-- Identify the script.
function ident(self)
    package.path = self.script_dir .. '/?.lua'
    local C      = require 'quvi/const'
    local r      = {}
    r.domain     = "ulmen%.tv"
    r.formats    = "default|best"
    r.categories = C.proto_rtmp
    local U      = require 'quvi/util'
    r.handles    = U.handles(self.page_url, {r.domain}, {"/stuckrad%-barre/%d+/.+$"})
    return r
end

-- Query available formats.
function query_formats(self)
    self.formats = "default|best"

    return self
end

-- Parse media URL.
function parse(self)
    self.host_id  = "ulmentv"

    local c = quvi.fetch(self.page_url, {fetch_type='config'})
    if c:match('<error>') then
        local s = c:match('<message>(.-)[\n<]')
        error( (not s) and "no match: error message" or s )
    end

    self.title = c:match('<meta content="([^"]*)" property="og:title"')
        or error("no match: media title")

    self.thumbnail_url = c:match('<meta content="([^"]*)" property="og:image"')
        or error("no match: thumbnail")

    self.id = c:match('<a href="#" data%-url="([^"]*)"')
        or error("no match: request data url")

    self.url = { "rtmp://178.23.127.5:1935/vod/" .. self.id }

    return self
end

-- vim: set ts=4 sw=4 tw=72 expandtab:
