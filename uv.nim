## Author Davide D'Agostino (@DAddYE)
## mail. info@daddye.it - web. http://daddye.it
## License MIT
##
## This wrapper is built and tested libuv 0.11.5

when defined(windows):
  import winlean
else:
  from posix import TAddrinfo, TSockaddr, TSockaddrIn, TSockaddrIn6, TMode, TOff, TGid, TStat

const LIBUV =
  when defined(windows): "libuv.dll"
  elif defined(macosx):  "libuv.dylib"
  else:                  "libuv.so"

type
  TBuf* = object
    base* : cstring
    len* : int

  TFile*    = cint
  TOsSock*  = cint
  TOnce*    = object
  TThread*  = object
  TMutex*   = object
  TRwlock*  = object
  TSem*     = object
  TCond*    = object

  TBarrier* = object
    n*          : cuint
    count*      : cuint
    mutex*      : TMutex
    turnstile1* : TSem
    turnstile2* : TSem

  TGid* = object
  TUid* = object

  TLib* = object
    handle* : pointer
    errmsg* : cstring

  TIoCb = proc (loop: ptr TLoop; w: ptr TIo; events: cuint) {.cdecl.}
  TIo = object
    cb            : TIoCb
    pending_queue : array[2, pointer]
    watcher_queue : array[2, pointer]
    pevents       : cuint
    events        : cuint
    fd            : cint
    rcount        : cint
    wcount        : cint

  TPoll* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle
    poll_cb*      : TPollCb
    io_watcher*   : TIo

  TPollEvent* = enum
    READABLE = 1, WRITABLE = 2

  TErrCode* {.size: sizeof(cint).} = enum
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

  THandleType* {.size: sizeof(cint).} = enum
    UNKNOWN_HANDLE = 0, ASYNC, CHECK, FS_EVENT, FS_POLL, HANDLE, IDLE, NAMED_PIPE, POLL, PREPARE,
    PROCESS, STREAM, TCP, TIMER, TTY, UDP, SIGNAL, FILE, HANDLE_TYPE_MAX

  TReqType* {.size: sizeof(cint), pure.} = enum
    UNKNOWN_REQ = 0, REQ, CONNECT, WRITE, SHUTDOWN, UDP_SEND, FS, WORK, GETADDRINFO, REQ_TYPE_MAX

  TRunMode* {.size: sizeof(cint).} = enum
    RUN_DEFAULT = 0, RUN_ONCE, RUN_NOWAIT

  TShutdown* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    handle*       : ptr TStream
    cb*           : TShutdownCb

  THandle* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle

  TPipe* = object
    close_cb*              : TCloseCb
    data*                  : pointer
    loop*                  : ptr TLoop
    ttype*                 : THandleType
    handle_queue*          : array[2, pointer]
    flags*                 : cint
    next_closing*          : ptr THandle
    write_queue_size*      : int
    alloc_cb*              : TAllocCb
    read_cb*               : TReadCb
    read2_cb*              : TRead2Cb
    connect_req*           : ptr TConnect
    shutdown_req*          : ptr TShutdown
    io_watcher*            : TIo
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]
    connection_cb*         : TConnectionCb
    delayed_error*         : cint
    accepted_fd*           : cint
    select*                : pointer
    ipc*                   : cint
    pipe_fname*            : cstring

  TTreeEntry* = object
    rbe_left*   : ptr TTimer
    rbe_right*  : ptr TTimer
    rbe_parent* : ptr TTimer
    rbe_color*  : cint

  TTimer* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle
    tree_entry*   : TTreeEntry
    timer_cb*     : TTimerCb
    timeout*      : uint64
    repeat*       : uint64
    start_id*     : uint64

  TTermios* = object

  TTty* = object
    close_cb*              : TCloseCb
    data*                  : pointer
    loop*                  : ptr TLoop
    ttype*                 : THandleType
    handle_queue*          : array[2, pointer]
    flags*                 : cint
    next_closing*          : ptr THandle
    write_queue_size*      : int
    alloc_cb*              : TAllocCb
    read_cb*               : TReadCb
    read2_cb*              : TRead2Cb
    connect_req*           : ptr TConnect
    shutdown_req*          : ptr TShutdown
    io_watcher*            : TIo
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]
    connection_cb*         : TConnectionCb
    delayed_error*         : cint
    accepted_fd*           : cint
    select*                : pointer
    orig_termios*          : TTermios
    mode*                  : cint

  TCheck* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle
    check_cb*     : TCheckCb
    queue*        : array[2, pointer]

  TPrepare* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle
    prepare_cb*   : TPrepareCb
    queue*        : array[2, pointer]

  TIdle* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle
    idle_cb*      : TIdleCb
    queue*        : array[2, pointer]

  TPAsyncCb = proc (loop: ptr TLoop, w: TPAsync, nevents: uint){.cdecl.}
  TPAsync = object
    cb         : TPAsyncCb
    io_watcher : TIo
    wfd        : int

  TAsync* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle
    async_cb*     : TAsyncCb
    queue*        : array[2, pointer]
    pending*      : cint

  TPWork = object
    work : proc (w: ptr TPWork)
    done : proc (w: ptr TPWork; status: cint)
    loop : ptr TLoop
    wq   : array[2, pointer]

  TWorkreq* = object
    work* : proc (w: ptr TWork) {.cdecl.}
    done* : proc (w: ptr TWork; status: cint) {.cdecl.}
    loop* : ptr TLoop
    wq*   : array[2, pointer]

  TWorkCb* = proc (req: ptr TWork) {.cdecl.}
  TWork* = object
    data*          : pointer
    ttype*         : TReqType
    active_queue*  : array[2, pointer]
    loop*          : ptr TLoop
    work_cb*       : TWorkCb
    after_work_cb* : TAfterWorkCb
    work_req*      : TWorkreq

  TGetaddrinfoCb* = proc (req: ptr TGetaddrinfo; status: cint; res: ptr TAddrinfo) {.cdecl.}
  TGetaddrinfo* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    loop*         : ptr TLoop
    work_req*     : TPWork
    cb*           : TGetaddrinfoCb
    hints*        : ptr TAddrinfo
    hostname*     : cstring
    service*      : cstring
    res*          : ptr TAddrinfo
    retcode*      : cint

  TStdioFlags* {.size: sizeof(cint).} = enum
    IGNORE = 0x00000000, CREATE_PIPE = 0x00000001, INHERIT_FD = 0x00000002,
    INHERIT_STREAM = 0x00000004, READABLE_PIPE = 0x00000010, WRITABLE_PIPE = 0x00000020
  TDataU* = object
    stream* : ptr TStream
    fd*     : cint

  TStdioContainer* = object
    flags* : TStdioFlags
    data*  : TDataU

  TProcessOptions* = object
    exit_cb* : TExitCb
    file*    : cstring
    args*    : cstringArray
    env*     : cstringArray
    cwd*     : cstring
    flags*   : cuint
    uid*     : TUid
    gid*     : TGid

  TProcessFlags* = enum
    PROCESS_SETUID = (1 shl 0), PROCESS_SETGID = (1 shl 1),
    PROCESS_WINDOWS_VERBATIM_ARGUMENTS = (1 shl 2), PROCESS_DETACHED = (1 shl 3),
    PROCESS_WINDOWS_HIDE = (1 shl 4)

  TProcess* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle
    exit_cb*      : TExitCb
    pid*          : cint
    queue*        : array[2, pointer]
    errorno*      : cint

  TCpuTimes* = object
    user* : uint64
    nice* : uint64
    sys*  : uint64
    idle* : uint64
    irq*  : uint64

  TCpuInfo* = object
    model*     : cstring
    speed*     : cint
    cpu_times* : TCpuTimes

  TAddressU* = object
    address4* : TSockaddr_in
    address6* : TSockaddr_in6

  TNetmaskU* = object
    netmask4* : TSockaddr_in
    netmask6* : TSockaddr_in6

  TInterfaceAddress* = object
    name* : cstring
    is_internal* : cint
    address* : TAddressU
    netmask* : TNetmaskU

  TFsType* {.size: sizeof(cint), pure.} = enum
    FS_UNKNOWN = - 1, FS_CUSTOM, FS_OPEN, FS_CLOSE, FS_READ, FS_WRITE, FS_SENDFILE, FS_STAT,
    FS_LSTAT, FS_FSTAT, FS_FTRUNCATE, FS_UTIME, FS_FUTIME, FS_CHMOD, FS_FCHMOD, FS_FSYNC,
    FS_FDATASYNC, FS_UNLINK, FS_RMDIR, FS_MKDIR, FS_RENAME, FS_READDIR, FS_LINK, FS_SYMLINK,
    FS_READLINK, FS_CHOWN, FS_FCHOWN

  TFs* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    fs_type*      : TFsType
    loop*         : ptr TLoop
    cb*           : TFsCb
    result*       : int
    pptr*         : pointer
    path*         : cstring
    errorno*      : TErrCode
    statbuf*      : TStat
    new_path*     : cstring
    file*         : TFile
    flags*        : cint
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

  TFsEvent* = object
    close_cb*       : TCloseCb
    data*           : pointer
    loop*           : ptr TLoop
    ttype*          : THandleType
    handle_queue*   : array[2, pointer]
    flags*          : cint
    next_closing*   : ptr THandle
    filename*       : cstring
    cb*             : TFsEventCb
    event_watcher*  : TIo
    realpath*       : cstring
    realpath_len*   : cint
    cf_flags*       : cint
    cf_eventstream* : pointer
    cf_cb*          : ptr TAsync
    cf_events*      : array[2, pointer]
    cf_sem*         : TSem
    cf_mutex*       : TMutex

  TFsPoll* = object
    close_cb*     : TCloseCb
    data*         : pointer
    loop*         : ptr TLoop
    ttype*        : THandleType
    handle_queue* : array[2, pointer]
    flags*        : cint
    next_closing* : ptr THandle
    poll_ctx*     : pointer

  TFsEventFlags* = enum
    FS_EVENT_WATCH_ENTRY = 1, FS_EVENT_STAT = 2, FS_EVENT_RECURSIVE = 3

  TSignal* = object
    close_cb*           : TCloseCb
    data*               : pointer
    loop*               : ptr TLoop
    ttype*              : THandleType
    handle_queue*       : array[2, pointer]
    flags*              : cint
    next_closing*       : ptr THandle
    signal_cb*          : TSignalCb
    signum*             : cint
    tree_entry*         : TTreeEntry
    caught_signals*     : cuint
    dispatched_signals* : cuint

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
    rbh_root* : ptr TTimer

  TLoop* = object
    data*              : pointer
    last_err*          : TErr
    active_handles*    : cuint
    handle_queue*      : array[2, pointer]
    active_reqs*       : array[2, pointer]
    stop_flag*         : cuint
    flags*             : culong
    backend_fd*        : cint
    pending_queue*     : array[2, pointer]
    watcher_queue*     : array[2, pointer]
    watchers*          : ptr ptr TIo
    nwatchers*         : cuint
    nfds*              : cuint
    wq*                : array[2, pointer]
    wq_mutex*          : TMutex
    wq_async*          : TAsync
    closing_handles*   : ptr THandle
    process_handles*   : array[2, array[1, pointer]]
    prepare_handles*   : array[2, pointer]
    check_handles*     : array[2, pointer]
    idle_handles*      : array[2, pointer]
    async_handles*     : array[2, pointer]
    async_watcher*     : TPAsync
    timer_handles*     : TTimers
    time*              : uint64
    signal_pipefd*     : array[2, cint]
    signal_io_watcher* : TIo
    child_watcher*     : TSignal
    emfile_fd*         : cint
    timer_counter*     : uint64
    cf_thread*         : TThread
    cf_cb*             : pointer
    cf_loop*           : pointer
    cf_mutex*          : TMutex
    cf_sem*            : TSem
    cf_signals*        : array[2, pointer]

  TCallback*     = proc () {.cdecl.}
  TEntry*        = proc (arg: pointer) {.cdecl.}
  TAllocCb*      = proc (handle: ptr THandle; suggested_size: int): TBuf {.cdecl.}
  TReadCb*       = proc (stream: ptr TStream; nread: int; buf: TBuf) {.cdecl.}
  TRead2Cb*      = proc (pipe: ptr TPipe; nread: int; buf: TBuf; pending: THandleType) {.cdecl.}
  TWriteCb*      = proc (req: ptr TWrite; status: cint) {.cdecl.}
  TConnectCb*    = proc (req: ptr TConnect; status: cint) {.cdecl.}
  TShutdownCb*   = proc (req: ptr TShutdown; status: cint) {.cdecl.}
  TConnectionCb* = proc (server: ptr TStream; status: cint) {.cdecl.}
  TCloseCb*      = proc (handle: ptr THandle) {.cdecl.}
  TPollCb*       = proc (handle: ptr TPoll; status: cint; events: cint) {.cdecl.}
  TTimerCb*      = proc (handle: ptr TTimer; status: cint){.cdecl.}
  TAsyncCb*      = proc (handle: ptr TAsync; status: cint) {.cdecl.}
  TPrepareCb*    = proc (handle: ptr TPrepare; status: cint) {.cdecl.}
  TCheckCb*      = proc (handle: ptr TCheck; status: cint) {.cdecl.}
  TIdleCb*       = proc (handle: ptr TIdle; status: cint) {.cdecl.}
  TExitCb*       = proc (a2: ptr TProcess; exit_status: cint; term_signal: cint) {.cdecl.}
  TWalkCb*       = proc (handle: ptr THandle; arg: pointer) {.cdecl.}
  TFsCb*         = proc (req: ptr TFs) {.cdecl.}
  TAfterWorkCb*  = proc (req: ptr TWork; status: cint) {.cdecl.}

  TTimespec* = object
    tv_sec*  : clong
    tv_nsec* : clong

  TFsEventCb* = proc (handle: ptr TFsEvent; filename: cstring; events: cint; status: cint) {.cdecl.}
  TFsPollCb*  = proc (handle: ptr TFsPoll; status: cint; prev: ptr TStat; curr: ptr TStat) {.cdecl.}
  TSignalCb*  = proc (handle: ptr TSignal; signum: cint) {.cdecl.}

  TMembership* {.size: sizeof(cint).} = enum
    LEAVE_GROUP = 0, JOIN_GROUP

  TErr* = object
    code*      : TErrCode
    sys_errno* : cint

  TReq* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]

  TStream* = object
    close_cb*              : TCloseCb
    data*                  : pointer
    loop*                  : ptr TLoop
    ttype*                 : THandleType
    handle_queue*          : array[2, pointer]
    flags*                 : cint
    next_closing*          : ptr THandle
    write_queue_size*      : int
    alloc_cb*              : TAllocCb
    read_cb*               : TReadCb
    read2_cb*              : TRead2Cb
    connect_req*           : ptr TConnect
    shutdown_req*          : ptr TShutdown
    io_watcher*            : TIo
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]
    connection_cb*         : TConnectionCb
    delayed_error*         : cint
    accepted_fd*           : cint
    select*                : pointer

  TWrite* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    cb*           : TWriteCb
    send_handle*  : ptr TStream
    handle*       : ptr TStream
    queue*        : array[2, pointer]
    write_index*  : cint
    bufs*         : ptr TBuf
    bufcnt*       : cint
    error*        : cint
    bufsml*       : array[0..4 - 1, TBuf]

  TTcp* = object
    close_cb*              : TCloseCb
    data*                  : pointer
    loop*                  : ptr TLoop
    ttype*                 : THandleType
    handle_queue*          : array[2, pointer]
    flags*                 : cint
    next_closing*          : ptr THandle
    write_queue_size*      : int
    alloc_cb*              : TAllocCb
    read_cb*               : TReadCb
    read2_cb*              : TRead2Cb
    connect_req*           : ptr TConnect
    shutdown_req*          : ptr TShutdown
    io_watcher*            : TIo
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]
    connection_cb*         : TConnectionCb
    delayed_error*         : cint
    accepted_fd*           : cint
    select*                : pointer

  TConnect* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    cb*           : TConnectCb
    handle*       : ptr TStream
    queue*        : array[2, pointer]

  TUdpFlags* = enum
    UDP_IPV6ONLY = 1, UDP_PARTIAL = 2

  TUdpSendCb* = proc (req: ptr TUdpSend; status: cint) {.cdecl.}
  TUdpRecvCb* = proc (handle: ptr TUdp; nread: int; buf: TBuf; adr: ptr TSockaddr; flags: cuint) {.cdecl.}

  TUdp* = object
    close_cb*              : TCloseCb
    data*                  : pointer
    loop*                  : ptr TLoop
    ttype*                 : THandleType
    handle_queue*          : array[2, pointer]
    flags*                 : cint
    next_closing*          : ptr THandle
    alloc_cb*              : TAllocCb
    recv_cb*               : TUdpRecvCb
    io_watcher*            : TIo
    write_queue*           : array[2, pointer]
    write_completed_queue* : array[2, pointer]

  TUdpSend* = object
    data*         : pointer
    ttype*        : TReqType
    active_queue* : array[2, pointer]
    handle*       : ptr TUdp
    cb*           : TUdpSendCb
    queue*        : array[2, pointer]
    adr*          : TSockaddr_in6
    bufcnt*       : cint
    bufs*         : ptr TBuf
    status*       : int
    send_cb*      : TUdpSendCb
    bufsml*       : array[4, TBuf]

