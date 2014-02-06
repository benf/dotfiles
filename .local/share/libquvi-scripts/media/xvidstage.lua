-- libquvi-scripts

local Xvidstage = {}

-- Identify the script.
function ident(qargs)
  return {
    domains = table.concat({'xvidstage.com'}, ','),
    can_parse_url = Xvidstage.can_parse_url(qargs)
  }
end

-- Parse media URL.
function parse(qargs)
  local p = { op = "download1", method_free = "1",
              id = qargs.input_url:match('xvidstage.com/([^/]+)') }
  local c = Xvidstage.request(qargs.input_url, "POST", p)

  qargs.id = p.id
  qargs.title = c:match('Dateiname:</td><td[^>]*>(.-)</td>')
  qargs.streams = Xvidstage.iter_streams(c, qargs)

  return qargs
end

function Xvidstage.iter_streams(c, qargs)
  local S = require 'quvi/stream'

  local mp3_url = c:match("addVariable%('file','(.-%.mp3)'%)")
  if mp3_url then
    local s = S.stream_new(mp3_url)
    s.container = "mp3"
    return { s }
  end

  local hash_pattern = string.rep('[a-z0-9]', 56)
  container, hash, port = c:match('|([^|]-)|(' .. hash_pattern .. ')|(%d-)|')
  ip4, ip3, ip2, ip1 = c:match('|(%d-)|+(%d-)|+(%d-)|+(%d-)|')

  local ip = table.concat({ip1,ip2,ip3,ip4},'.')
  local url = { "http://", ip , ':', port, '/d/', hash, '/', qargs.title }
  local s = S.stream_new(table.concat(url))
  s.container = container
  return { s }
end

function Xvidstage.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)

  return t and t.scheme and t.scheme:lower():match('^http$')
           and t.host and t.host:lower():match('xvidstage%.com$')
           and true or false
end

function Xvidstage.request(url, method, params)
  local lgi = require 'lgi'
  local Soup = lgi.Soup
  local req = lgi.Soup.Session():request_http_uri(method, Soup.URI(url))

  p = {}
  for k,v in pairs(params) do
    table.insert(p, table.concat({ k, '=', v }))
  end
  p = table.concat(p, '&')

  if method == "POST" then
    req:get_message():set_request("application/x-www-form-urlencoded", 0, p, #p)
  end

  function read(stream)
    local Bytes = require 'bytes'
    local buffer = Bytes.new(4096)
    local out = {}

    while true do
      local size = stream:read(buffer)
      if size <= 0 then
        break;
      end
      table.insert(out, tostring(buffer):sub(1, size))
    end

    return table.concat(out)
  end

  return read(req:send())
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
