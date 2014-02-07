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
  local R = require 'soup_request'
  local p = { op = "download1", method_free = "1",
              id = qargs.input_url:match('xvidstage.com/([^/]+)') }
  local c = R.request(qargs.input_url, "POST", p)

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
      repeat
        code, count = code:gsub("([^a-zA-Z0-9])"..s.."([^a-zA-Z0-9])", '%1'..data[i]..'%2')
      until count == 0
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

  local pattern = string.rep('[a-z0-9]', 56)
  local packed = c:match("(function%(p,a,c,k,e,d%)[^\n]+"..pattern.."[^\n]+)%)")
  c = Xvidstage.unpack_minjs(packed)

  url,ext = c:match('["\'](http://[^"\']+/d/'..pattern..'/)video%.(.-)["\']')
  local s = S.stream_new(table.concat({url, qargs.title}))
  s.container = ext
  return { s }
end

function Xvidstage.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)

  return t and t.scheme and t.scheme:lower():match('^http$')
           and t.host and t.host:lower():match('xvidstage%.com$')
           and t.path and t.path:match("^/[a-z0-9]+")
           and true or false
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