{.pragma: libuv, cdecl, dynlib: LIBUV, importc: "uv_$1".}
proc version*(): cuint {.libuv.}
proc version_string*(): cstring {.libuv.}
proc loop_new*(): ptr TLoop {.libuv.}
proc loop_delete*(a2: ptr TLoop) {.libuv.}
proc default_loop*(): ptr TLoop {.libuv.}
proc run*(a2: ptr TLoop; mode: TRunMode): cint {.libuv.}
proc stop*(a2: ptr TLoop) {.libuv.}
proc href*(a2: ptr THandle) {.cdecl, dynlib: LIBUV, importc: "uv_ref".}
proc unref*(a2: ptr THandle) {.libuv.}
proc has_ref*(a2: ptr THandle): cint {.libuv.}
proc update_time*(a2: ptr TLoop) {.libuv.}
proc now*(a2: ptr TLoop): uint64 {.libuv.}
proc backend_fd*(a2: ptr TLoop): cint {.libuv.}
proc backend_timeout*(a2: ptr TLoop): cint {.libuv.}
proc last_error*(a2: ptr TLoop): TErr {.libuv.}
proc strerror*(err: TErr): cstring {.libuv.}
proc err_name*(err: TErr): cstring {.libuv.}
proc shutdown(req: ptr TShutdown; handle: ptr TStream; cb: TShutdownCb): cint {.libuv.}
proc handle_size*(ttype: THandleType): int {.libuv.}
proc req_size*(ttype: TReqType): int {.libuv.}
proc is_active*(handle: ptr THandle): cint {.libuv.}
proc walk*(loop: ptr TLoop; walk_cb: TWalkCb; arg: pointer) {.libuv.}
proc close*(handle: ptr THandle; close_cb: TCloseCb) {.libuv.}
proc buf_init*(base: cstring; len: cuint): TBuf {.libuv.}
proc strlcpy*(dst: cstring; src: cstring; size: int): int {.libuv.}
proc strlcat*(dst: cstring; src: cstring; size: int): int {.libuv.}
proc listen*(stream: ptr TStream; backlog: cint; cb: TConnectionCb): cint {.libuv.}
proc accept*(server: ptr TStream; client: ptr TStream): cint {.libuv.}
proc read_start*(a2: ptr TStream; alloc_cb: TAllocCb; read_cb: TReadCb): cint {.libuv.}
proc read_stop*(a2: ptr TStream): cint {.libuv.}
proc read2_start*(a2: ptr TStream; alloc_cb: TAllocCb; read_cb: TRead2Cb): cint {.libuv.}
proc write(req: ptr TWrite; handle: ptr TStream; bufs: ptr TBuf; bufcnt: cint; cb: TWriteCb): cint {.libuv.}
proc write2*(req: ptr TWrite; handle: ptr TStream; bufs: ptr TBuf; bufcnt: cint; send_handle: ptr TStream; cb: TWriteCb): cint {.libuv.}
proc is_readable*(handle: ptr TStream): cint {.libuv.}
proc is_writable*(handle: ptr TStream): cint {.libuv.}
proc stream_set_blocking*(handle: ptr TStream; blocking: cint): cint {.libuv.}
proc is_closing*(handle: ptr THandle): cint {.libuv.}
proc tcp_init*(a2: ptr TLoop; handle: ptr TTcp): cint {.libuv.}
proc tcp_open*(handle: ptr TTcp; sock: TOsSock): cint {.libuv.}
proc tcp_nodelay*(handle: ptr TTcp; enable: cint): cint {.libuv.}
proc tcp_keepalive*(handle: ptr TTcp; enable: cint; delay: cuint): cint {.libuv.}
proc tcp_simultaneous_accepts*(handle: ptr TTcp; enable: cint): cint {.libuv.}
proc tcp_bind*(handle: ptr TTcp; a3: TSockaddr_in): cint {.libuv.}
proc tcp_bind6*(handle: ptr TTcp; a3: TSockaddr_in6): cint {.libuv.}
proc tcp_getsockname*(handle: ptr TTcp; name: ptr TSockaddr; namelen: ptr cint): cint {.libuv.}
proc tcp_getpeername*(handle: ptr TTcp; name: ptr TSockaddr; namelen: ptr cint): cint {.libuv.}
proc tcp_connect*(req: ptr TConnect; handle: ptr TTcp; address: TSockaddr_in; cb: TConnectCb): cint {.libuv.}
proc tcp_connect6*(req: ptr TConnect; handle: ptr TTcp; address: TSockaddr_in6; cb: TConnectCb): cint {.libuv.}
proc udp_init*(a2: ptr TLoop; handle: ptr TUdp): cint {.libuv.}
proc udp_open*(handle: ptr TUdp; sock: TOsSock): cint {.libuv.}
proc udp_bind*(handle: ptr TUdp; adr: TSockaddr_in; flags: cuint): cint {.libuv.}
proc udp_bind6*(handle: ptr TUdp; adr: TSockaddr_in6; flags: cuint): cint {.libuv.}
proc udp_getsockname*(handle: ptr TUdp; name: ptr TSockaddr; namelen: ptr cint): cint {.libuv.}
proc udp_set_membership*(handle: ptr TUdp; multicast_addr: cstring; interface_addr: cstring; membership: TMembership): cint {.libuv.}
proc udp_set_multicast_loop*(handle: ptr TUdp; on: cint): cint {.libuv.}
proc udp_set_multicast_ttl*(handle: ptr TUdp; ttl: cint): cint {.libuv.}
proc udp_set_broadcast*(handle: ptr TUdp; on: cint): cint {.libuv.}
proc udp_set_ttl*(handle: ptr TUdp; ttl: cint): cint {.libuv.}
proc udp_send(req: ptr TUdpSend; handle: ptr TUdp; bufs: ptr TBuf; bufcnt: cint; adr: TSockaddr_in; send_cb: TUdpSendCb): cint {.libuv.}
proc udp_send6*(req: ptr TUdpSend; handle: ptr TUdp; bufs: ptr TBuf; bufcnt: cint; adr: TSockaddr_in6; send_cb: TUdpSendCb): cint {.libuv.}
proc udp_recv_start*(handle: ptr TUdp; alloc_cb: TAllocCb; recv_cb: TUdpRecvCb): cint {.libuv.}
proc udp_recv_stop*(handle: ptr TUdp): cint {.libuv.}
proc tty_init*(a2: ptr TLoop; a3: ptr TTty; fd: TFile; readable: cint): cint {.libuv.}
proc tty_set_mode*(a2: ptr TTty; mode: cint): cint {.libuv.}
proc tty_reset_mode*() {.libuv.}
proc tty_get_winsize*(a2: ptr TTty; width: ptr cint; height: ptr cint): cint {.libuv.}
proc guess_handle*(file: TFile): THandleType {.libuv.}
proc pipe_init*(a2: ptr TLoop; handle: ptr TPipe; ipc: cint): cint {.libuv.}
proc pipe_open*(a2: ptr TPipe; file: TFile): cint {.libuv.}
proc pipe_bind*(handle: ptr TPipe; name: cstring): cint {.libuv.}
proc pipe_connect*(req: ptr TConnect; handle: ptr TPipe; name: cstring; cb: TConnectCb) {.libuv.}
proc pipe_pending_instances*(handle: ptr TPipe; count: cint) {.libuv.}
proc poll_init*(loop: ptr TLoop; handle: ptr TPoll; fd: cint): cint {.libuv.}
proc poll_init_socket*(loop: ptr TLoop; handle: ptr TPoll; socket: TOsSock): cint {.libuv.}
proc poll_start*(handle: ptr TPoll; events: cint; cb: TPollCb): cint {.libuv.}
proc poll_stop*(handle: ptr TPoll): cint {.libuv.}
proc prepare_init*(a2: ptr TLoop; prepare: ptr TPrepare): cint {.libuv.}
proc prepare_start*(prepare: ptr TPrepare; cb: TPrepareCb): cint {.libuv.}
proc prepare_stop*(prepare: ptr TPrepare): cint {.libuv.}
proc check_init*(a2: ptr TLoop; check: ptr TCheck): cint {.libuv.}
proc check_start*(check: ptr TCheck; cb: TCheckCb): cint {.libuv.}
proc check_stop*(check: ptr TCheck): cint {.libuv.}
proc idle_init*(a2: ptr TLoop; idle: ptr TIdle): cint {.libuv.}
proc idle_start*(idle: ptr TIdle; cb: TIdleCb): cint {.libuv.}
proc idle_stop*(idle: ptr TIdle): cint {.libuv.}
proc async_init*(a2: ptr TLoop; async: ptr TAsync; async_cb: TAsyncCb): cint {.libuv.}
proc async_send*(async: ptr TAsync): cint {.libuv.}
proc timer_init*(a2: ptr TLoop; handle: ptr TTimer): cint {.libuv.}
proc timer_start*(handle: ptr TTimer; cb: TTimerCb; timeout: uint64; repeat: uint64): cint {.libuv.}
proc timer_stop*(handle: ptr TTimer): cint {.libuv.}
proc timer_again*(handle: ptr TTimer): cint {.libuv.}
proc timer_set_repeat*(handle: ptr TTimer; repeat: uint64) {.libuv.}
proc timer_get_repeat*(handle: ptr TTimer): uint64 {.libuv.}
proc getaddrinfo(loop: ptr TLoop; req: ptr TGetaddrinfo; getaddrinfo_cb: TGetaddrinfoCb; node: cstring; service: cstring; hints: ptr TAddrinfo): cint {.libuv.}
proc freeaddrinfo*(ai: ptr TAddrinfo) {.libuv.}
proc spawn*(a2: ptr TLoop; a3: ptr TProcess; options: TProcessOptions): cint {.libuv.}
proc process_kill*(a2: ptr TProcess; signum: cint): cint {.libuv.}
proc kill*(pid: cint; signum: cint): TErr {.libuv.}
proc queue_work*(loop: ptr TLoop; req: ptr TWork; work_cb: TWorkCb; after_work_cb: TAfterWorkCb): cint {.libuv.}
proc cancel*(req: ptr TReq): cint {.libuv.}
proc setup_args*(argc: cint; argv: cstringArray): cstringArray {.libuv.}
proc get_process_title*(buffer: cstring; size: int): TErr {.libuv.}
proc set_process_title*(title: cstring): TErr {.libuv.}
proc resident_set_memory*(rss: ptr int): TErr {.libuv.}
proc uptime*(uptime: ptr cdouble): TErr {.libuv.}
proc cpu_info*(cpu_infos: ptr ptr TCpuInfo; count: ptr cint): TErr {.libuv.}
proc free_cpu_info*(cpu_infos: ptr TCpuInfo; count: cint) {.libuv.}
proc interface_addresses*(addresses: ptr ptr TInterfaceAddress; count: ptr cint): TErr {.libuv.}
proc free_interface_addresses*(addresses: ptr TInterfaceAddress; count: cint) {.libuv.}
proc fs_req_cleanup*(req: ptr TFs) {.libuv.}
proc fs_close*(loop: ptr TLoop; req: ptr TFs; file: TFile; cb: TFsCb): cint {.libuv.}
proc fs_open*(loop: ptr TLoop; req: ptr TFs; path: cstring; flags: cint; mode: cint; cb: TFsCb): cint {.libuv.}
proc fs_read*(loop: ptr TLoop; req: ptr TFs; file: TFile; buf: pointer; length: int; offset: int64; cb: TFsCb): cint {.libuv.}
proc fs_unlink*(loop: ptr TLoop; req: ptr TFs; path: cstring; cb: TFsCb): cint {.libuv.}
proc fs_write*(loop: ptr TLoop; req: ptr TFs; file: TFile; buf: pointer; length: int; offset: int64; cb: TFsCb): cint {.libuv.}
proc fs_mkdir*(loop: ptr TLoop; req: ptr TFs; path: cstring; mode: cint; cb: TFsCb): cint {.libuv.}
proc fs_rmdir*(loop: ptr TLoop; req: ptr TFs; path: cstring; cb: TFsCb): cint {.libuv.}
proc fs_readdir*(loop: ptr TLoop; req: ptr TFs; path: cstring; flags: cint; cb: TFsCb): cint {.libuv.}
proc fs_stat*(loop: ptr TLoop; req: ptr TFs; path: cstring; cb: TFsCb): cint {.libuv.}
proc fs_fstat*(loop: ptr TLoop; req: ptr TFs; file: TFile; cb: TFsCb): cint {.libuv.}
proc fs_rename*(loop: ptr TLoop; req: ptr TFs; path: cstring; new_path: cstring; cb: TFsCb): cint {.libuv.}
proc fs_fsync*(loop: ptr TLoop; req: ptr TFs; file: TFile; cb: TFsCb): cint {.libuv.}
proc fs_fdatasync*(loop: ptr TLoop; req: ptr TFs; file: TFile; cb: TFsCb): cint {.libuv.}
proc fs_ftruncate*(loop: ptr TLoop; req: ptr TFs; file: TFile; offset: int64; cb: TFsCb): cint {.libuv.}
proc fs_sendfile*(loop: ptr TLoop; req: ptr TFs; out_fd: TFile; in_fd: TFile; in_offset: int64; length: int; cb: TFsCb): cint {.libuv.}
proc fs_chmod*(loop: ptr TLoop; req: ptr TFs; path: cstring; mode: cint; cb: TFsCb): cint {.libuv.}
proc fs_utime*(loop: ptr TLoop; req: ptr TFs; path: cstring; atime: cdouble; mtime: cdouble; cb: TFsCb): cint {.libuv.}
proc fs_futime*(loop: ptr TLoop; req: ptr TFs; file: TFile; atime: cdouble; mtime: cdouble; cb: TFsCb): cint {.libuv.}
proc fs_lstat*(loop: ptr TLoop; req: ptr TFs; path: cstring; cb: TFsCb): cint {.libuv.}
proc fs_link*(loop: ptr TLoop; req: ptr TFs; path: cstring; new_path: cstring; cb: TFsCb): cint {.libuv.}
proc fs_symlink*(loop: ptr TLoop; req: ptr TFs; path: cstring; new_path: cstring; flags: cint; cb: TFsCb): cint {.libuv.}
proc fs_readlink*(loop: ptr TLoop; req: ptr TFs; path: cstring; cb: TFsCb): cint {.libuv.}
proc fs_fchmod*(loop: ptr TLoop; req: ptr TFs; file: TFile; mode: cint; cb: TFsCb): cint {.libuv.}
proc fs_chown*(loop: ptr TLoop; req: ptr TFs; path: cstring; uid: cint; gid: cint; cb: TFsCb): cint {.libuv.}
proc fs_fchown*(loop: ptr TLoop; req: ptr TFs; file: TFile; uid: cint; gid: cint; cb: TFsCb): cint {.libuv.}
proc fs_poll_init*(loop: ptr TLoop; handle: ptr TFsPoll): cint {.libuv.}
proc fs_poll_start*(handle: ptr TFsPoll; poll_cb: TFsPollCb; path: cstring; interval: cuint): cint {.libuv.}
proc fs_poll_stop*(handle: ptr TFsPoll): cint {.libuv.}
proc signal_init*(loop: ptr TLoop; handle: ptr TSignal): cint {.libuv.}
proc signal_start*(handle: ptr TSignal; signal_cb: TSignalCb; signum: cint): cint {.libuv.}
proc signal_stop*(handle: ptr TSignal): cint {.libuv.}
proc loadavg*(avg: array[0..3 - 1, cdouble]) {.libuv.}
proc fs_event_init*(loop: ptr TLoop; handle: ptr TFsEvent; filename: cstring; cb: TFsEventCb; flags: cint): cint {.libuv.}
proc ip4_addr*(ip: cstring; port: cint): TSockaddrIn {.libuv.}
proc ip6_addr*(ip: cstring; port: cint): TSockaddrIn6 {.libuv.}
proc ip4_name*(src: ptr TSockaddrIn; dst: cstring; size: int): cint {.libuv.}
proc ip6_name*(src: ptr TSockaddrIn6; dst: cstring; size: int): cint {.libuv.}
proc inet_ntop*(af: cint; src: pointer; dst: cstring; size: int): TErr {.libuv.}
proc inet_pton*(af: cint; src: cstring; dst: pointer): TErr {.libuv.}
proc exepath*(buffer: cstring; size: ptr int): cint {.libuv.}
proc cwd*(buffer: cstring; size: int): TErr {.libuv.}
proc chdir*(dir: cstring): TErr {.libuv.}
proc get_free_memory*(): uint64 {.libuv.}
proc get_total_memory*(): uint64 {.libuv.}
proc hrtime*(): uint64 {.libuv.}
proc disable_stdio_inheritance*() {.libuv.}
proc dlopen*(filename: cstring; lib: ptr TLib): cint {.libuv.}
proc dlclose*(lib: ptr TLib) {.libuv.}
proc dlsym*(lib: ptr TLib; name: cstring; p: ptr pointer): cint {.libuv.}
proc dlerror*(lib: ptr TLib): cstring {.libuv.}
proc mutex_init*(handle: ptr TMutex): cint {.libuv.}
proc mutex_destroy*(handle: ptr TMutex) {.libuv.}
proc mutex_lock*(handle: ptr TMutex) {.libuv.}
proc mutex_trylock*(handle: ptr TMutex): cint {.libuv.}
proc mutex_unlock*(handle: ptr TMutex) {.libuv.}
proc rwlock_init*(rwlock: ptr TRwlock): cint {.libuv.}
proc rwlock_destroy*(rwlock: ptr TRwlock) {.libuv.}
proc rwlock_rdlock*(rwlock: ptr TRwlock) {.libuv.}
proc rwlock_tryrdlock*(rwlock: ptr TRwlock): cint {.libuv.}
proc rwlock_rdunlock*(rwlock: ptr TRwlock) {.libuv.}
proc rwlock_wrlock*(rwlock: ptr TRwlock) {.libuv.}
proc rwlock_trywrlock*(rwlock: ptr TRwlock): cint {.libuv.}
proc rwlock_wrunlock*(rwlock: ptr TRwlock) {.libuv.}
proc sem_init*(sem: ptr TSem; value: cuint): cint {.libuv.}
proc sem_destroy*(sem: ptr TSem) {.libuv.}
proc sem_post*(sem: ptr TSem) {.libuv.}
proc sem_wait*(sem: ptr TSem) {.libuv.}
proc sem_trywait*(sem: ptr TSem): cint {.libuv.}
proc cond_init*(cond: ptr TCond): cint {.libuv.}
proc cond_destroy*(cond: ptr TCond) {.libuv.}
proc cond_signal*(cond: ptr TCond) {.libuv.}
proc cond_broadcast*(cond: ptr TCond) {.libuv.}
proc cond_wait*(cond: ptr TCond; mutex: ptr TMutex) {.libuv.}
proc cond_timedwait*(cond: ptr TCond; mutex: ptr TMutex; timeout: uint64): cint {.libuv.}
proc barrier_init*(barrier: ptr TBarrier; count: cuint): cint {.libuv.}
proc barrier_destroy*(barrier: ptr TBarrier) {.libuv.}
proc barrier_wait*(barrier: ptr TBarrier) {.libuv.}
proc once*(guard: ptr TOnce; callback: TCallback) {.libuv.}
proc thread_create*(tid: ptr TThread; entry: TEntry; arg: pointer): cint {.libuv.}
proc thread_self*(): culong {.libuv.}
proc thread_join*(tid: ptr TThread): cint {.libuv.}

