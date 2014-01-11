-- Identify the script.
function ident(self)
    package.path = self.script_dir .. '/?.lua'
    local C      = require 'quvi/const'
    local r      = {}
    r.domain     = "zdf%.de"
    r.formats    = "default|best"
    r.categories = C.proto_rtmp
    local U      = require 'quvi/util'
    r.handles    = U.handles(self.page_url, {r.domain},
                             {"/ZDFmediathek/beitrag/video/"})
    return r
end

-- Query available formats.
function query_formats(self)
    self.formats = "default|best"

    return self
end

-- Parse media URL.
function parse(self)
    self.host_id  = "zdfmediathek"

    self.id = self.page_url:match("/ZDFmediathek/beitrag/video/(%d+)")
                or error ("no match: media id")

    local xmlwebservice_url = "http://www.zdf.de/ZDFmediathek/xmlservice/web/beitragsDetails?id=" .. self.id

    local c = quvi.fetch(xmlwebservice_url, {fetch_type='config'})
    if c:match('<error>') then
        local s = c:match('<message>(.-)[\n<]')
        error( (not s) and "no match: error message" or s )
    end

    self.title = c:match('<title>([^<]*)</title>')
        or error("no match: media title")

    self.thumbnail_url = c:match('<teaserimage alt="[^"]*" key="946x532">([^<]*)</teaserimage>')

    local url = c:match('<quality>veryhigh</quality>[ \n]*<url>(http://nrodl.zdf.de/[^<]*\.mp4)</url>')

    if (c:match('<width>1024</width>')) then
        url = string.gsub(url, "1456k_p13v11", "2256k_p14v11")
    end

    self.url = { url }

    return self
end

-- vim: set ts=4 sw=4 tw=72 expandtab:
