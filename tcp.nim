from uv import nil
from posix import TAddrinfo, TSockaddr, TSockaddrIn, TSockaddrIn6

type
  Handle* {.inheritable.} = object
    native*: ref uv.TTcp
  ErrorIO*  = object of EIO
  Callback* = proc (t: ref Handle)

proc init* (): ref Handle =
  result.new
  result.native.new
  var err = uv.tcp_init(uv.default_loop(), result.native)
  uv.check err

proc bind_to* (t: ref uv.TTcp, ip: string, port: int) =
  var addr_in = uv.ip4_addr(ip, port)
  var err = uv.tcp_bind(t, addr_in)
  uv.check err

proc bind_to6* (t: ref uv.TTcp, ip: string, port: int) =
  var addr_in = uv.ip6_addr(ip, port)
  var err = uv.tcp_bind6(t, addr_in)
  uv.check err

proc accept* (t: ref Handle) =
  var client = init()
  var err = uv.accept(t.native, client.native)
  uv.check err

proc raise_error* () =
  var e = ErrorIO.new
  e.msg = $uv.strerror(uv.last_error(uv.default_loop()))
  raise e

template listen* (t: ref Handle, backlog: int, cb: Callback) =
  # I'm adding a self reference
  var wrapper = proc (s: ref uv.TStream, status: int) {.cdecl.} =
    uv.check status
    var stream = Handle.new
    stream.native = cast[ref uv.TTcp](s)
    stream.accept()
    cb(stream)
  var err = uv.listen(t.native, backlog, wrapper)
  if err > 0: raise_error

when isMainModule:
  var t = init()
  t.bind_to "0.0.0.0", 3000
  t.listen(128) do (resp: ref Handle):
    echo "Hello"
  echo ">> Execute in a separate terminal: $ nc 127.0.0.0 3000"
  var err = uv.run(uv.default_loop(), uv.RUN_DEFAULT)
  uv.check err
