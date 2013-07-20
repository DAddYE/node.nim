## Author Davide D'Agostino (@DAddYE)
## mail. info@daddye.it - web. http://daddye.it
## License MIT
##
## This wrapper is built and tested withlibuv 0.11.5
## For libuv license, see libuv license.

when defined(windows):
  import winlean
else:
  from posix import TAddrinfo, TSockaddr, TSockaddrIn, TSockaddrIn6, TMode, TOff, TGid, TStat

const LIBUV =
  when defined(windows): "./dpes/libuv/libuv.dll"
  elif defined(macosx):  "./deps/libuv/libuv.dylib"
  else:                  "./deps/libuv/libuv.so"

type
  TBuf* = object
    base* : cstring
    len* : int

  TFile*    = int
  TOsSock*  = int
  TOnce*    = object
  TThread*  = object
  TMutex*   = object
  TRwlock*  = object
  TSem*     = object
  TCond*    = object

  TBarrier* = object
    n*          : uint8
    count*      : uint8
    mutex*      : TMutex
    turnstile1* : TSem
    turnstile2* : TSem

  TGid* = object
  TUid* = object

  TLib* = object
    handle* : pointer
    errmsg* : cstring

  TIoCb = proc (loop: ref TLoop; w: ref TIo; events: uint8) {.cdecl.}
  TIo = object
    cb            : TIoCb
    pending_queue : array[2, pointer]
    watcher_queue : array[2, pointer]
    pevents       : uint8
    events        : uint8
    fd            : int
    rcount        : int
    wcount        : int

  TPoll* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ref TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : int
    next_closing* : ref THandle
    poll_cb*      : TPollCb
    io_watcher*   : TIo

  TPollEvent* = enum
    READABLE = 1, WRITABLE = 2

  TErrCode* {.size: sizeof(int).} = enum
    UNKNOWN = - 1, OK = 0, EOF = 1, EADDRINFO = 2, EACCES = 3, EAGAIN = 4, EADDRINUSE = 5,
    EADDRNOTAVAIL = 6, EAFNOSUPPORT = 7, EALREADY = 8, EBADF = 9, EBUSY = 10, ECONNABORTED = 11,
    ECONNREFUSED = 12, ECONNRESET = 13, EDESTADDRREQ = 14, EFAULT = 15, EHOSTUNREACH = 16,
    EINTR = 17, EINVAL = 18, EISCONN = 19, EMFILE = 20, EMSGSIZE = 21, ENETDOWN = 22,
    ENETUNREACH = 23, ENFILE = 24, ENOBUFS = 25, ENOMEM = 26, ENOTDIR = 27, EISDIR = 28,
    ENONET = 29, ENOTCONN = 31, ENOTSOCK = 32, ENOTSUP = 33, ENOENT = 34, ENOSYS = 35, EPIPE = 36,
    EPROTO = 37, EPROTONOSUPPORT = 38, EPROTOTYPE = 39, ETIMEDOUT = 40, ECHARSET = 41,
    EAIFAMNOSUPPORT = 42, EAISERVICE = 44, EAISOCKTYPE = 45, ESHUTDOWN = 46, EEXIST = 47,
    ESRCH = 48, ENAMETOOLONG = 49, EPERM = 50, ELOOP = 51, EXDEV = 52, ENOTEMPTY = 53, ENOSPC = 54,
    EIO = 55, EROFS = 56, ENODEV = 57, ESPIPE = 58, ECANCELED = 59, MAX_ERRORS

  THandleType* {.size: sizeof(int).} = enum
    UNKNOWN_HANDLE = 0, ASYNC, UCHECK, FS_EVENT, FS_POLL, HANDLE, IDLE, NAMED_PIPE, POLL, PREPARE,
    PROCESS, STREAM, TCP, TIMER, TTY, UDP, SIGNAL, FILE, HANDLE_TYPE_MAX

  TReqType* {.size: sizeof(int), pure.} = enum
    UNKNOWN_REQ = 0, REQ, CONNECT, WRITE, SHUTDOWN, UDP_SEND, FS, WORK, GETADDRINFO, REQ_TYPE_MAX

  TRunMode* {.size: sizeof(int).} = enum
    RUN_DEFAULT = 0, RUN_ONCE, RUN_NOWAIT

  TShutdown* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    handle*       : ref TStream
    cb*           : TShutdownCb

  TStream* {.inheritable} = object
    close_cb*              : TCloseCb
    data*                  : pointer
    loop*                  : ref TLoop
    ttype*                 : THandleType
    handle_queue*          : array[2, pointer]
    flags*                 : int
    next_closing*          : ref THandle
    write_queue_size*      : int
    alloc_cb*              : TAllocCb
    read_cb*               : TReadCb
    read2_cb*              : TRead2Cb
    connect_req*           : ref TConnect
    shutdown_req*          : ref TShutdown
    io_watcher*            : TIo
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]
    connection_cb*         : TConnectionCb
    delayed_error*         : int
    accepted_fd*           : int
    select*                : pointer

  THandle* {.inheritable.} = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ref TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : int
    next_closing* : ref THandle

  TPipe* = object of TStream
    ipc*        : int
    pipe_fname* : cstring

  TTreeEntry* = object
    rbe_left*   : ref TTimer
    rbe_right*  : ref TTimer
    rbe_parent* : ref TTimer
    rbe_color*  : int

  TTimer* = object of THandle
    tree_entry*   : TTreeEntry
    timer_cb*     : TTimerCb
    timeout*      : uint64
    repeat*       : uint64
    start_id*     : uint64

  TTermios* = object

  TTty* = object of TStream
    orig_termios* : TTermios
    mode*         : int

  TCheck* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ref TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : int
    next_closing* : ref THandle
    check_cb*     : TCheckCb
    queue*        : array[2, pointer]

  TPrepare* = object of THandle
    prepare_cb*   : TPrepareCb
    queue*        : array[2, pointer]

  TIdle* = object of THandle
    idle_cb*      : TIdleCb
    queue*        : array[2, pointer]

  TPAsyncCb = proc (loop: ref TLoop, w: TPAsync, nevents: uint){.cdecl.}
  TPAsync = object
    cb         : TPAsyncCb
    io_watcher : TIo
    wfd        : int

  TAsync* = object of THandle
    async_cb*     : TAsyncCb
    queue*        : array[2, pointer]
    pending*      : int

  TPWork = object
    work : proc (w: ref TPWork)
    done : proc (w: ref TPWork; status: int)
    loop : ref TLoop
    wq   : array[2, pointer]

  TWorkreq* = object
    work* : proc (w: ref TWork) {.cdecl.}
    done* : proc (w: ref TWork; status: int) {.cdecl.}
    loop* : ref TLoop
    wq*   : array[2, pointer]

  TWorkCb* = proc (req: ref TWork) {.cdecl.}
  TWork* = object
    data*          : pointer
    ttype*         : TReqType
    active_queue*  : array[2, pointer]
    loop*          : ref TLoop
    work_cb*       : TWorkCb
    after_work_cb* : TAfterWorkCb
    work_req*      : TWorkreq

  TGetaddrinfoCb* = proc (req: ref TGetaddrinfo; status: int; res: ref TAddrinfo) {.cdecl.}
  TGetaddrinfo* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    loop*         : ref TLoop
    work_req*     : TPWork
    cb*           : TGetaddrinfoCb
    hints*        : ref TAddrinfo
    hostname*     : cstring
    service*      : cstring
    res*          : ref TAddrinfo
    retcode*      : int

  TStdioFlags* {.size: sizeof(int).} = enum
    IGNORE = 0x00000000, CREATE_PIPE = 0x00000001, INHERIT_FD = 0x00000002,
    INHERIT_STREAM = 0x00000004, READABLE_PIPE = 0x00000010, WRITABLE_PIPE = 0x00000020
  TDataU* = object
    stream* : ref TStream
    fd*     : int

  TStdioContainer* = object
    flags* : TStdioFlags
    data*  : TDataU

  TProcessOptions* = object
    exit_cb* : TExitCb
    file*    : cstring
    args*    : cstringArray
    env*     : cstringArray
    cwd*     : cstring
    flags*   : uint8
    uid*     : TUid
    gid*     : TGid

  TProcessFlags* = enum
    PROCESS_SETUID = (1 shl 0), PROCESS_SETGID = (1 shl 1),
    PROCESS_WINDOWS_VERBATIM_ARGUMENTS = (1 shl 2), PROCESS_DETACHED = (1 shl 3),
    PROCESS_WINDOWS_HIDE = (1 shl 4)

  TProcess* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ref TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : int
    next_closing* : ref THandle
    exit_cb*      : TExitCb
    pid*          : int
    queue*        : array[2, pointer]
    errorno*      : int

  TCpuTimes* = object
    user* : uint64
    nice* : uint64
    sys*  : uint64
    idle* : uint64
    irq*  : uint64

  TCpuInfo* = object
    model*     : cstring
    speed*     : int
    cpu_times* : TCpuTimes

  TAddressU* = object
    address4* : TSockaddr_in
    address6* : TSockaddr_in6

  TNetmaskU* = object
    netmask4* : TSockaddr_in
    netmask6* : TSockaddr_in6

  TInterfaceAddress* = object
    name* : cstring
    is_internal* : int
    address* : TAddressU
    netmask* : TNetmaskU

  TFsType* {.size: sizeof(int), pure.} = enum
    FS_UNKNOWN = - 1, FS_CUSTOM, FS_OPEN, FS_CLOSE, FS_READ, FS_WRITE, FS_SENDFILE, FS_STAT,
    FS_LSTAT, FS_FSTAT, FS_FTRUNCATE, FS_UTIME, FS_FUTIME, FS_CHMOD, FS_FCHMOD, FS_FSYNC,
    FS_FDATASYNC, FS_UNLINK, FS_RMDIR, FS_MKDIR, FS_RENAME, FS_READDIR, FS_LINK, FS_SYMLINK,
    FS_READLINK, FS_CHOWN, FS_FCHOWN

  TFs* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    fs_type*      : TFsType
    loop*         : ref TLoop
    cb*           : TFsCb
    result*       : int
    pptr*         : pointer
    path*         : cstring
    errorno*      : TErrCode
    statbuf*      : TStat
    new_path*     : cstring
    file*         : TFile
    flags*        : int
    mode*         : TMode
    buf*          : pointer
    len*          : int
    off*          : TOff
    uid*          : TUid
    gid*          : TGid
    atime*        : cdouble
    mtime*        : cdouble
    work_req*     : TPWork

  EFsEvent* = enum
    RENAME = 1, CHANGE = 2

  TFsEvent* = object of THandle
    filename*       : cstring
    cb*             : TFsEventCb
    event_watcher*  : TIo
    realpath*       : cstring
    realpath_len*   : int
    cf_flags*       : int
    cf_eventstream* : pointer
    cf_cb*          : ref TAsync
    cf_events*      : array[2, pointer]
    cf_sem*         : TSem
    cf_mutex*       : TMutex

  TFsPoll* = object of THandle
    poll_ctx*     : pointer

  TFsEventFlags* = enum
    FS_EVENT_WATCH_ENTRY = 1, FS_EVENT_STAT = 2, FS_EVENT_RECURSIVE = 3

  TSignal* = object of THandle
    signal_cb*          : TSignalCb
    signum*             : int
    tree_entry*         : TTreeEntry
    caught_signals*     : uint8
    dispatched_signals* : uint8

  TAnyHandle* = object
    async*    : TAsync
    check*    : TCheck
    fs_event* : EFsEvent
    fs_poll*  : TFsPoll
    handle*   : THandle
    idle*     : TIdle
    pipe*     : TPipe
    poll*     : TPoll
    prepare*  : TPrepare
    process*  : TProcess
    stream*   : TStream
    tcp*      : TTcp
    timer*    : TTimer
    tty*      : TTty
    udp*      : TUdp
    signal*   : TSignal

  TAnyReq* = object
    req*         : TReq
    connect*     : TConnect
    write*       : TWrite
    shutdown*    : TShutdown
    udp_send*    : TUdpSend
    fs*          : TFs
    work*        : TWork
    getaddrinfo* : TGetaddrinfo

  TTimers* = object
    rbh_root* : ref TTimer

  TLoop* = object
    data*              : pointer
    last_err*          : TErr
    active_handles*    : uint8
    handle_queue*      : array[2, pointer]
    active_reqs*       : array[2, pointer]
    stop_flag*         : uint8
    flags*             : culong
    backend_fd*        : int
    pending_queue*     : array[2, pointer]
    watcher_queue*     : array[2, pointer]
    watchers*          : ref ref TIo
    nwatchers*         : uint8
    nfds*              : uint8
    wq*                : array[2, pointer]
    wq_mutex*          : TMutex
    wq_async*          : TAsync
    closing_handles*   : ref THandle
    process_handles*   : array[2, array[1, pointer]]
    prepare_handles*   : array[2, pointer]
    check_handles*     : array[2, pointer]
    idle_handles*      : array[2, pointer]
    async_handles*     : array[2, pointer]
    async_watcher*     : TPAsync
    timer_handles*     : TTimers
    time*              : uint64
    signal_pipefd*     : array[2, int]
    signal_io_watcher* : TIo
    child_watcher*     : TSignal
    emfile_fd*         : int
    timer_counter*     : uint64
    cf_thread*         : TThread
    cf_cb*             : pointer
    cf_loop*           : pointer
    cf_mutex*          : TMutex
    cf_sem*            : TSem
    cf_signals*        : array[2, pointer]

  TCallback*     = proc () {.cdecl.}
  TEntry*        = proc (arg: pointer) {.cdecl.}
  TAllocCb*      = proc (handle: ref THandle; suggested_size: int): TBuf {.cdecl.}
  TReadCb*       = proc (stream: ref TStream; nread: int; buf: TBuf) {.cdecl.}
  TRead2Cb*      = proc (pipe: ref TPipe; nread: int; buf: TBuf; pending: THandleType) {.cdecl.}
  TWriteCb*      = proc (req: ref TWrite; status: int) {.cdecl.}
  TConnectCb*    = proc (req: ref TConnect; status: int) {.cdecl.}
  TShutdownCb*   = proc (req: ref TShutdown; status: int) {.cdecl.}
  TConnectionCb* = proc (server: ref TStream; status: int) {.cdecl.}
  TCloseCb*      = proc (handle: ref THandle) {.cdecl.}
  TPollCb*       = proc (handle: ref TPoll; status: int; events: int) {.cdecl.}
  TTimerCb*      = proc (handle: ref TTimer; status: int){.cdecl.}
  TAsyncCb*      = proc (handle: ref TAsync; status: int) {.cdecl.}
  TPrepareCb*    = proc (handle: ref TPrepare; status: int) {.cdecl.}
  TCheckCb*      = proc (handle: ref TCheck; status: int) {.cdecl.}
  TIdleCb*       = proc (handle: ref TIdle; status: int) {.cdecl.}
  TExitCb*       = proc (a2: ref TProcess; exit_status: int; term_signal: int) {.cdecl.}
  TWalkCb*       = proc (handle: ref THandle; arg: pointer) {.cdecl.}
  TFsCb*         = proc (req: ref TFs) {.cdecl.}
  TAfterWorkCb*  = proc (req: ref TWork; status: int) {.cdecl.}

  TTimespec* = object
    tv_sec*  : clong
    tv_nsec* : clong

  TFsEventCb* = proc (handle: ref TFsEvent; filename: cstring; events: int; status: int) {.cdecl.}
  TFsPollCb*  = proc (handle: ref TFsPoll; status: int; prev: ref TStat; curr: ref TStat) {.cdecl.}
  TSignalCb*  = proc (handle: ref TSignal; signum: int) {.cdecl.}

  TMembership* {.size: sizeof(int).} = enum
    LEAVE_GROUP = 0, JOIN_GROUP

  TErr* = object
    code*      : TErrCode
    sys_errno* : int

  TReq* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]

  TWrite* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    cb*           : TWriteCb
    send_handle*  : ref TStream
    handle*       : ref TStream
    queue*        : array[2, pointer]
    write_index*  : int
    bufs*         : ref TBuf
    bufcnt*       : int
    error*        : int
    bufsml*       : array[0..4 - 1, TBuf]

  TTcp* = object of TStream

  TConnect* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    cb*           : TConnectCb
    handle*       : ref TStream
    queue*        : array[2, pointer]

  TUdpFlags* = enum
    UDP_IPV6ONLY = 1, UDP_PARTIAL = 2

  TUdpSendCb* = proc (req: ref TUdpSend; status: int) {.cdecl.}
  TUdpRecvCb* = proc (handle: ref TUdp; nread: int; buf: TBuf; adr: ref TSockaddr; flags: uint8) {.cdecl.}

  TUdp* = object of THandle
    alloc_cb*              : TAllocCb
    recv_cb*               : TUdpRecvCb
    io_watcher*            : TIo
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]

  TUdpSend* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    handle*       : ref TUdp
    cb*           : TUdpSendCb
    queue*        : array[2, pointer]
    adr*          : TSockaddr_in6
    bufcnt*       : int
    bufs*         : ref TBuf
    status*       : int
    send_cb*      : TUdpSendCb
    bufsml*       : array[4, TBuf]

