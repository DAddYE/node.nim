from tcp import nil
from uv import nil
from os import nil

import re
import utils
import http
import events

type
  Server = object of uv.TTcp
    callback: RequestListener

  Client = object of uv.TTcp
    request: ref http.Request

  RequestListener = proc (req: ref Client, res: ref Server)

var
  loop = uv.default_loop()

const
  ip6regex = r"^(((?=.*(::))(?!.*\3.+\3))\3?|([\dA-F]{1,4}(\3|:\b|$)|\2))(?4){5}((?4){2}|(((2[0-4]|1\d|[1-9])?\d|25[0-5])\.?\b){4})\z"

proc on (c: ref Client, event: string, func: proc (req: ref Request)) =
  c.request.events.addListener(event) do (a: events.EventArgs):
    var event_arg = http.EventArg(a) #.request
    func(event_arg.request)

proc on_alloc (handle: ref uv.THandle, suggested_size: int): uv.TBuf {.cdecl.} =
  withoutGC do:
    debug "-> request buffer of size: ", suggested_size
    # TODO: check if I should mark `var s` with GC_ref
    var s = ""; s.setLen(suggested_size)
    result = uv.buf_init(s, suggested_size.uint)

proc on_write (req: ref uv.TWrite, status: int) {.cdecl.} =
  withoutGC do:
    debug "-> got on_write"
    var tcp = req.handle
    var cli = cast[ref Client](tcp) # this is uv.TStream <-> Client
    uv.close(cli, nil)

proc on_headers (req: ref Request) =
  withoutGC do:
    debug "-> got on_headers"
    var s  = "HTTP/1.1 200 OK\r\n" &
      "Content-Type: text/plain\r\n" &
      "Content-Length: 12\r\n" &
      "\r\n" &
      "hello world\n"
    var buf = uv.TBuf.new
    buf.base = s
    buf.len  = s.len
    var err  = uv.write(req.writer, req.stream, buf, 1, on_write)
    if err > 0: tcp.raise_error()

proc on_read (req: ref uv.TStream, nread: int, buf: uv.TBuf){.cdecl.} =
  withoutGC do:
    debug "-> got read_tcp for: ", buf.base

    if nread == -1 and uv.last_error(loop).code != uv.EOF: tcp.raise_error()
    var cli = cast[ref Client](req)
    cli.request.stream = req
    cli.request.writer.new
    cli.on("headers", on_headers)
    var parsed = cli.request.parse(buf.base, buf.len)
    if parsed < nread: echo "Parsing error!"

proc on_connect (server: ref uv.TStream, status: int){.cdecl.} =
  withoutGC do:
    debug "-> got a new connection request"

    if status == -1: tcp.raise_error()
    var cli = Client.new
    cli.request = http.init_request()

    if uv.tcp_init(loop, cli) > 0: tcp.raise_error()
    if uv.accept(server, cli) > 0: tcp.raise_error()
    if uv.read_start(cli, on_alloc, on_read) > 0: tcp.raise_error()

    # Get back my original object
    var srv = cast[ref Server](server)
    srv.callback(cli, srv)

proc listen (srv: ref Server, port: int, address: string = "0.0.0.0") =
  if address =~ re(ip6regex): tcp.bind_to6(srv, address, port)
  else: tcp.bind_to(srv, address, port)
  var err = uv.listen(srv, 128, on_connect)
  if err > 0: tcp.raise_error()

proc create_server* (callback: RequestListener): ref Server =
  result.new
  result.callback = callback
  var err = uv.tcp_init(loop, result)
  if err > 0: tcp.raise_error()

when isMainModule:
  block:
    var s = create_server do (req: ref Client, res: ref Server):
      # echo "mmm2"
    s.listen(3000)
    echo "Listening on http://localhost:3000"
    var err = uv.run(loop, uv.RUN_DEFAULT)
    uv.check err
