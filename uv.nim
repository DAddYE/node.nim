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
  AddrInfo    = TAddrinfo
  Sockaddr    = TSockaddr
  SockaddrIn  = TSockaddrIn
  SockaddrIn6 = TSockaddrIn6
  Mode = TMode
  Off  = TOff
  Stat = TStat

  Buf* = object
    base* : cstring
    len* : int

  File*    = int
  OsSock*  = int
  Once*    = object
  Thread*  = object
  Mutex*   = object
  Rwlock*  = object
  Sem*     = object
  Cond*    = object

  Barrier* = object
    n*          : uint8
    count*      : uint8
    mutex*      : Mutex
    turnstile1* : Sem
    turnstile2* : Sem

  Gid* = object
  Uid* = object

  Lib* = object
    handle* : pointer
    errmsg* : cstring

  IoCb = proc (loop: ref Loop; w: ref Io; events: uint8) {.cdecl.}
  Io = object
    cb            : IoCb
    pending_queue : array[2, pointer]
    watcher_queue : array[2, pointer]
    pevents       : uint8
    events        : uint8
    fd            : int
    rcount        : int
    wcount        : int

  Poll* = object
    close_cb*     : CloseCb
    data*         : pointer
    loop*         : ref Loop
    ttype*        : HandleType
    handle_queue* : array[2, pointer]
    flags*        : int
    next_closing* : ref Handle
    poll_cb*      : PollCb
    io_watcher*   : Io

  PollEvent* {.pure.} = enum
    READABLE = 1, WRITABLE = 2

  ErrCode* = enum
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

  HandleType* {.pure.} = enum
    UNKNOWN_HANDLE = 0, ASYNC, UCHECK, FS_EVENT, FS_POLL, HANDLE, IDLE, NAMED_PIPE, POLL, PREPARE,
    PROCESS, STREAM, TCP, TIMER, TTY, UDP, SIGNAL, FILE, HANDLE_TYPE_MAX

  ReqType* {.pure.} = enum
    UNKNOWN_REQ = 0, REQ, CONNECT, WRITE, SHUTDOWN, UDP_SEND, FS, WORK, GETADDRINFO, REQ_TYPE_MAX

  RunMode*  = enum
    RUN_DEFAULT = 0, RUN_ONCE, RUN_NOWAIT

  Shutdown* = object
    data*         : pointer
    ttype*        : ReqType
    active_queue* : array[2, pointer]
    handle*       : ref Stream
    cb*           : ShutdownCb


  Handle* {.inheritable.} = object
    close_cb*     : CloseCb
    data*         : pointer
    loop*         : ref Loop
    ttype*        : HandleType
    handle_queue* : array[2, pointer]
    flags*        : int
    next_closing* : ref Handle


  Stream* {.inheritable} = object of Handle
    write_queue_size*      : int
    alloc_cb*              : AllocCb
    read_cb*               : ReadCb
    read2_cb*              : Read2Cb
    connect_req*           : ref Connect
    shutdown_req*          : ref Shutdown
    io_watcher*            : Io
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]
    connection_cb*         : ConnectionCb
    delayed_error*         : int
    accepted_fd*           : int
    select*                : pointer

  Pipe* = object of Stream
    ipc*        : int
    pipe_fname* : cstring

  TreeEntry* = object
    rbe_left*   : ref Timer
    rbe_right*  : ref Timer
    rbe_parent* : ref Timer
    rbe_color*  : int

  Timer* = object of Handle
    tree_entry*   : TreeEntry
    timer_cb*     : TimerCb
    timeout*      : uint64
    repeat*       : uint64
    start_id*     : uint64

  Termios* = object

  Tty* = object of Stream
    orig_termios* : Termios
    mode*         : int

  Check* = object
    close_cb*     : CloseCb
    data*         : pointer
    loop*         : ref Loop
    ttype*        : HandleType
    handle_queue* : array[2, pointer]
    flags*        : int
    next_closing* : ref Handle
    check_cb*     : CheckCb
    queue*        : array[2, pointer]

  Prepare* = object of Handle
    prepare_cb*   : PrepareCb
    queue*        : array[2, pointer]

  Idle* = object of Handle
    idle_cb*      : IdleCb
    queue*        : array[2, pointer]

  PAsyncCb = proc (loop: ref Loop, w: PAsync, nevents: uint){.cdecl.}
  PAsync = object
    cb         : PAsyncCb
    io_watcher : Io
    wfd        : int

  Async* = object of Handle
    async_cb*     : AsyncCb
    queue*        : array[2, pointer]
    pending*      : int

  PWork = object
    work : proc (w: ref PWork)
    done : proc (w: ref PWork; status: int)
    loop : ref Loop
    wq   : array[2, pointer]

  Workreq* = object
    work* : proc (w: ref Work) {.cdecl.}
    done* : proc (w: ref Work; status: int) {.cdecl.}
    loop* : ref Loop
    wq*   : array[2, pointer]

  WorkCb* = proc (req: ref Work) {.cdecl.}
  Work* = object
    data*          : pointer
    ttype*         : ReqType
    active_queue*  : array[2, pointer]
    loop*          : ref Loop
    work_cb*       : WorkCb
    after_work_cb* : AfterWorkCb
    work_req*      : Workreq

  GetaddrinfoCb* = proc (req: ref Getaddrinfo; status: int; res: ref Addrinfo) {.cdecl.}
  Getaddrinfo* = object
    data*         : pointer
    ttype*        : ReqType
    active_queue* : array[2, pointer]
    loop*         : ref Loop
    work_req*     : PWork
    cb*           : GetaddrinfoCb
    hints*        : ref Addrinfo
    hostname*     : cstring
    service*      : cstring
    res*          : ref Addrinfo
    retcode*      : int

  StdioFlags*  = enum
    IGNORE = 0x00000000, CREATE_PIPE = 0x00000001, INHERIT_FD = 0x00000002,
    INHERIT_STREAM = 0x00000004, READABLE_PIPE = 0x00000010, WRITABLE_PIPE = 0x00000020
  DataU* = object
    stream* : ref Stream
    fd*     : int

  StdioContainer* = object
    flags* : StdioFlags
    data*  : DataU

  ProcessOptions* = object
    exit_cb* : ExitCb
    file*    : cstring
    args*    : cstringArray
    env*     : cstringArray
    cwd*     : cstring
    flags*   : uint8
    uid*     : Uid
    gid*     : Gid

  ProcessFlags* = enum
    PROCESS_SETUID = (1 shl 0), PROCESS_SETGID = (1 shl 1),
    PROCESS_WINDOWS_VERBATIM_ARGUMENTS = (1 shl 2), PROCESS_DETACHED = (1 shl 3),
    PROCESS_WINDOWS_HIDE = (1 shl 4)

  Process* = object
    close_cb*     : CloseCb
    data*         : pointer
    loop*         : ref Loop
    ttype*        : HandleType
    handle_queue* : array[2, pointer]
    flags*        : int
    next_closing* : ref Handle
    exit_cb*      : ExitCb
    pid*          : int
    queue*        : array[2, pointer]
    errorno*      : int

  CpuTimes* = object
    user* : uint64
    nice* : uint64
    sys*  : uint64
    idle* : uint64
    irq*  : uint64

  CpuInfo* = object
    model*     : cstring
    speed*     : int
    cpu_times* : CpuTimes

  AddressU* = object
    address4* : Sockaddr_in
    address6* : Sockaddr_in6

  NetmaskU* = object
    netmask4* : Sockaddr_in
    netmask6* : Sockaddr_in6

  InterfaceAddress* = object
    name* : cstring
    is_internal* : int
    address* : AddressU
    netmask* : NetmaskU

  FsType* {.pure.} = enum
    FS_UNKNOWN = - 1, FS_CUSTOM, FS_OPEN, FS_CLOSE, FS_READ, FS_WRITE, FS_SENDFILE, FS_STAT,
    FS_LSTAT, FS_FSTAT, FS_FTRUNCATE, FS_UTIME, FS_FUTIME, FS_CHMOD, FS_FCHMOD, FS_FSYNC,
    FS_FDATASYNC, FS_UNLINK, FS_RMDIR, FS_MKDIR, FS_RENAME, FS_READDIR, FS_LINK, FS_SYMLINK,
    FS_READLINK, FS_CHOWN, FS_FCHOWN

  Fs* = object
    data*         : pointer
    ttype*        : ReqType
    active_queue* : array[2, pointer]
    fs_type*      : FsType
    loop*         : ref Loop
    cb*           : FsCb
    result*       : int
    pptr*         : pointer
    path*         : cstring
    errorno*      : ErrCode
    statbuf*      : Stat
    new_path*     : cstring
    file*         : File
    flags*        : int
    mode*         : Mode
    buf*          : pointer
    len*          : int
    off*          : Off
    uid*          : Uid
    gid*          : Gid
    atime*        : cdouble
    mtime*        : cdouble
    work_req*     : PWork

  EFsEvent* = enum
    RENAME = 1, CHANGE = 2

  FsEvent* = object of Handle
    filename*       : cstring
    cb*             : FsEventCb
    event_watcher*  : Io
    realpath*       : cstring
    realpath_len*   : int
    cf_flags*       : int
    cf_eventstream* : pointer
    cf_cb*          : ref Async
    cf_events*      : array[2, pointer]
    cf_sem*         : Sem
    cf_mutex*       : Mutex

  FsPoll* = object of Handle
    poll_ctx*     : pointer

  FsEventFlags* = enum
    FS_EVENT_WATCH_ENTRY = 1, FS_EVENT_STAT = 2, FS_EVENT_RECURSIVE = 3

  Signal* = object of Handle
    signal_cb*          : SignalCb
    signum*             : int
    tree_entry*         : TreeEntry
    caught_signals*     : uint8
    dispatched_signals* : uint8

  AnyHandle* = object
    async*    : Async
    check*    : Check
    fs_event* : EFsEvent
    fs_poll*  : FsPoll
    handle*   : Handle
    idle*     : Idle
    pipe*     : Pipe
    poll*     : Poll
    prepare*  : Prepare
    process*  : Process
    stream*   : Stream
    tcp*      : Tcp
    timer*    : Timer
    tty*      : Tty
    udp*      : Udp
    signal*   : Signal

  AnyReq* = object
    req*         : Req
    connect*     : Connect
    write*       : Write
    shutdown*    : Shutdown
    udp_send*    : UdpSend
    fs*          : Fs
    work*        : Work
    getaddrinfo* : Getaddrinfo

  Timers* = object
    rbh_root* : ref Timer

  Loop* = object
    data*              : pointer
    last_err*          : Err
    active_handles*    : uint8
    handle_queue*      : array[2, pointer]
    active_reqs*       : array[2, pointer]
    stop_flag*         : uint8
    flags*             : culong
    backend_fd*        : int
    pending_queue*     : array[2, pointer]
    watcher_queue*     : array[2, pointer]
    watchers*          : ref ref Io
    nwatchers*         : uint8
    nfds*              : uint8
    wq*                : array[2, pointer]
    wq_mutex*          : Mutex
    wq_async*          : Async
    closing_handles*   : ref Handle
    process_handles*   : array[2, array[1, pointer]]
    prepare_handles*   : array[2, pointer]
    check_handles*     : array[2, pointer]
    idle_handles*      : array[2, pointer]
    async_handles*     : array[2, pointer]
    async_watcher*     : PAsync
    timer_handles*     : Timers
    time*              : uint64
    signal_pipefd*     : array[2, int]
    signal_io_watcher* : Io
    child_watcher*     : Signal
    emfile_fd*         : int
    timer_counter*     : uint64
    cf_thread*         : Thread
    cf_cb*             : pointer
    cf_loop*           : pointer
    cf_mutex*          : Mutex
    cf_sem*            : Sem
    cf_signals*        : array[2, pointer]

  Callback*     = proc () {.cdecl.}
  Entry*        = proc (arg: pointer) {.cdecl.}
  AllocCb*      = proc (handle: ref Handle; suggested_size: int): Buf {.cdecl.}
  ReadCb*       = proc (stream: ref Stream; nread: int; buf: Buf) {.cdecl.}
  Read2Cb*      = proc (pipe: ref Pipe; nread: int; buf: Buf; pending: HandleType) {.cdecl.}
  WriteCb*      = proc (req: ref Write; status: int) {.cdecl.}
  ConnectCb*    = proc (req: ref Connect; status: int) {.cdecl.}
  ShutdownCb*   = proc (req: ref Shutdown; status: int) {.cdecl.}
  ConnectionCb* = proc (server: ref Stream; status: int) {.cdecl.}
  CloseCb*      = proc (handle: ref Handle) {.cdecl.}
  PollCb*       = proc (handle: ref Poll; status: int; events: int) {.cdecl.}
  TimerCb*      = proc (handle: ref Timer; status: int){.cdecl.}
  AsyncCb*      = proc (handle: ref Async; status: int) {.cdecl.}
  PrepareCb*    = proc (handle: ref Prepare; status: int) {.cdecl.}
  CheckCb*      = proc (handle: ref Check; status: int) {.cdecl.}
  IdleCb*       = proc (handle: ref Idle; status: int) {.cdecl.}
  ExitCb*       = proc (a2: ref Process; exit_status: int; term_signal: int) {.cdecl.}
  WalkCb*       = proc (handle: ref Handle; arg: pointer) {.cdecl.}
  FsCb*         = proc (req: ref Fs) {.cdecl.}
  AfterWorkCb*  = proc (req: ref Work; status: int) {.cdecl.}

  Timespec* = object
    tv_sec*  : clong
    tv_nsec* : clong

  FsEventCb* = proc (handle: ref FsEvent; filename: cstring; events: int; status: int) {.cdecl.}
  FsPollCb*  = proc (handle: ref FsPoll; status: int; prev: ref Stat; curr: ref Stat) {.cdecl.}
  SignalCb*  = proc (handle: ref Signal; signum: int) {.cdecl.}

  Membership* = enum
    LEAVE_GROUP = 0, JOIN_GROUP

  Err* = object
    code*      : ErrCode
    sys_errno* : int

  Req* = object
    data*         : pointer
    ttype*        : ReqType
    active_queue* : array[2, pointer]

  Write* = object
    data*         : pointer
    ttype*        : ReqType
    active_queue* : array[2, pointer]
    cb*           : WriteCb
    send_handle*  : ref Stream
    handle*       : ref Stream
    queue*        : array[2, pointer]
    write_index*  : int
    bufs*         : ref Buf
    bufcnt*       : int
    error*        : int
    bufsml*       : array[0..4 - 1, Buf]

  Tcp* = object of Stream

  Connect* = object
    data*         : pointer
    ttype*        : ReqType
    active_queue* : array[2, pointer]
    cb*           : ConnectCb
    handle*       : ref Stream
    queue*        : array[2, pointer]

  UdpFlags* = enum
    UDP_IPV6ONLY = 1, UDP_PARTIAL = 2

  UdpSendCb* = proc (req: ref UdpSend; status: int) {.cdecl.}
  UdpRecvCb* = proc (handle: ref Udp; nread: int; buf: Buf; adr: ref Sockaddr; flags: uint8) {.cdecl.}

  Udp* = object of Handle
    alloc_cb*              : AllocCb
    recv_cb*               : UdpRecvCb
    io_watcher*            : Io
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]

  UdpSend* = object
    data*         : pointer
    ttype*        : ReqType
    active_queue* : array[2, pointer]
    handle*       : ref Udp
    cb*           : UdpSendCb
    queue*        : array[2, pointer]
    adr*          : Sockaddr_in6
    bufcnt*       : int
    bufs*         : ref Buf
    status*       : int
    send_cb*      : UdpSendCb
    bufsml*       : array[4, Buf]

