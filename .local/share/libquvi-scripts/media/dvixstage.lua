-- libquvi-scripts

local Dvixstage = {}

-- Identify the script.
function ident(qargs)
  return {
    domains = table.concat({'divxstage.eu'}, ','),
    can_parse_url = Dvixstage.can_parse_url(qargs)
  }
end

-- Parse media URL.
function parse(qargs)
  local c = quvi.http.fetch(qargs.input_url).data

  qargs.id = c:match('file="(.-)"') or error("no match id")
  qargs.title = c:match('<div class="video_det">%s+<strong>(.-)</strong>')
  qargs.streams = Dvixstage.iter_streams(c, qargs)

  return qargs
end

function Dvixstage.iter_streams(c, qargs)
  local S = require 'quvi/stream'

  filekey = c:match('filekey="(.-)"') or error("no match: filekey")
  api_url = { "http://www.divxstage.eu/api/player.api.php?file=",
              qargs.id, "&key=", filekey}
  url = quvi.http.fetch(table.concat(api_url)).data:match("url=([^&]+)")

  return { S.stream_new(url) }
end

function Dvixstage.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)

  return t and t.scheme and t.scheme:lower():match('^http$')
           and t.host and t.host:lower():match('divxstage%.eu$')
           and t.path and t.path:match("^/video/[a-z0-9]+")
           and true or false
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
