from uv import nil
from posix import TAddrinfo, TSockaddr, TSockaddrIn, TSockaddrIn6

type
  Tcp* = ref object
    data: ref uv.TTcp

  ErrorIO*  = ref object of EIO
  Callback* = proc (t: Tcp)

proc init* (): Tcp =
  result.new
  result.data.new
  var err = uv.tcp_init(uv.default_loop(), result.data)
  uv.check err

proc bind_to* (t: Tcp, ip: string, port: int) =
  var addr_in = uv.ip4_addr(ip, port)
  var err = uv.tcp_bind(t.data, addr_in)
  uv.check err

proc bind_to6* (t: Tcp, ip: string, port: int) =
  var addr_in = uv.ip6_addr(ip, port)
  var err = uv.tcp_bind6(t.data, addr_in)
  uv.check err

proc accept* (t: Tcp) =
  var client = init()
  var err = uv.accept(t.data, client.data)
  uv.check err

template listen* (t: Tcp, backlog: int, cb: Callback) =
  # I'm adding a self reference
  var wrapper = proc (s: ref uv.TStream, status: int) {.cdecl.} =
    uv.check status
    var stream: Tcp
    stream.new
    stream.data = cast[ref uv.TTcp](s)
    accept(stream)
    cb(stream)
  var err = uv.listen(t.data, backlog, wrapper)
  if err > 0:
    var e: ErrorIO
    e.new
    e.msg = $uv.strerror(uv.last_error(uv.default_loop()))
    raise e

when isMainModule:
  var t = init()
  t.bind_to "0.0.0.0", 3000
  t.listen(128) do (resp: Tcp):
    echo "Hello"
  echo ">> Execute in a separate terminal: $ nc 127.0.0.0 3000"
  var err = uv.run(uv.default_loop(), uv.RUN_DEFAULT)
  uv.check err
