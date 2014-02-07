-- libquvi-scripts

local Putlocker = {}

-- Identify the script.
function ident(qargs)
  return {
    domains = table.concat({'putlocker.com'}, ','),
    can_parse_url = Putlocker.can_parse_url(qargs)
  }
end

-- Parse media URL.
function parse(qargs)
  local R = require 'soup_request'
  local c = quvi.http.fetch(qargs.input_url).data
  local p = { confirm = "Continue as Free User",
              hash = c:match('value="([^"]+)" name="hash"') }
  c = R.request(qargs.input_url, "POST", p)

  qargs.id = qargs.input_url:match("file/([A-Z0-9]+)")
  qargs.title = c:match('<div class="site-content">%s*<h1>(.-)<strong>')
  --qargs.thumb_url = c:match('property="og:image"%s+content="(.-)"')
  --qargs.duration_ms = tonumber(c:match('duration:%s*"(%d+)"') or 0) * 1000
  qargs.streams = Putlocker.iter_streams(c, qargs)

  return qargs
end

function Putlocker.iter_streams(c, qargs)
  local S = require 'quvi/stream'

  url = c:match('<a href="([^"]+)" class="download_file_link"')

  --  url,container = c:match('file:%s*"(.-/)v%.(.-)"')
  local s = S.stream_new(table.concat({"http://www.putlocker.com", url}))
  --s.container = container
  return { s }
end

function Putlocker.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)

  return t and t.scheme and t.scheme:lower():match('^http$')
           and t.host and t.host:lower():match('putlocker%.com$')
           and t.path and t.path:match("^/file/[A-Z0-9]+")
           and true or false
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
