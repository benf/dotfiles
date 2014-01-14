-- Identify the script.
function ident(self)
    package.path = self.script_dir .. '/?.lua'
    local C      = require 'quvi/const'
    local r      = {}
    r.domain     = "zdf%.de"
    r.formats    = "default|best"
    local B      = require 'quvi/bit'
    r.categories = B.bit_or(C.proto_http, C.proto_rtsp)
    local U      = require 'quvi/util'
    r.handles    = U.handles(self.page_url, {r.domain}, {"/ZDFmediathek/"})
    return r
end

-- Query available formats.
function query_formats(self)
    self.formats = "default|best"

    return self
end

function parse_video(self, c)
    local url = c:match('<quality>veryhigh</quality>%s*' ..
                        '<url>(http://n?rodl%.zdf%.de/[^<]+%.mp4)</url>')
                        or error("no match: url")

    local meta_url = c:match('<quality>hd</quality>%s*<url>([^>]+%.meta)</url>')
    if meta_url then
        url = http_mp4_from_meta(meta_url) or url
        -- OLD code:
        -- known replacements from veryhigh mp4 to hd mp4:
        -- either: suffix _hd instead of _vh
        --url = string.gsub(url, "_vh.mp4", "_hd.mp4")
        -- or:
        --url = string.gsub(url, "1596k_p13v9", "3056k_p15v9")
    end

    if (c:match('<height>576</height>%s*<width>1024</width>')) then
        url = string.gsub(url, "1456k_p13v11", "2256k_p14v11")
    end

    self.url = { url }

    return self
end

function parse_live_video(self, c)
    self.url = { c:match("<quality>veryhigh</quality>%s*" ..
                        "<url>(rtsp://[^<]+)</url>")
                        or error("no match: rtsp url") }
    return self
end

-- Parse media URL.
function parse(self)
    self.host_id  = "zdfmediathek"

    self.id = self.page_url:match("/ZDFmediathek/#?/?beitrag/video/(%d+)") or
        self.page_url:match("/ZDFmediathek/#?/?beitrag/live/(%d+)")
        or error ("no match: media id")

    local xml = { "http://www.zdf.de/",
                  "ZDFmediathek/xmlservice/web/beitragsDetails?id=", self.id }

    local c = quvi.fetch(table.concat(xml), {fetch_type='config'})
    if not(c:match('<statuscode>ok</statuscode>')) then
        local msg = { 'error: ', xml_get(c, 'statuscode', false),
                      ' - ',  xml_get(c, 'debuginfo', false) }
        error(table.concat(msg))
    end

    local type = xml_get(c, 'type', false)
    self.title = xml_get(c, 'title', false)
    self.thumbnail_url = c:match('<teaserimage alt=".-" key="946x532">'..
                                 '([^<]+)</teaserimage>')
    if type == "video" then
        return parse_video(self, c)
    elseif type == "livevideo" then
        return parse_live_video(self, c)
    else
        error("unknown video type")
    end
end

-- utlity

--
function http_mp4_from_meta(meta_url)
    local c = quvi.fetch(meta_url, {fetch_type='config'})
    local path = c:match("mp4:(.-%.mp4)")

    return path and "http://nrodl.zdf.de/none/" .. path or nil
end


--For very simple XML value extraction.
function xml_get(d, e, is_cdata)
    local p = is_cdata and '.-%w+%[(.-)%].-' or '(.-)'
    local t = {'<',e,'>', p, '</',e,'>'}
    return d:match(table.concat(t))
              or error(table.concat({'no match: element: ',e}))
end

-- vim: set ts=4 sw=4 tw=72 expandtab:
