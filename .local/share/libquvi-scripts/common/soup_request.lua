-- libquvi-scripts

local M = {}

function M.request(url, method, params)
  local lgi = require 'lgi'
  local Soup = lgi.Soup
  local req = lgi.Soup.Session():request_http_uri(method, Soup.URI(url))

  function url_encode(str)
    if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w %-%_%.%~])",
          function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
    end
    return str
  end

  p = {}
  for k,v in pairs(params) do
    table.insert(p, table.concat({ k, '=', url_encode(v) }))
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

return M
