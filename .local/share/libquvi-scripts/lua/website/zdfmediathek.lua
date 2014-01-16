local ZDFmediathek = {} -- Utility functions unique to this script.

-- Identify the script.
function ident(self)
    package.path = self.script_dir .. '/?.lua'
    local B      = require 'quvi/bit'
    local C      = require 'quvi/const'
    local U      = require 'quvi/util'
    local r      = {}
    r.domain     = "zdf%.de"
    r.formats    = "default|best"
    r.categories = B.bit_or(C.proto_http, C.proto_rtsp)
    r.handles    = U.handles(self.page_url, {r.domain}, {"/ZDFmediathek/"})
    return r
end

-- Query available formats.
function query_formats(self)
    local c = ZDFmediathek.get_config(self)
    local fmts = ZDFmediathek.iter_formats(c)
    local r = {}

    table.sort(fmts, ZDFmediathek.compare_format)
    for _,f in pairs(fmts) do
        table.insert(r, ZDFmediathek.to_s(f))
    end
    self.formats = table.concat(r, "|")

    return self
end

-- Parse media URL.
function parse(self)
    local U = require 'quvi/util'

    local c = ZDFmediathek.get_config(self)
    local fmts = ZDFmediathek.iter_formats(c)

    local f = U.choose_format(self, fmts,
                              ZDFmediathek.choose_best,
                              ZDFmediathek.choose_default,
                              ZDFmediathek.to_s)
                    or error("unable to match format")

    self.url = { f.url or error("no match: media URL") }

    return self
end

function ZDFmediathek.merge_format(fmt1, fmt2)
    local t = {}
    for k,v in pairs(fmt1) do t[k] = v end
    for k,v in pairs(fmt2) do t[k] = v end
    return t
end

function ZDFmediathek.table_add_format(t, fmt)
    -- Only accessible with HBBTV user agent, lets drop it
    -- FIXME: store facets in fmt and match for <facet>hbbtv</facet>?
    if fmt.url:match('http://www.metafilegenerator.de/') then
        return
    end
    -- The livestream smil URL is not accessible (404)
    if fmt.type == "h264_aac_mp4_rtmp_smil_http" then
        return
    end

    table.insert(t, fmt)

    -- Some URLs/Formats are not explicitly listed but can be derived:

    -- The "high"-quality f4m file may contain a reference to a file that is
    -- of better quality than "veryhigh" classified http streams.
    -- Example: 2256k instead of 1496k
    if fmt.quality == "high" and fmt.type == "h264_aac_f4f_http_f4m_http" then
        local new = { type = "h264_aac_mp4_http_na_na",
                      container = "mp4", quality = "veryhigh_ext" }
        new.url = ZDFmediathek.http_mp4_from_f4m(fmt.url)
        if new.url then
            table.insert(t, ZDFmediathek.merge_format(fmt, new))
        end
    end

    if fmt.quality == "hd" and fmt.type == "h264_aac_mp4_rtmp_zdfmeta_http" then
        local new = { type = "h264_aac_mp4_http_na_na", container = "mp4",
                      proto = "http" }
        new.url = ZDFmediathek.http_mp4_from_meta(fmt.url)
        if new.url then
            table.insert(t, ZDFmediathek.merge_format(fmt, new))
        end
    end

    return
end

function ZDFmediathek.iter_formats(c)
    local p = {
        '<formitaet basetype="((.-)_(.-)_(.-)_(.-)_.-)".->',
          '<quality>(.-)</quality>',
          '<url>(.-)</url>',
          '(.-)',
        '</formitaet>'
    }
    local t = {}

    for type,vcodec,acodec,container,proto,quality,url,data in
        c:gmatch(table.concat(p, '%s*')) do
        f = { type = type, container = container, url = url, vcodec = vcodec,
              acodec = acodec, proto = proto, quality = quality }
        -- width and height are not available for live streams -> may be nil
        f.width = tonumber(data:match("<width>(.-)</width>"))
        f.height = tonumber(data:match("<height>(.-)</height>"))
        ZDFmediathek.table_add_format(t, f)
    end

    return t
end

