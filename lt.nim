{.link: "./deps/lthread/liblthread.a".}

from posix import TSockaddr, TSocklen, TMsghdr, TIOVec, TOff, sleep

type
  Sockaddr = TSockaddr
  SockLen = TSocklen
  Msghdr = TMsghdr
  IOVec = TIOVec
  Off = TOff

  LThread*     = object
  LThreadCond* = object
  LThreadFunc* = proc (a2: pointer){.cdecl.}

{.push header: "../deps/lthread/src/lthread.h", importc.}
proc lthread_summary* (): cstring
proc lthread_create* (new_lt: var ptr LThread, a3: LThreadFunc, arg: pointer): cint
proc lthread_cancel* (lt: ptr LThread)
proc lthread_run* ()
proc lthread_join* (lt: ptr LThread, p: ref pointer, timeout: uint64): cint
proc lthread_detach* ()
proc lthread_sleep* (msecs: uint64)
proc lthread_wakeup* (lt: ref LThread)
proc lthread_cond_create* (c: ref ref LThreadCond): cint
proc lthread_cond_wait* (c: ref LThreadCond, timeout: uint64): cint
proc lthread_cond_signal* (c: ref LThreadCond)
proc lthread_cond_broadcast* (c: ref LThreadCond)
proc lthread_init* (size: int): cint
proc lthread_get_data* (): pointer
proc lthread_set_data* (data: pointer)
proc lthread_current* (): ptr LThread

# socket related functions
proc lthread_socket* (a2: cint, a3: cint, a4: cint): cint
proc lthread_pipe* (fildes: array[0..2 - 1, cint]): cint
proc lthread_accept* (fd: cint, a3: ref Sockaddr, a4: ref Socklen): cint
proc lthread_close* (fd: cint): cint
proc lthread_set_funcname* (f: cstring)
proc lthread_id* (): uint64
proc lthread_connect* (fd: cint, a3: ref Sockaddr, a4: Socklen, timeout: uint64): cint
proc lthread_recv* (fd: cint, buf: pointer, buf_len: int, flags: cint, timeout: uint64): int
proc lthread_read* (fd: cint, buf: pointer, length: int, timeout: uint64): int
proc lthread_readline* (fd: cint, buf: cstringArray, max: int, timeout: uint64): int
proc lthread_recv_exact* (fd: cint, buf: pointer, buf_len: int, flags: cint, timeout: uint64): int
proc lthread_read_exact* (fd: cint, buf: pointer, length: int, timeout: uint64): int
proc lthread_recvmsg* (fd: cint, message: ref Msghdr, flags: cint, timeout: uint64): int
proc lthread_recvfrom* (fd: cint, buf: pointer, length: int, flags: cint, address: ref Sockaddr, address_len: ref Socklen, timeout: uint64): int
proc lthread_send* (fd: cint, buf: pointer, buf_len: int, flags: cint): int
proc lthread_write* (fd: cint, buf: pointer, buf_len: int): int
proc lthread_sendmsg* (fd: cint, message: ref Msghdr, flags: cint): int
proc lthread_sendto* (fd: cint, buf: pointer, length: int, flags: cint, dest_addr: ref Sockaddr, dest_len: Socklen): int
proc lthread_writev* (fd: cint, iov: ref IOVec, iovcnt: cint): int
# when defined(freeBSD):
#   proc lthread_sendfile* (fd: cint, s: cint, offset: Off, nbytes: int, hdtr: ref sf_hdtr): cint
proc lthread_io_write* (fd: cint, buf: pointer, nbytes: int): int
proc lthread_io_read* (fd: cint, buf: pointer, nbytes: int): int
proc lthread_compute_begin* (): cint
proc lthread_compute_end* ()
{.pop.}

when isMainModule:
  import pure/times
  block:
    proc printf(formatstr: cstring) {.importc: "printf", varargs, header: "<stdio.h>".}
    proc a (x: pointer){.cdecl.} =
      echo "I am in a"
      lthread_detach()
      for i in 1..3:
        var t1 = getTime()
        lthread_sleep(2000)
        var t2 = getTime()
        printf("a (%d): elapsed is: %ld\n", i, t2 - t1)
      echo "a is exiting"

    proc b (x: pointer){.cdecl.} =
      echo "I am in b"
      lthread_detach()
      for i in 1..8:
        var t1 = getTime()
        lthread_sleep(1000)
        var t2 = getTime()
        printf("b (%d): elapsed is: %ld\n", i, t2 - t1)
      echo "b is exiting"

    proc c (x: pointer){.cdecl.} =
      echo "c is running"
      discard lthread_compute_begin()
      discard sleep(8)
      lthread_compute_end()
      echo "c is exiting"

    proc d (x: pointer){.cdecl.} =
      var lt_new: ptr LThread
      lthread_detach()
      echo "d is running"
      echo lthread_create(lt_new, c, nil)
      echo lthread_join(lt_new, nil, 0)
      echo "d is done joining on c."

    var t: ptr LThread
    discard lthread_create(t, a, nil)
    discard lthread_create(t, b, nil)
    discard lthread_create(t, d, nil)
    lthread_run()