{.pragma: libuv, cdecl, dynlib: LIBUV, importc: "uv_$1".}
proc version* (): uint8 {.libuv.}
proc version_string* (): cstring {.libuv.}
proc loop_new* (): ref Loop {.libuv.}
proc loop_delete* (a2: ref Loop) {.libuv.}
proc default_loop* (): ref Loop {.libuv.}
proc run* (a2: ref Loop; mode: RunMode): int {.libuv.}
proc stop* (a2: ref Loop) {.libuv.}
proc href* (a2: ref Handle) {.cdecl, dynlib: LIBUV, importc: "uv_ref".}
proc unref* (a2: ref Handle) {.libuv.}
proc has_ref* (a2: ref Handle): int {.libuv.}
proc update_time* (a2: ref Loop) {.libuv.}
proc now* (a2: ref Loop): uint64 {.libuv.}
proc backend_fd* (a2: ref Loop): int {.libuv.}
proc backend_timeout* (a2: ref Loop): int {.libuv.}
proc last_error* (a2: ref Loop): Err {.libuv.}
proc strerror* (err: Err): cstring {.libuv.}
proc err_name* (err: Err): cstring {.libuv.}
proc shutdown* (req: ref Shutdown; handle: ref Stream; cb: ShutdownCb): int {.libuv.}
proc handle_size* (ttype: HandleType): int {.libuv.}
proc req_size* (ttype: ReqType): int {.libuv.}
proc is_active* (handle: ref Handle): int {.libuv.}
proc walk* (loop: ref Loop; walk_cb: WalkCb; arg: pointer) {.libuv.}
proc close* (handle: ref Handle; close_cb: CloseCb) {.libuv.}
proc buf_init* (base: cstring; len: uint): Buf {.libuv.}
proc strlcpy* (dst: cstring; src: cstring; size: int): int {.libuv.}
proc strlcat* (dst: cstring; src: cstring; size: int): int {.libuv.}
proc listen* (stream: ref Stream; backlog: int; cb: ConnectionCb): int {.libuv.}
proc accept* (server: ref Stream; client: ref Stream): int {.libuv.}
proc read_start* (a2: ref Stream; alloc_cb: AllocCb; read_cb: ReadCb): int {.libuv.}
proc read_stop* (a2: ref Stream): int {.libuv.}
proc read2_start* (a2: ref Stream; alloc_cb: AllocCb; read_cb: Read2Cb): int {.libuv.}
proc write* (req: ref Write; handle: ref Stream; bufs: ref Buf; bufcnt: int; cb: WriteCb): int {.libuv.}
proc write2* (req: ref Write; handle: ref Stream; bufs: ref Buf; bufcnt: int; send_handle: ref Stream; cb: WriteCb): int {.libuv.}
proc is_readable* (handle: ref Stream): int {.libuv.}
proc is_writable* (handle: ref Stream): int {.libuv.}
proc stream_set_blocking* (handle: ref Stream; blocking: int): int {.libuv.}
proc is_closing* (handle: ref Handle): int {.libuv.}
proc tcp_init* (a2: ref Loop; handle: ref Tcp): int {.libuv.}
proc tcp_open* (handle: ref Tcp; sock: OsSock): int {.libuv.}
proc tcp_nodelay* (handle: ref Tcp; enable: int): int {.libuv.}
proc tcp_keepalive* (handle: ref Tcp; enable: int; delay: uint8): int {.libuv.}
proc tcp_simultaneous_accepts* (handle: ref Tcp; enable: int): int {.libuv.}
proc tcp_bind* (handle: ref Tcp; a3: Sockaddr_in): int {.libuv.}
proc tcp_bind6* (handle: ref Tcp; a3: Sockaddr_in6): int {.libuv.}
proc tcp_getsockname* (handle: ref Tcp; name: ref Sockaddr; namelen: ref int): int {.libuv.}
proc tcp_getpeername* (handle: ref Tcp; name: ref Sockaddr; namelen: ref int): int {.libuv.}
proc tcp_connect* (req: ref Connect; handle: ref Tcp; address: Sockaddr_in; cb: ConnectCb): int {.libuv.}
proc tcp_connect6* (req: ref Connect; handle: ref Tcp; address: Sockaddr_in6; cb: ConnectCb): int {.libuv.}
proc udp_init* (a2: ref Loop; handle: ref Udp): int {.libuv.}
proc udp_open* (handle: ref Udp; sock: OsSock): int {.libuv.}
proc udp_bind* (handle: ref Udp; adr: Sockaddr_in; flags: uint8): int {.libuv.}
proc udp_bind6* (handle: ref Udp; adr: Sockaddr_in6; flags: uint8): int {.libuv.}
proc udp_getsockname* (handle: ref Udp; name: ref Sockaddr; namelen: ref int): int {.libuv.}
proc udp_set_membership* (handle: ref Udp; multicast_addr: cstring; interface_addr: cstring; membership: Membership): int {.libuv.}
proc udp_set_multicast_loop* (handle: ref Udp; on: int): int {.libuv.}
proc udp_set_multicast_ttl* (handle: ref Udp; ttl: int): int {.libuv.}
proc udp_set_broadcast* (handle: ref Udp; on: int): int {.libuv.}
proc udp_set_ttl* (handle: ref Udp; ttl: int): int {.libuv.}
proc udp_send* (req: ref UdpSend; handle: ref Udp; bufs: ref Buf; bufcnt: int; adr: Sockaddr_in; send_cb: UdpSendCb): int {.libuv.}
proc udp_send6* (req: ref UdpSend; handle: ref Udp; bufs: ref Buf; bufcnt: int; adr: Sockaddr_in6; send_cb: UdpSendCb): int {.libuv.}
proc udp_recv_start* (handle: ref Udp; alloc_cb: AllocCb; recv_cb: UdpRecvCb): int {.libuv.}
proc udp_recv_stop* (handle: ref Udp): int {.libuv.}
proc tty_init* (a2: ref Loop; a3: ref Tty; fd: File; readable: int): int {.libuv.}
proc tty_set_mode* (a2: ref Tty; mode: int): int {.libuv.}
proc tty_reset_mode* () {.libuv.}
proc tty_get_winsize* (a2: ref Tty; width: ref int; height: ref int): int {.libuv.}
proc guess_handle* (file: File): HandleType {.libuv.}
proc pipe_init* (a2: ref Loop; handle: ref Pipe; ipc: int): int {.libuv.}
proc pipe_open* (a2: ref Pipe; file: File): int {.libuv.}
proc pipe_bind* (handle: ref Pipe; name: cstring): int {.libuv.}
proc pipe_connect* (req: ref Connect; handle: ref Pipe; name: cstring; cb: ConnectCb) {.libuv.}
proc pipe_pending_instances* (handle: ref Pipe; count: int) {.libuv.}
proc poll_init* (loop: ref Loop; handle: ref Poll; fd: int): int {.libuv.}
proc poll_init_socket* (loop: ref Loop; handle: ref Poll; socket: OsSock): int {.libuv.}
proc poll_start* (handle: ref Poll; events: int; cb: PollCb): int {.libuv.}
proc poll_stop* (handle: ref Poll): int {.libuv.}
proc prepare_init* (a2: ref Loop; prepare: ref Prepare): int {.libuv.}
proc prepare_start* (prepare: ref Prepare; cb: PrepareCb): int {.libuv.}
proc prepare_stop* (prepare: ref Prepare): int {.libuv.}
proc check_init* (a2: ref Loop; check: ref Check): int {.libuv.}
proc check_start* (check: ref Check; cb: CheckCb): int {.libuv.}
proc check_stop* (check: ref Check): int {.libuv.}
proc idle_init* (a2: ref Loop; idle: ref Idle): int {.libuv.}
proc idle_start* (idle: ref Idle; cb: IdleCb): int {.libuv.}
proc idle_stop* (idle: ref Idle): int {.libuv.}
proc async_init* (a2: ref Loop; async: ref Async; async_cb: AsyncCb): int {.libuv.}
proc async_send* (async: ref Async): int {.libuv.}
proc timer_init* (a2: ref Loop; handle: ref Timer): int {.libuv.}
proc timer_start* (handle: ref Timer; cb: TimerCb; timeout: uint64; repeat: uint64): int {.libuv.}
proc timer_stop* (handle: ref Timer): int {.libuv.}
proc timer_again* (handle: ref Timer): int {.libuv.}
proc timer_set_repeat* (handle: ref Timer; repeat: uint64) {.libuv.}
proc timer_get_repeat* (handle: ref Timer): uint64 {.libuv.}
proc getaddrinfo* (loop: ref Loop; req: ref Getaddrinfo; getaddrinfo_cb: GetaddrinfoCb; node: cstring; service: cstring; hints: ref Addrinfo): int {.libuv.}
proc freeaddrinfo* (ai: ref Addrinfo) {.libuv.}
proc spawn* (a2: ref Loop; a3: ref Process; options: ProcessOptions): int {.libuv.}
proc process_kill* (a2: ref Process; signum: int): int {.libuv.}
proc kill* (pid: int; signum: int): Err {.libuv.}
proc queue_work* (loop: ref Loop; req: ref Work; work_cb: WorkCb; after_work_cb: AfterWorkCb): int {.libuv.}
proc cancel* (req: ref Req): int {.libuv.}
proc setup_args* (argc: int; argv: cstringArray): cstringArray {.libuv.}
proc get_process_title* (buffer: cstring; size: int): Err {.libuv.}
proc set_process_title* (title: cstring): Err {.libuv.}
proc resident_set_memory* (rss: ref int): Err {.libuv.}
proc uptime* (uptime: ref cdouble): Err {.libuv.}
proc cpu_info* (cpu_infos: ref ref CpuInfo; count: ref int): Err {.libuv.}
proc free_cpu_info* (cpu_infos: ref CpuInfo; count: int) {.libuv.}
proc interface_addresses* (addresses: ref ref InterfaceAddress; count: ref int): Err {.libuv.}
proc free_interface_addresses* (addresses: ref InterfaceAddress; count: int) {.libuv.}
proc fs_req_cleanup* (req: ref Fs) {.libuv.}
proc fs_close* (loop: ref Loop; req: ref Fs; file: File; cb: FsCb): int {.libuv.}
proc fs_open* (loop: ref Loop; req: ref Fs; path: cstring; flags: int; mode: int; cb: FsCb): int {.libuv.}
proc fs_read* (loop: ref Loop; req: ref Fs; file: File; buf: pointer; length: int; offset: int64; cb: FsCb): int {.libuv.}
proc fs_unlink* (loop: ref Loop; req: ref Fs; path: cstring; cb: FsCb): int {.libuv.}
proc fs_write* (loop: ref Loop; req: ref Fs; file: File; buf: pointer; length: int; offset: int64; cb: FsCb): int {.libuv.}
proc fs_mkdir* (loop: ref Loop; req: ref Fs; path: cstring; mode: int; cb: FsCb): int {.libuv.}
proc fs_rmdir* (loop: ref Loop; req: ref Fs; path: cstring; cb: FsCb): int {.libuv.}
proc fs_readdir* (loop: ref Loop; req: ref Fs; path: cstring; flags: int; cb: FsCb): int {.libuv.}
proc fs_stat* (loop: ref Loop; req: ref Fs; path: cstring; cb: FsCb): int {.libuv.}
proc fs_fstat* (loop: ref Loop; req: ref Fs; file: File; cb: FsCb): int {.libuv.}
proc fs_rename* (loop: ref Loop; req: ref Fs; path: cstring; new_path: cstring; cb: FsCb): int {.libuv.}
proc fs_fsync* (loop: ref Loop; req: ref Fs; file: File; cb: FsCb): int {.libuv.}
proc fs_fdatasync* (loop: ref Loop; req: ref Fs; file: File; cb: FsCb): int {.libuv.}
proc fs_ftruncate* (loop: ref Loop; req: ref Fs; file: File; offset: int64; cb: FsCb): int {.libuv.}
proc fs_sendfile* (loop: ref Loop; req: ref Fs; out_fd: File; in_fd: File; in_offset: int64; length: int; cb: FsCb): int {.libuv.}
proc fs_chmod* (loop: ref Loop; req: ref Fs; path: cstring; mode: int; cb: FsCb): int {.libuv.}
proc fs_utime* (loop: ref Loop; req: ref Fs; path: cstring; atime: cdouble; mtime: cdouble; cb: FsCb): int {.libuv.}
proc fs_futime* (loop: ref Loop; req: ref Fs; file: File; atime: cdouble; mtime: cdouble; cb: FsCb): int {.libuv.}
proc fs_lstat* (loop: ref Loop; req: ref Fs; path: cstring; cb: FsCb): int {.libuv.}
proc fs_link* (loop: ref Loop; req: ref Fs; path: cstring; new_path: cstring; cb: FsCb): int {.libuv.}
proc fs_symlink* (loop: ref Loop; req: ref Fs; path: cstring; new_path: cstring; flags: int; cb: FsCb): int {.libuv.}
proc fs_readlink* (loop: ref Loop; req: ref Fs; path: cstring; cb: FsCb): int {.libuv.}
proc fs_fchmod* (loop: ref Loop; req: ref Fs; file: File; mode: int; cb: FsCb): int {.libuv.}
proc fs_chown* (loop: ref Loop; req: ref Fs; path: cstring; uid: int; gid: int; cb: FsCb): int {.libuv.}
proc fs_fchown* (loop: ref Loop; req: ref Fs; file: File; uid: int; gid: int; cb: FsCb): int {.libuv.}
proc fs_poll_init* (loop: ref Loop; handle: ref FsPoll): int {.libuv.}
proc fs_poll_start* (handle: ref FsPoll; poll_cb: FsPollCb; path: cstring; interval: uint8): int {.libuv.}
proc fs_poll_stop* (handle: ref FsPoll): int {.libuv.}
proc signal_init* (loop: ref Loop; handle: ref Signal): int {.libuv.}
proc signal_start* (handle: ref Signal; signal_cb: SignalCb; signum: int): int {.libuv.}
proc signal_stop* (handle: ref Signal): int {.libuv.}
proc loadavg* (avg: array[0..3 - 1, cdouble]) {.libuv.}
proc fs_event_init* (loop: ref Loop; handle: ref FsEvent; filename: cstring; cb: FsEventCb; flags: int): int {.libuv.}
proc ip4_addr* (ip: cstring; port: int): SockaddrIn {.libuv.}
proc ip6_addr* (ip: cstring; port: int): SockaddrIn6 {.libuv.}
proc ip4_name* (src: ref SockaddrIn; dst: cstring; size: int): int {.libuv.}
proc ip6_name* (src: ref SockaddrIn6; dst: cstring; size: int): int {.libuv.}
proc inet_ntop* (af: int; src: pointer; dst: cstring; size: int): Err {.libuv.}
proc inet_pton* (af: int; src: cstring; dst: pointer): Err {.libuv.}
proc exepath* (buffer: cstring; size: ref int): int {.libuv.}
proc cwd* (buffer: cstring; size: int): Err {.libuv.}
proc chdir* (dir: cstring): Err {.libuv.}
proc get_free_memory* (): uint64 {.libuv.}
proc get_total_memory* (): uint64 {.libuv.}
proc hrtime* (): uint64 {.libuv.}
proc disable_stdio_inheritance* () {.libuv.}
proc dlopen* (filename: cstring; lib: ref Lib): int {.libuv.}
proc dlclose* (lib: ref Lib) {.libuv.}
proc dlsym* (lib: ref Lib; name: cstring; p: ref pointer): int {.libuv.}
proc dlerror* (lib: ref Lib): cstring {.libuv.}
proc mutex_init* (handle: ref Mutex): int {.libuv.}
proc mutex_destroy* (handle: ref Mutex) {.libuv.}
proc mutex_lock* (handle: ref Mutex) {.libuv.}
proc mutex_trylock* (handle: ref Mutex): int {.libuv.}
proc mutex_unlock* (handle: ref Mutex) {.libuv.}
proc rwlock_init* (rwlock: ref Rwlock): int {.libuv.}
proc rwlock_destroy* (rwlock: ref Rwlock) {.libuv.}
proc rwlock_rdlock* (rwlock: ref Rwlock) {.libuv.}
proc rwlock_tryrdlock* (rwlock: ref Rwlock): int {.libuv.}
proc rwlock_rdunlock* (rwlock: ref Rwlock) {.libuv.}
proc rwlock_wrlock* (rwlock: ref Rwlock) {.libuv.}
proc rwlock_trywrlock* (rwlock: ref Rwlock): int {.libuv.}
proc rwlock_wrunlock* (rwlock: ref Rwlock) {.libuv.}
proc sem_init* (sem: ref Sem; value: uint8): int {.libuv.}
proc sem_destroy* (sem: ref Sem) {.libuv.}
proc sem_post* (sem: ref Sem) {.libuv.}
proc sem_wait* (sem: ref Sem) {.libuv.}
proc sem_trywait* (sem: ref Sem): int {.libuv.}
proc cond_init* (cond: ref Cond): int {.libuv.}
proc cond_destroy* (cond: ref Cond) {.libuv.}
proc cond_signal* (cond: ref Cond) {.libuv.}
proc cond_broadcast* (cond: ref Cond) {.libuv.}
proc cond_wait* (cond: ref Cond; mutex: ref Mutex) {.libuv.}
proc cond_timedwait* (cond: ref Cond; mutex: ref Mutex; timeout: uint64): int {.libuv.}
proc barrier_init* (barrier: ref Barrier; count: uint8): int {.libuv.}
proc barrier_destroy* (barrier: ref Barrier) {.libuv.}
proc barrier_wait* (barrier: ref Barrier) {.libuv.}
proc once* (guard: ref Once; callback: Callback) {.libuv.}
proc thread_create* (tid: ref Thread; entry: Entry; arg: pointer): int {.libuv.}
proc thread_self* (): culong {.libuv.}
proc thread_join* (tid: ref Thread): int {.libuv.}

proc check* (err: int) =
  assert err == 0, "Response was: " & $ErrCode(err)

proc run_default_loop* () =
  var err = run(default_loop(), RUN_DEFAULT)
  check err

when isMainModule:
  # Raw test:
  {.pragma: libuv_raw, cdecl, dynlib: LIBUV, importc.}
  proc uv_default_loop(): pointer {.libuv_raw.}
  proc uv_run(loop: pointer; mode: RunMode): int {.libuv_raw.}
  proc uv_timer_init(a2: pointer; handle: pointer): int {.libuv_raw.}
  proc uv_timer_start(timer: pointer; cb: proc (h: ref Timer, status: int){.cdecl.}; timeout: int64; repeat: int64): int {.libuv_raw.}
  var h = sizeof(Timer).alloc
  proc test_timer(handle: ref Timer; status: int) {.cdecl.} =
    echo "Hello World"
  check uv_timer_init(uv_default_loop(), h)
  check uv_timer_start(h, test_timer, 2000, 0)
  check uv_run(uv_default_loop(), RUN_DEFAULT)
