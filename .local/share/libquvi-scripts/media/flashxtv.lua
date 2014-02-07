-- libquvi-scripts

local Flashx = {}

-- Identify the script.
function ident(qargs)
  return {
    domains = table.concat({'flashx.tv'}, ','),
    can_parse_url = Flashx.can_parse_url(qargs)
  }
end

-- Parse media URL.
function parse(qargs)
  local c = quvi.http.fetch(qargs.input_url).data
  qargs.title = c:match('<div class="video_title">(.-)</div>')
  local iframe_url = c:match('<iframe[^>]+src="(http://play.flashx.tv/.-)"')
  if not(iframe_url) then error("file not available") end

  c = quvi.http.fetch(iframe_url).data
  local p = { yes = c:match('name="yes"[^>]+value="(.-)"'),
              sec = c:match('name="sec"[^>]+value="(.-)"') }
  local R = require 'soup_request'
  c = R.request("http://play.flashx.tv/player/player.php", "POST", p)
  local data_url = c:match('data="[^"]+config=(.-)"')
  c = quvi.http.fetch(data_url).data

  qargs.id = qargs.input_url:match('video/([A-Z0-9]+)')
  qargs.thumb_url = c:match('<image>(.-)</image>')
  qargs.streams = Flashx.iter_streams(c, qargs)

  return qargs
end

function Flashx.iter_streams(c, qargs)
  local S = require 'quvi/stream'

  url = c:match('<file>(.-)</file>')
  local s = S.stream_new(url)
  s.container = "flv"
  return { s }
end

function Flashx.can_parse_url(qargs)
  local U = require 'socket.url'
  local t = U.parse(qargs.input_url)

  return t and t.scheme and t.scheme:lower():match('^http$')
           and t.host and t.host:lower():match('flashx%.tv$')
           and t.path and t.path:match("^/video/[A-Z0-9]+")
           and true or false
end

-- vim: set ts=2 sw=2 tw=72 expandtab:
