-- libquvi-scripts

local Radio = {}

-- Identify the script.
function ident(qargs)
  return {
    domains = table.concat({'radio.de'}, ','),
    can_parse_url = Radio.can_parse_url(qargs)
  }
end

-- Parse media URL.
function parse(qargs)
  local S = require 'quvi/stream'
  local c = quvi.http.fetch(qargs.input_url).data

  if c:match('<error>') then
    local s = c:match('<message>(.-)[\n<]')
    error((not s) and "no match: error message" or s)
  end

  qargs.id = qargs.input_url:match('http://(.-)%.radio%.de')
  qargs.title = c:match('property="og:title" content="(.-)">')
  qargs.thumb_url = c:match('property="og:image" content="(.-)"')

  local url = c:match('_getPlaylist.*"stream":"(.-)"')
  qargs.streams = { S.stream_new(url) }

  return qargs
end

function Radio.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)

  return t and t.scheme and t.scheme:lower():match('^http$')
           and t.host and t.host:lower():match('.-%.radio%.de$')
           and t.host ~= "www.radio.de" and true or false
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
