-- libquvi-scripts

local Vidstream = {}

-- Identify the script.
function ident(qargs)
  return {
    domains = table.concat({'vidstream.in'}, ','),
    can_parse_url = Vidstream.can_parse_url(qargs)
  }
end

-- Parse media URL.
function parse(qargs)
  local c = quvi.http.fetch(qargs.input_url).data
  local p = { op = "download1", imhuman = "Proceed+to+video",
              id = qargs.input_url:match('vidstream.in/([^/]+)'),
              hash = c:match('name="hash" value="(.-)"') }
  local R = require 'soup_request'
  c = R.request(qargs.input_url, "POST", p)

  qargs.id = p.id
  qargs.title = c:match('property="og:title"%s+content="(.-)"')
  qargs.thumb_url = c:match('property="og:image"%s+content="(.-)"')
  qargs.duration_ms = tonumber(c:match('duration:%s*"(%d+)"') or 0) * 1000
  qargs.streams = Vidstream.iter_streams(c, qargs)

  return qargs
end

function Vidstream.iter_streams(c, qargs)
  local S = require 'quvi/stream'

  url,container = c:match('file:%s*"(.-/)v%.(.-)"')
  local s = S.stream_new(table.concat({url, "v.", container}))
  s.container = container
  return { s }
end

function Vidstream.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)

  return t and t.scheme and t.scheme:lower():match('^http$')
           and t.host and t.host:lower():match('vidstream%.in$')
           and t.path and t.path:match("^/[a-z0-9]+")
           and true or false
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