{.pragma: libuv, cdecl, dynlib: LIBUV, importc: "uv_$1".}
proc version* (): uint8 {.libuv.}
proc version_string* (): cstring {.libuv.}
proc loop_new* (): ref TLoop {.libuv.}
proc loop_delete* (a2: ref TLoop) {.libuv.}
proc default_loop* (): ref TLoop {.libuv.}
proc run* (a2: ref TLoop; mode: TRunMode): int {.libuv.}
proc stop* (a2: ref TLoop) {.libuv.}
proc href* (a2: ref THandle) {.cdecl, dynlib: LIBUV, importc: "uv_ref".}
proc unref* (a2: ref THandle) {.libuv.}
proc has_ref* (a2: ref THandle): int {.libuv.}
proc update_time* (a2: ref TLoop) {.libuv.}
proc now* (a2: ref TLoop): uint64 {.libuv.}
proc backend_fd* (a2: ref TLoop): int {.libuv.}
proc backend_timeout* (a2: ref TLoop): int {.libuv.}
proc last_error* (a2: ref TLoop): TErr {.libuv.}
proc strerror* (err: TErr): cstring {.libuv.}
proc err_name* (err: TErr): cstring {.libuv.}
proc shutdown* (req: ref TShutdown; handle: ref TStream; cb: TShutdownCb): int {.libuv.}
proc handle_size* (ttype: THandleType): int {.libuv.}
proc req_size* (ttype: TReqType): int {.libuv.}
proc is_active* (handle: ref THandle): int {.libuv.}
proc walk* (loop: ref TLoop; walk_cb: TWalkCb; arg: pointer) {.libuv.}
proc close* (handle: ref THandle; close_cb: TCloseCb) {.libuv.}
proc buf_init* (base: cstring; len: uint8): TBuf {.libuv.}
proc strlcpy* (dst: cstring; src: cstring; size: int): int {.libuv.}
proc strlcat* (dst: cstring; src: cstring; size: int): int {.libuv.}
proc listen* (stream: ref TStream; backlog: int; cb: TConnectionCb): int {.libuv.}
proc accept* (server: ref TStream; client: ref TStream): int {.libuv.}
proc read_start* (a2: ref TStream; alloc_cb: TAllocCb; read_cb: TReadCb): int {.libuv.}
proc read_stop* (a2: ref TStream): int {.libuv.}
proc read2_start* (a2: ref TStream; alloc_cb: TAllocCb; read_cb: TRead2Cb): int {.libuv.}
proc write* (req: ref TWrite; handle: ref TStream; bufs: ref TBuf; bufcnt: int; cb: TWriteCb): int {.libuv.}
proc write2* (req: ref TWrite; handle: ref TStream; bufs: ref TBuf; bufcnt: int; send_handle: ref TStream; cb: TWriteCb): int {.libuv.}
proc is_readable* (handle: ref TStream): int {.libuv.}
proc is_writable* (handle: ref TStream): int {.libuv.}
proc stream_set_blocking* (handle: ref TStream; blocking: int): int {.libuv.}
proc is_closing* (handle: ref THandle): int {.libuv.}
proc tcp_init* (a2: ref TLoop; handle: ref TTcp): int {.libuv.}
proc tcp_open* (handle: ref TTcp; sock: TOsSock): int {.libuv.}
proc tcp_nodelay* (handle: ref TTcp; enable: int): int {.libuv.}
proc tcp_keepalive* (handle: ref TTcp; enable: int; delay: uint8): int {.libuv.}
proc tcp_simultaneous_accepts* (handle: ref TTcp; enable: int): int {.libuv.}
proc tcp_bind* (handle: ref TTcp; a3: TSockaddr_in): int {.libuv.}
proc tcp_bind6* (handle: ref TTcp; a3: TSockaddr_in6): int {.libuv.}
proc tcp_getsockname* (handle: ref TTcp; name: ref TSockaddr; namelen: ref int): int {.libuv.}
proc tcp_getpeername* (handle: ref TTcp; name: ref TSockaddr; namelen: ref int): int {.libuv.}
proc tcp_connect* (req: ref TConnect; handle: ref TTcp; address: TSockaddr_in; cb: TConnectCb): int {.libuv.}
proc tcp_connect6* (req: ref TConnect; handle: ref TTcp; address: TSockaddr_in6; cb: TConnectCb): int {.libuv.}
proc udp_init* (a2: ref TLoop; handle: ref TUdp): int {.libuv.}
proc udp_open* (handle: ref TUdp; sock: TOsSock): int {.libuv.}
proc udp_bind* (handle: ref TUdp; adr: TSockaddr_in; flags: uint8): int {.libuv.}
proc udp_bind6* (handle: ref TUdp; adr: TSockaddr_in6; flags: uint8): int {.libuv.}
proc udp_getsockname* (handle: ref TUdp; name: ref TSockaddr; namelen: ref int): int {.libuv.}
proc udp_set_membership* (handle: ref TUdp; multicast_addr: cstring; interface_addr: cstring; membership: TMembership): int {.libuv.}
proc udp_set_multicast_loop* (handle: ref TUdp; on: int): int {.libuv.}
proc udp_set_multicast_ttl* (handle: ref TUdp; ttl: int): int {.libuv.}
proc udp_set_broadcast* (handle: ref TUdp; on: int): int {.libuv.}
proc udp_set_ttl* (handle: ref TUdp; ttl: int): int {.libuv.}
proc udp_send* (req: ref TUdpSend; handle: ref TUdp; bufs: ref TBuf; bufcnt: int; adr: TSockaddr_in; send_cb: TUdpSendCb): int {.libuv.}
proc udp_send6* (req: ref TUdpSend; handle: ref TUdp; bufs: ref TBuf; bufcnt: int; adr: TSockaddr_in6; send_cb: TUdpSendCb): int {.libuv.}
proc udp_recv_start* (handle: ref TUdp; alloc_cb: TAllocCb; recv_cb: TUdpRecvCb): int {.libuv.}
proc udp_recv_stop* (handle: ref TUdp): int {.libuv.}
proc tty_init* (a2: ref TLoop; a3: ref TTty; fd: TFile; readable: int): int {.libuv.}
proc tty_set_mode* (a2: ref TTty; mode: int): int {.libuv.}
proc tty_reset_mode* () {.libuv.}
proc tty_get_winsize* (a2: ref TTty; width: ref int; height: ref int): int {.libuv.}
proc guess_handle* (file: TFile): THandleType {.libuv.}
proc pipe_init* (a2: ref TLoop; handle: ref TPipe; ipc: int): int {.libuv.}
proc pipe_open* (a2: ref TPipe; file: TFile): int {.libuv.}
proc pipe_bind* (handle: ref TPipe; name: cstring): int {.libuv.}
proc pipe_connect* (req: ref TConnect; handle: ref TPipe; name: cstring; cb: TConnectCb) {.libuv.}
proc pipe_pending_instances* (handle: ref TPipe; count: int) {.libuv.}
proc poll_init* (loop: ref TLoop; handle: ref TPoll; fd: int): int {.libuv.}
proc poll_init_socket* (loop: ref TLoop; handle: ref TPoll; socket: TOsSock): int {.libuv.}
proc poll_start* (handle: ref TPoll; events: int; cb: TPollCb): int {.libuv.}
proc poll_stop* (handle: ref TPoll): int {.libuv.}
proc prepare_init* (a2: ref TLoop; prepare: ref TPrepare): int {.libuv.}
proc prepare_start* (prepare: ref TPrepare; cb: TPrepareCb): int {.libuv.}
proc prepare_stop* (prepare: ref TPrepare): int {.libuv.}
proc check_init* (a2: ref TLoop; check: ref TCheck): int {.libuv.}
proc check_start* (check: ref TCheck; cb: TCheckCb): int {.libuv.}
proc check_stop* (check: ref TCheck): int {.libuv.}
proc idle_init* (a2: ref TLoop; idle: ref TIdle): int {.libuv.}
proc idle_start* (idle: ref TIdle; cb: TIdleCb): int {.libuv.}
proc idle_stop* (idle: ref TIdle): int {.libuv.}
proc async_init* (a2: ref TLoop; async: ref TAsync; async_cb: TAsyncCb): int {.libuv.}
proc async_send* (async: ref TAsync): int {.libuv.}
proc timer_init* (a2: ref TLoop; handle: ref TTimer): int {.libuv.}
proc timer_start* (handle: ref TTimer; cb: TTimerCb; timeout: uint64; repeat: uint64): int {.libuv.}
proc timer_stop* (handle: ref TTimer): int {.libuv.}
proc timer_again* (handle: ref TTimer): int {.libuv.}
proc timer_set_repeat* (handle: ref TTimer; repeat: uint64) {.libuv.}
proc timer_get_repeat* (handle: ref TTimer): uint64 {.libuv.}
proc getaddrinfo* (loop: ref TLoop; req: ref TGetaddrinfo; getaddrinfo_cb: TGetaddrinfoCb; node: cstring; service: cstring; hints: ref TAddrinfo): int {.libuv.}
proc freeaddrinfo* (ai: ref TAddrinfo) {.libuv.}
proc spawn* (a2: ref TLoop; a3: ref TProcess; options: TProcessOptions): int {.libuv.}
proc process_kill* (a2: ref TProcess; signum: int): int {.libuv.}
proc kill* (pid: int; signum: int): TErr {.libuv.}
proc queue_work* (loop: ref TLoop; req: ref TWork; work_cb: TWorkCb; after_work_cb: TAfterWorkCb): int {.libuv.}
proc cancel* (req: ref TReq): int {.libuv.}
proc setup_args* (argc: int; argv: cstringArray): cstringArray {.libuv.}
proc get_process_title* (buffer: cstring; size: int): TErr {.libuv.}
proc set_process_title* (title: cstring): TErr {.libuv.}
proc resident_set_memory* (rss: ref int): TErr {.libuv.}
proc uptime* (uptime: ref cdouble): TErr {.libuv.}
proc cpu_info* (cpu_infos: ref ref TCpuInfo; count: ref int): TErr {.libuv.}
proc free_cpu_info* (cpu_infos: ref TCpuInfo; count: int) {.libuv.}
proc interface_addresses* (addresses: ref ref TInterfaceAddress; count: ref int): TErr {.libuv.}
proc free_interface_addresses* (addresses: ref TInterfaceAddress; count: int) {.libuv.}
proc fs_req_cleanup* (req: ref TFs) {.libuv.}
proc fs_close* (loop: ref TLoop; req: ref TFs; file: TFile; cb: TFsCb): int {.libuv.}
proc fs_open* (loop: ref TLoop; req: ref TFs; path: cstring; flags: int; mode: int; cb: TFsCb): int {.libuv.}
proc fs_read* (loop: ref TLoop; req: ref TFs; file: TFile; buf: pointer; length: int; offset: int64; cb: TFsCb): int {.libuv.}
proc fs_unlink* (loop: ref TLoop; req: ref TFs; path: cstring; cb: TFsCb): int {.libuv.}
proc fs_write* (loop: ref TLoop; req: ref TFs; file: TFile; buf: pointer; length: int; offset: int64; cb: TFsCb): int {.libuv.}
proc fs_mkdir* (loop: ref TLoop; req: ref TFs; path: cstring; mode: int; cb: TFsCb): int {.libuv.}
proc fs_rmdir* (loop: ref TLoop; req: ref TFs; path: cstring; cb: TFsCb): int {.libuv.}
proc fs_readdir* (loop: ref TLoop; req: ref TFs; path: cstring; flags: int; cb: TFsCb): int {.libuv.}
proc fs_stat* (loop: ref TLoop; req: ref TFs; path: cstring; cb: TFsCb): int {.libuv.}
proc fs_fstat* (loop: ref TLoop; req: ref TFs; file: TFile; cb: TFsCb): int {.libuv.}
proc fs_rename* (loop: ref TLoop; req: ref TFs; path: cstring; new_path: cstring; cb: TFsCb): int {.libuv.}
proc fs_fsync* (loop: ref TLoop; req: ref TFs; file: TFile; cb: TFsCb): int {.libuv.}
proc fs_fdatasync* (loop: ref TLoop; req: ref TFs; file: TFile; cb: TFsCb): int {.libuv.}
proc fs_ftruncate* (loop: ref TLoop; req: ref TFs; file: TFile; offset: int64; cb: TFsCb): int {.libuv.}
proc fs_sendfile* (loop: ref TLoop; req: ref TFs; out_fd: TFile; in_fd: TFile; in_offset: int64; length: int; cb: TFsCb): int {.libuv.}
proc fs_chmod* (loop: ref TLoop; req: ref TFs; path: cstring; mode: int; cb: TFsCb): int {.libuv.}
proc fs_utime* (loop: ref TLoop; req: ref TFs; path: cstring; atime: cdouble; mtime: cdouble; cb: TFsCb): int {.libuv.}
proc fs_futime* (loop: ref TLoop; req: ref TFs; file: TFile; atime: cdouble; mtime: cdouble; cb: TFsCb): int {.libuv.}
proc fs_lstat* (loop: ref TLoop; req: ref TFs; path: cstring; cb: TFsCb): int {.libuv.}
proc fs_link* (loop: ref TLoop; req: ref TFs; path: cstring; new_path: cstring; cb: TFsCb): int {.libuv.}
proc fs_symlink* (loop: ref TLoop; req: ref TFs; path: cstring; new_path: cstring; flags: int; cb: TFsCb): int {.libuv.}
proc fs_readlink* (loop: ref TLoop; req: ref TFs; path: cstring; cb: TFsCb): int {.libuv.}
proc fs_fchmod* (loop: ref TLoop; req: ref TFs; file: TFile; mode: int; cb: TFsCb): int {.libuv.}
proc fs_chown* (loop: ref TLoop; req: ref TFs; path: cstring; uid: int; gid: int; cb: TFsCb): int {.libuv.}
proc fs_fchown* (loop: ref TLoop; req: ref TFs; file: TFile; uid: int; gid: int; cb: TFsCb): int {.libuv.}
proc fs_poll_init* (loop: ref TLoop; handle: ref TFsPoll): int {.libuv.}
proc fs_poll_start* (handle: ref TFsPoll; poll_cb: TFsPollCb; path: cstring; interval: uint8): int {.libuv.}
proc fs_poll_stop* (handle: ref TFsPoll): int {.libuv.}
proc signal_init* (loop: ref TLoop; handle: ref TSignal): int {.libuv.}
proc signal_start* (handle: ref TSignal; signal_cb: TSignalCb; signum: int): int {.libuv.}
proc signal_stop* (handle: ref TSignal): int {.libuv.}
proc loadavg* (avg: array[0..3 - 1, cdouble]) {.libuv.}
proc fs_event_init* (loop: ref TLoop; handle: ref TFsEvent; filename: cstring; cb: TFsEventCb; flags: int): int {.libuv.}
proc ip4_addr* (ip: cstring; port: int): TSockaddrIn {.libuv.}
proc ip6_addr* (ip: cstring; port: int): TSockaddrIn6 {.libuv.}
proc ip4_name* (src: ref TSockaddrIn; dst: cstring; size: int): int {.libuv.}
proc ip6_name* (src: ref TSockaddrIn6; dst: cstring; size: int): int {.libuv.}
proc inet_ntop* (af: int; src: pointer; dst: cstring; size: int): TErr {.libuv.}
proc inet_pton* (af: int; src: cstring; dst: pointer): TErr {.libuv.}
proc exepath* (buffer: cstring; size: ref int): int {.libuv.}
proc cwd* (buffer: cstring; size: int): TErr {.libuv.}
proc chdir* (dir: cstring): TErr {.libuv.}
proc get_free_memory* (): uint64 {.libuv.}
proc get_total_memory* (): uint64 {.libuv.}
proc hrtime* (): uint64 {.libuv.}
proc disable_stdio_inheritance* () {.libuv.}
proc dlopen* (filename: cstring; lib: ref TLib): int {.libuv.}
proc dlclose* (lib: ref TLib) {.libuv.}
proc dlsym* (lib: ref TLib; name: cstring; p: ref pointer): int {.libuv.}
proc dlerror* (lib: ref TLib): cstring {.libuv.}
proc mutex_init* (handle: ref TMutex): int {.libuv.}
proc mutex_destroy* (handle: ref TMutex) {.libuv.}
proc mutex_lock* (handle: ref TMutex) {.libuv.}
proc mutex_trylock* (handle: ref TMutex): int {.libuv.}
proc mutex_unlock* (handle: ref TMutex) {.libuv.}
proc rwlock_init* (rwlock: ref TRwlock): int {.libuv.}
proc rwlock_destroy* (rwlock: ref TRwlock) {.libuv.}
proc rwlock_rdlock* (rwlock: ref TRwlock) {.libuv.}
proc rwlock_tryrdlock* (rwlock: ref TRwlock): int {.libuv.}
proc rwlock_rdunlock* (rwlock: ref TRwlock) {.libuv.}
proc rwlock_wrlock* (rwlock: ref TRwlock) {.libuv.}
proc rwlock_trywrlock* (rwlock: ref TRwlock): int {.libuv.}
proc rwlock_wrunlock* (rwlock: ref TRwlock) {.libuv.}
proc sem_init* (sem: ref TSem; value: uint8): int {.libuv.}
proc sem_destroy* (sem: ref TSem) {.libuv.}
proc sem_post* (sem: ref TSem) {.libuv.}
proc sem_wait* (sem: ref TSem) {.libuv.}
proc sem_trywait* (sem: ref TSem): int {.libuv.}
proc cond_init* (cond: ref TCond): int {.libuv.}
proc cond_destroy* (cond: ref TCond) {.libuv.}
proc cond_signal* (cond: ref TCond) {.libuv.}
proc cond_broadcast* (cond: ref TCond) {.libuv.}
proc cond_wait* (cond: ref TCond; mutex: ref TMutex) {.libuv.}
proc cond_timedwait* (cond: ref TCond; mutex: ref TMutex; timeout: uint64): int {.libuv.}
proc barrier_init* (barrier: ref TBarrier; count: uint8): int {.libuv.}
proc barrier_destroy* (barrier: ref TBarrier) {.libuv.}
proc barrier_wait* (barrier: ref TBarrier) {.libuv.}
proc once* (guard: ref TOnce; callback: TCallback) {.libuv.}
proc thread_create* (tid: ref TThread; entry: TEntry; arg: pointer): int {.libuv.}
proc thread_self* (): culong {.libuv.}
proc thread_join* (tid: ref TThread): int {.libuv.}

proc check* (err: int) =
  assert err == 0, "Response was: " & $TErrCode(err)

when isMainModule:
  # Raw test:
  {.pragma: libuv_raw, cdecl, dynlib: LIBUV, importc.}
  proc uv_default_loop(): pointer {.libuv_raw.}
  proc uv_run(loop: pointer; mode: TRunMode): int {.libuv_raw.}
  proc uv_timer_init(a2: pointer; handle: pointer): int {.libuv_raw.}
  proc uv_timer_start(timer: pointer; cb: proc (h: ref TTimer, status: int){.cdecl.}; timeout: int64; repeat: int64): int {.libuv_raw.}
  var h = handle_size(TIMER).alloc
  proc test_timer(handle: ref TTimer; status: int) {.cdecl.} =
    echo "Hello World"
  check uv_timer_init(uv_default_loop(), h)
  check uv_timer_start(h, test_timer, 2000, 0)
  check uv_run(uv_default_loop(), RUN_DEFAULT)
