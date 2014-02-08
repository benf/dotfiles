-- libquvi-scripts
-- Copyright (C) 2014  Benjamin Franzke <benjaminfranzke@googlemail.com>
--
-- This file is part of libquvi-scripts <http://quvi.sourceforge.net/>.
--
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Affero General Public
-- License as published by the Free Software Foundation, either
-- version 3 of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General
-- Public License along with this program.  If not, see
-- <http://www.gnu.org/licenses/>.
--

local ZDFmediathek = {} -- Utility functions unique to this script.

-- Identify the script.
function ident(qargs)
  return {
    can_parse_url = ZDFmediathek.can_parse_url(qargs),
    domains = table.concat({'zdf.de'}, ',')
  }
end

function ZDFmediathek.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)

  if t and t.scheme and t.scheme:lower():match('^http$')
       and t.host and t.host:lower():match('zdf%.de$')
       and t.path and t.path:match('/ZDFmediathek/')
  then
    return true
  else
    return false
  end
end

ZDFmediathek.xmlservice_schema = {
  status = { statuscode = false, debuginfo = true },
  video = {
    information = { title = false },
    details = { lengthSec = true },
    teaserimages = { teaserimage = {} },
    formitaeten = {
      formitaet = {
        quality = false,
        url = false,
        width = true,
        height = true,
        videoBitrate = true,
        audioBitrate = true,
        facets = { facet = false }
      }
    }
  }
}

function ZDFmediathek.find_tag(t, tag)
  local r = {}
  for i=1, #t do
    if t[i].tag == tag then
      table.insert(r, t[i])
    end
  end
  return r
end

function ZDFmediathek.find_first_tag(t, tag, optional)
  for i=1, #t do
    if t[i].tag == tag then
      return t[i]
    end
  end
  if optional then
    return {}
  else
    error("[find_first_tag] no match: tag=" .. tag)
  end
end

function ZDFmediathek.extract_schema(x, s)
  local t = {}

  for k,v in pairs(s) do
    if type(v) == "boolean" then
      t[k] = ZDFmediathek.find_first_tag(x, k, v)[1]
    elseif type(v) == "table" then
      local tags = ZDFmediathek.find_tag(x, k)

      t[k] = {}
      for _,tag in ipairs(tags) do
        if next(v) == nil then -- if v is empty insert the tag values
          table.insert(t[k], tag[1])
        else
          local d = ZDFmediathek.extract_schema(tag, v)
          d.attr = tag.attr
          table.insert(t[k], d)
        end
      end

      if #t[k] == 1 then t[k] = t[k][1] end
    end
  end

  return t
end

