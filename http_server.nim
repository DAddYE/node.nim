import re
import utils
import http
import events
import uv

type
  Server = ref object of Tcp
    callback: RequestListener

  Client = ref object of Tcp
    request: ref http.Request
    server: Server

  RequestListener = proc (req: Client, res: Server)
  ErrorIO* = object of system.EIO

var
  loop = defaultLoop()
  respStr  = """
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 12

hello world
  """
  resp = Buf.new

resp.base = respStr
resp.len  = respStr.len

const
  ip6regex = r"^(((?=.*(::))(?!.*\3.+\3))\3?|([\dA-F]{1,4}(\3|:\b|$)|\2))(?4){5}((?4){2}|(((2[0-4]|1\d|[1-9])?\d|25[0-5])\.?\b){4})\z"

proc raiseError* () =
  var e = ErrorIO.new
  e.msg = $uv.strerror(loop.lastError())
  raise e

proc on (c: Client, event: string, func: proc (req: ref Request)) =
  c.request.events.addListener(event) do (a: events.EventArgs):
    debug "-> got event: ", event
    func(http.EventArg(a).request)

proc onAlloc (handle: ref Handle, suggestedSize: int): Buf {.cdecl.} =
  debug "-> request buffer of size: ", suggestedSize
  result.base = cast[cstring](alloc(suggestedSize))
  result.len = suggestedSize

proc onClose (handle: ref Handle){.cdecl.} =
  debug "-- Connection closed, occupied mem: ", getOccupiedMem()
  # dealloc cast[pointer](handle) # do I really need that?

proc onWrite (req: ref Write, status: int) {.cdecl.} =
  debug "-> got onWrite"
  req.handle.close(onClose)

proc onHeaders (req: ref Request) =
  debug "-> got onHeaders"
  # req.server
  # .callback(req, req.server)
  if req.writer.write(req.stream, resp, 1, onWrite) > 0: raiseError()

proc onRead (req: ref Stream, nread: int, buf: Buf){.cdecl.} =
  debug "-> got onRead"
  let cli = cast[Client](req)
  if nread >= 0:
    cli.request.stream = req
    cli.request.writer.new
    cli.on("headers", onHeaders)
    if cli.request.parse(buf.base, nread) < nread:
      echo "Parsing error!"
      uv.close(cli, on_close)
  else:
    if loop.lastError.code != uv.EOF: raiseError()
    uv.close(cli, on_close)
  dealloc(buf.base)

proc onConnect (srv: ref Stream, status: int){.cdecl.} =
  debug "-> got onConnect status: ", status

  if status == -1: raiseError()
  var cli: Client; cli.new
  cli.request = http.initRequest()
  cli.server  = cast[Server](srv)

  if loop.tcpInit(cli) > 0: raiseError()
  if srv.accept(cli) > 0: raiseError()
  if cli.readStart(onAlloc, onRead) > 0: raiseError()

proc bindTo* (t: ref Tcp, ip: string, port: int) =
  var addrIn = uv.ip4Addr(ip, port)
  if uv.tcpBind(t, addrIn) > 0: raiseError()

proc bindTo6* (t: ref Tcp, ip: string, port: int) =
  var addrIn = uv.ip6Addr(ip, port)
  if uv.tcpBind6(t, addrIn) > 0: raiseError()

proc listen* (srv: Server, port: int, address: string = "0.0.0.0") =
  if loop.tcpInit(srv) > 0: raiseError()
  if address =~ re(ip6regex): srv.bindTo6(address, port) else: srv.bindTo(address, port)
  if srv.listen(511, onConnect) > 0: raiseError()

proc createServer* (cb: RequestListener): Server =
  Server(callback: cb)

when isMainModule:
  block:
    var s = createServer do (req: Client, res: Server):
      echo "mmm2"
    s.listen(3000)
    echo "Listening on http://localhost:3000"
    if loop.run(RUN_DEFAULT) > 0: raiseError()