function ZDFmediathek.get_config(self)
    self.host_id  = "zdfmediathek"

    self.id = self.page_url:match('/ZDFmediathek/#?/?beitrag/video/(%d+)') or
        self.page_url:match('/ZDFmediathek/#?/?beitrag/live/(%d+)')
        or error ("no match: media id")

    local xml = { "http://www.zdf.de/",
                  "ZDFmediathek/xmlservice/web/beitragsDetails?id=", self.id }

    local c = quvi.fetch(table.concat(xml), {fetch_type='config'})
    if not(c:match('<statuscode>ok</statuscode>')) then
        error(table.concat({'error:', xml_get(c, 'statuscode', false), '-',
                                      xml_get(c, 'debuginfo', false)}, ' '))
    end

    self.title = xml_get(c, 'title', false)
    self.thumbnail_url =
            c:match('<teaserimage alt=".-" key="946x532">([^<]+)</teaserimage>')

    -- Quirks for broken stream descriptors
    if xml_get(c, 'type', false) == "livevideo" then
        -- The server returns 403 without ?hdcore
        c = c:gsub('manifest%.f4m</url>', 'manifest.f4m?hdcore</url>')

        -- Fix incorrect basetype
        c = c:gsub('h264_aac_na_rtsp_mov_http', 'h264_aac_3gp_rtsp_na_na')
    end

    return c
end

function ZDFmediathek.http_mp4_from_meta(meta_url)
    local c = quvi.fetch(meta_url, {fetch_type='config'})
    local path = c:match("mp4:(.-%.mp4)")

    return path and "http://nrodl.zdf.de/none/" .. path or nil
end

function ZDFmediathek.http_mp4_from_f4m(f4m_url)
    local c = quvi.fetch(f4m_url, {fetch_type='config'})
    local max_bitrate = 0
    local path = nil

    for p, bitrate in c:gmatch('<media href="(.-)/manifest%.f4m%?hdcore"'..
                               ' bitrate="(%d+)"/>') do
        if tonumber(bitrate) > max_bitrate then
            max_bitrate = tonumber(bitrate)
            path = p
        end
    end

    return path and "http://nrodl.zdf.de/none/" .. path or nil
end

function ZDFmediathek.rank_type(f)
    local rank = {
        h264_aac_mp4_http_na_na    = 4,
        vp8_vorbis_webm_http_na_na = 3,
        h264_aac_3gp_rtsp_na_na    = 2,
        h264_aac_ts_http_m3u8_http = 1
    }
    return rank[f.type] and rank[f.type] or 0
end

function ZDFmediathek.rank_quality(f)
    local r = {
        hd = 6, veryhigh_ext = 5, veryhigh = 4, high = 3, med = 2, low = 1
    }
    return rank[f.quality] and rank[f.quality] or 0
end

function ZDFmediathek.compare_format(f1, f2)
    local t1 = ZDFmediathek.rank_type(f1)
    local t2 = ZDFmediathek.rank_type(f2)

    if (t1 ~= t2) then
        return t1 > t2
    end

    if f1.width and f2.width and f1.height and f2.height then
        local U = require 'quvi/util'
        return U.is_higher_quality(f1, f2)
    end

    return ZDFmediathek.rank_quality(f1) > ZDFmediathek.rank_quality(f2)
end

function ZDFmediathek.choose_best(t)
    table.sort(t, ZDFmediathek.compare_format)
    return t[1]
end

ZDFmediathek.choose_default = ZDFmediathek.choose_best

function ZDFmediathek.to_s(t)
    return string.format("%s%s_%s%s",
                         t.container,
                         (t.proto ~= "http") and '_' .. t.proto or '',
                         t.quality,
                         (t.height) and '_' .. t.height ..'p' or '')
end


--For very simple XML value extraction.
function xml_get(d, e, is_cdata)
    local p = is_cdata and '.-%w+%[(.-)%].-' or '(.-)'
    local t = {'<',e,'>', p, '</',e,'>'}
    return d:match(table.concat(t))
              or error(table.concat({'no match: element: ',e}))
end

-- vim: set ts=4 sw=4 tw=72 expandtab: