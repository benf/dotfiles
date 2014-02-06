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

-- http://stackoverflow.com/questions/3554315/lua-base-converter
function Xvidstage.basen(n,b)
    n = math.floor(n)
    if not b or b == 10 then return tostring(n) end
    local digits = "0123456789abcdefghijklmnopqrstuvwxyz"
    local t = {}
    repeat
        local d = (n % b) + 1
        n = math.floor(n / b)
        table.insert(t, 1, digits:sub(d,d))
    until n == 0
    return table.concat(t)
end

function Xvidstage.unpack_minjs(minjs)
  p,a,c,k = minjs:match("return p}%('(.-\\'%);)',(%d+),(%d+),'(.-)'")

  base = tonumber(a)
  -- num = tonumber(c) -- not needed
  code = p:gsub("\\'", "'")

  data = {}
  for w in (k:gsub("||", "| |")..'|'):gmatch("([^|]+)|") do
    table.insert(data, w)
  end

  for i=1,#data do
    if data[i] ~= " " then
      local s = Xvidstage.basen(i-1, base)
      code = code:gsub("([^a-z0-9])"..s.."([^a-z0-9])", "%1"..data[i].."%2")
    end
  end

  return code
end

function Xvidstage.iter_streams(c, qargs)
  local S = require 'quvi/stream'

  local mp3_url = c:match("addVariable%('file','(.+/)[^/]+%.mp3'%)")
  if mp3_url then
    local s = S.stream_new(table.concat({mp3_url,qargs.title}))
    s.container = "mp3"
    return { s }
  end

  local packed = c:match("<div id=\"player_code\"><script[^>]+>([^\n]+)")
  c = Xvidstage.unpack_minjs(packed)

  local id_pattern = string.rep('[a-z0-9]', 56)
  url,ext = c:match('["\'](http://[^"\']+/d/'..id_pattern..'/)video%.(.-)["\']')
  local s = S.stream_new(table.concat({url, qargs.title}))
  s.container = ext
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