when isMainModule:
  var Loop = default_loop()

  proc check_err(err: int) =
    assert err == 0, "Response was: " & $TErrCode(err)


  ## Module global
  template set_timer(timeout: uint64, repeat: uint64, timer: var TTimer, actions: proc ()) =
    check_err timer_init(Loop, addr timer)
    var cb = proc (handle: ptr TTimer; status: cint){.cdecl.} = actions()
    check_err timer_start(addr timer, cb, timeout, repeat)

  template set_timer(timeout: uint64, repeat: uint64, actions: proc ()) =
    var t: TTimer
    set_timer(timeout, repeat, t, actions)

  var t: TTimer
  set_timer(1000, 1000, t):
    echo("Interval every 1s with t")

  set_timer(2000, 0):
    echo("Timout of 2s without t")

  echo "Running LibUV ", version_string()
  check_err run(Loop, RUN_DEFAULT)

  # Raw test
  # {.pragma: libuv_raw, cdecl, dynlib: LIBUV, importc.}
  # proc uv_default_loop(): pointer {.libuv_raw.}
  # proc uv_run(loop: pointer; mode: TRunMode): int {.libuv_raw.}
  # proc uv_timer_init(a2: pointer; handle: pointer): int {.libuv_raw.}
  # proc uv_timer_start(timer: pointer; cb: proc (h: ptr TTimer, status: cint){.cdecl.}; timeout: int64; repeat: int64): int {.libuv_raw.}

  # var h = handle_size(TIMER).alloc
  # proc test_timer(handle: ptr TTimer; status: cint) {.cdecl.} =
  #   echo "Hello World"

  # check_err uv_timer_init(uv_default_loop(), h)
  # check_err uv_timer_start(h, test_timer, 2000, 0)
  # check_err uv_run(uv_default_loop(), RUN_DEFAULT)