-- Parse media URL.
function parse(qargs)
  local P = require 'lxp.lom'

  qargs.id = qargs.input_url:match('/ZDFmediathek/#?/?beitrag/video/(%d+)') or
             qargs.input_url:match('/ZDFmediathek/#?/?beitrag/live/(%d+)')
             or error ("no match: media id")
  local xml = { "http://www.zdf.de/",
                "ZDFmediathek/xmlservice/web/beitragsDetails?id=", qargs.id }
  local c = quvi.http.fetch(table.concat(xml)).data
  local x = P.parse(c)
  local r = ZDFmediathek.extract_schema(x, ZDFmediathek.xmlservice_schema)
  --io.stderr:write(dump(r) .. '\n')

  if r.status.statuscode ~= "ok" then
    error(table.concat({'error: ', r.status.statuscode, ' - ', r.status.debuginfo or ''}))
  end

  qargs.title = r.video.information.title
  local imgs = r.video.teaserimages.teaserimage
  qargs.thumb_url = imgs[#imgs]

  qargs.duration_ms = 1000 * tonumber(r.video.details.lengthSec or '0')
  qargs.streams = ZDFmediathek.iter_streams(r)

  return qargs
end

function ZDFmediathek.add_stream(t, s)
  local e = s.nostd
  if e.facet == 'hbbtv' then return end -- Only for HBBTV useragents, drop it.

  table.insert(t, s)

  -- Some URLs/Formats are not explicitly listed but can be derived:

  -- The "high"-quality f4m file may contain a reference to a file that is
  -- of better quality than "veryhigh" classified http streams.
  -- Example: 2256k instead of 1496k
  if e.quality == "high" and e.type == "h264_aac_f4f_http_f4m_http" then
    local new = { container = "mp4" ,
                  nostd = { type = "h264_aac_mp4_http_na_na" } }
    new.url = ZDFmediathek.http_mp4_from_f4m(s.url)
    if new.url then
      table.insert(t, ZDFmediathek.merge_stream_descriptor(s, new))
    end
  end

  -- HD quality movies are not listed with an http url.
  -- But one can build it from the rtmp URL given in a .meta file:
  if e.quality == "hd" and e.type == "h264_aac_mp4_rtmp_zdfmeta_http" then
    local n = { container = "mp4",
                nostd = { type = "h264_aac_mp4_http_na_na", protocol = "http" }}
    new.url = ZDFmediathek.http_mp4_from_zdfmeta(s.url)
    if new.url then
      table.insert(t, ZDFmediathek.merge_stream_descriptor(s, new))
    end
  end
end

function ZDFmediathek.stream_apply_quirks(s, U)
  if U.ends_with(s.url, 'manifest.f4m') then
    s.url = s.url .. '?hdcore' -- The server returns 403 without ?hdcore
  end
  if s.nostd.type == 'h264_aac_na_rtsp_mov_http' then
    s.nostd.type = 'h264_aac_3gp_rtsp_na_na' -- Add missing container specifier
  end
end

function ZDFmediathek.iter_streams(r)
  local S = require 'quvi/stream'
  local U = require 'quvi/util'

  local t = {}
  for _,fmt in ipairs(r.video.formitaeten.formitaet) do
    local s = S.stream_new(fmt.url)
    s.nostd = { type = fmt.attr.basetype or error("missing type attribute"),
                quality = fmt.quality }
    ZDFmediathek.stream_apply_quirks(s, U)

    s.video.width = tonumber(fmt.width or 0)
    s.video.height = tonumber(fmt.height or 0)

    s.video.bitrate_kbit_s = fmt.videoBitrate or ''
    s.audio.bitrate_kbit_s = fmt.audioBitrate or ''

    s.video.encoding, s.audio.encoding, s.container, s.nostd.protocol =
        s.nostd.type:match("^(.-)_(.-)_(.-)_(.-)_.-")
    s.nostd.facet = fmt.facets.facet or nil
    ZDFmediathek.add_stream(t, s)
  end

  for _,v in pairs(t) do
    v.id = ZDFmediathek.to_id(v)
  end

  table.sort(t, ZDFmediathek.compare_stream)
  -- After sort, first stream is the best
  t[1].flags.best = true

  return t
end

function ZDFmediathek.http_mp4_from_zdfmeta(meta_url)
  local c = quvi.http.fetch(meta_url).data
  local path = c:match("mp4:(.-%.mp4)")

  return path and "http://nrodl.zdf.de/none/" .. path or nil
end

function ZDFmediathek.http_mp4_from_f4m(f4m_url)
  local c = quvi.http.fetch(f4m_url).data
  local t = { max_rate = 0, path = nil }

  for p, r in c:gmatch('href="(.-)/manifest%.f4m%?hdcore" bitrate="(%d+)"') do
    if tonumber(r) > t.max_rate then
      t = { max_rate = tonumber(r), path = p }
    end
  end

  return t.path and "http://nrodl.zdf.de/none/" .. t.path or nil
end

function ZDFmediathek.rank_type(s)
  local rank = {
    h264_aac_mp4_http_na_na    = 4,
    vp8_vorbis_webm_http_na_na = 3,
    h264_aac_3gp_rtsp_na_na    = 2,
    h264_aac_ts_http_m3u8_http = 1
  }
  return rank[s.nostd.type] and rank[s.nostd.type] or 0
end

function ZDFmediathek.rank_quality(s)
  local rank = { hd = 5, veryhigh = 4, high = 3, med = 2, low = 1 }
  return rank[s.nostd.quality] and rank[s.nostd.quality] or 0
end

function ZDFmediathek.compare_stream(s1, s2)
  local t1 = ZDFmediathek.rank_type(s1)
  local t2 = ZDFmediathek.rank_type(s2)

  if (t1 ~= t2) then
    return t1 > t2
  end

  local v = { s1.video, s2.video }
  if v[1].width and v[2].width and v[1].height and v[2].height then
    return v[1].width > v[2].width and v[1].height > v[2].height
  end

  return ZDFmediathek.rank_quality(s1) > ZDFmediathek.rank_quality(s2)
end

function ZDFmediathek.to_id(s)
  local proto = (s.nostd.protocol ~= "http") and '_' .. s.nostd.protocol or ''
  local quality = (s.video.height) and s.video.height ..'p' or s.nostd.quality
  return table.concat({ s.container, proto, '_', quality })
end

function ZDFmediathek.table_append(source, dest)
  for k,v in pairs(source) do
    if type(v) == "table" then
      if type(dest[k]) ~= "table" then
        dest[k] = {}
      end
      ZDFmediathek.table_append(v, dest[k])
    else
      dest[k] = v
    end
  end
end

function ZDFmediathek.merge_stream_descriptor(s1, s2)
  local t = {}
  ZDFmediathek.table_append(s1, t)
  ZDFmediathek.table_append(s2, t)
  return t
end

function dump(o)
if type(o) == 'table' then
local s = '{ '
for k,v in pairs(o) do
if type(k) ~= 'number' then k = '"'..k..'"' end
s = s .. '['..k..'] = ' .. dump(v) .. ','
end
return s .. '} '
else
return tostring(o)
end
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
