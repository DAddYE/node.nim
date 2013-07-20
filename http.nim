{.pragma: http_h, cdecl, header: "../deps/http-parser/http_parser.h",    importc: "http_$1".}
{.pragma: http_l, cdecl, dynlib: "./deps/http-parser/libhttp_parser.so", importc: "http_$1".}

from os import nil
import unsigned

type
  DataCb = proc (a2: ref Parser; at: cstring; length: int): int8 {.cdecl.}
  Cb     = proc (a2: ref Parser): int8 {.cdecl.}

  HttpMethod* = enum
    HTTP_DELETE,   HTTP_GET,      HTTP_HEAD,        HTTP_POST,         HTTP_PUT,
    HTTP_CONNECT,  HTTP_OPTIONS,  HTTP_TRACE,       HTTP_COPY,         HTTP_LOCK,
    HTTP_MKCOL,    HTTP_MOVE,     HTTP_PROPFIND,    HTTP_PROPPATCH,    HTTP_SEARCH,
    HTTP_UNLOCK,   HTTP_REPORT,   HTTP_MKACTIVITY,  HTTP_CHECKOUT,     HTTP_MERGE,
    HTTP_MSEARCH,  HTTP_NOTIFY,   HTTP_SUBSCRIBE,   HTTP_UNSUBSCRIBE,  HTTP_PATCH,
    HTTP_PURGE

  ParserType* = enum
    HTTP_REQUEST, HTTP_RESPONSE, HTTP_BOTH

  ParserFlags* = enum
    F_CHUNKED  = 1 shl 0, F_CONNECTION_KEEP_ALIVE = 1 shl 1, F_CONNECTION_CLOSE = 1 shl 2,
    F_TRAILING = 1 shl 3, F_UPGRADE               = 1 shl 4, F_SKIPBODY         = 1 shl 5

  Header*  = tuple[name: string, value: string]
  Headers* = seq[Header]

  Any = object of TObject
    headers*  : Headers
    err_no*   : uint8
    err_name* : string
    err_desc* : string
    body*     : string
    last_header_was_value : bool

  PRequest = ref Request
  Request* = object of Any
    meth*       : string
    url*        : string
    http_major* : uint16
    http_minor* : uint16
    complete*   : bool

  Parser = object
    type_flags     : uint8 # bit-field 2 and flags bit-field 6
    state          : uint8
    header_state   : uint8
    index          : uint8
    nread          : uint32
    content_length : uint64
    http_major     : uint16
    http_minor     : uint16
    status_code    : uint16
    meth           : uint8
    err_no_upgrade : uint8 # bit-field err 7, upgrade 1
    data           : ref Any

  ParserSettings = object
    on_message_begin    : Cb
    on_url              : DataCb
    on_status_complete  : Cb
    on_header_field     : DataCb
    on_header_value     : DataCb
    on_headers_complete : Cb
    on_body             : DataCb
    on_message_complete : Cb

  ParserUrlFields* = enum
    SCHEMA,    HOST,  PORT,  PATH,  QUERY,  FRAGMENT,
    USERINFO,  MAX

  FieldData = object
    off  : uint16
    size : uint16

  ParserUrl = object
    field_set  : uint16
    port       : uint16
    field_data : array[MAX, FieldData]

# Parser Methods
proc init* (parser: ref Parser, kind: ParserType) {.http_l, importc: "http_parser_init".}
proc execute* (parser: ref Parser, settings: ref ParserSettings, data: cstring, size: int): int {.http_l, importc: "http_parser_execute".}
proc should_keep_alive* (parser: ref Parser): int {.http_l.}
proc parser_pause* (parser: ref Parser; paused: int) {.http_l.}
proc body_is_final* (parser: ref Parser): int {.http_l.}
proc kind* (parser: ref Parser): uint8 = parser.type_flags and 0x03
proc flags* (parser: ref Parser): uint8 = parser.type_flags shr 2
proc err_no* (parser: ref Parser): uint8 = parser.err_no_upgrade and 0x7F
proc upgrade* (parser: ref Parser): uint8 = parser.err_no_upgrade shr 1

proc parser_parse_url* (buf: cstring; buflen: int; is_connect: int; u: ref ParserUrl): int {.http_l.}
proc method_str* (m: uint8): cstring {.http_l.}
proc errno_name* (err: uint8): cstring {.http_l.}
proc errno_description* (err: uint8): cstring {.http_l.}

template debug(args: varargs[string, `$`]) =
  if os.get_env("DEBUG") != "":
    for i in args.items(): stdout.write(i)
    stdout.write("\n")

proc parse_request* (body: cstring): ref Request =
  var settings : ref ParserSettings
  var parser   : ref Parser
  var request  : ref Request

  # Alloc resources
  request.new
  settings.new
  parser.new

  request.complete = false

  settings.on_message_begin = proc (p: ref Parser): int8 {.cdecl.} =
    debug "-- message begin"
    p.data.headers = @[]
    return 0

  settings.on_url = proc (p: ref Parser, at: cstring, length: csize): int8 {.cdecl.} =
    var req = PRequest(p.data)
    req.url = $at
    req.url.setLen(length)
    req.meth = $method_str(p.meth)
    debug "-> got url: '", req.url, "', '", req.meth, "'"
    return 0

  settings.on_header_field = proc (p: ref Parser, at: cstring, length: csize): int8 {.cdecl.} =
    var req  = PRequest(p.data)
    var field = $(at)
    field.setLen(length)
    var header: Header
    if req.headers.len > 0 and not req.last_header_was_value:
      req.headers[req.headers.len - 1].name.add(field)
    else:
      header.name = field
      req.headers.insert header
    req.last_header_was_value = false
    debug "-> got header field: '", field, "'"
    return 0

  settings.on_header_value = proc (p: ref Parser, at: cstring, length: csize): int8 {.cdecl.} =
    var req   = PRequest(p.data)
    var field = $(at)
    field.setLen(length)
    if req.headers.len == 0:
      var header: Header
      header.value = field
      req.headers.insert header
    else:
      req.headers[0].value = field
    req.last_header_was_value = true
    debug "-> got header value: '", field, "'"
    return 0

  settings.on_headers_complete = proc (p: ref Parser): int8 {.cdecl.} =
    var req = PRequest(p.data)
    req.http_major = p.http_major
    req.http_minor = p.http_minor
    debug "-> got header complete HTTP/", req.http_major, ".", req.http_minor
    return 0

  settings.on_status_complete = proc (p: ref Parser): int8 {.cdecl.} =
    debug "-> got status complete"
    return 0

  settings.on_body = proc (p: ref Parser, at: cstring, length: csize): int8 {.cdecl.} =
    var req  = PRequest(p.data)
    var body = $at
    body.setLen(length)
    if req.body.isNil(): req.body = body else: req.body.add(body)
    debug "-> got the body '", body, "'"
    return 0

  settings.on_message_complete = proc (p: ref Parser): int8 {.cdecl.} =
    var req      = PRequest(p.data)
    req.err_no   = p.err_no
    req.err_name = $err_no_name(p.err_no)
    req.err_desc = $err_no_description(p.err_no)
    req.complete = true
    debug "-- message complete: '", req.err_no, "', '",
              req.err_name, "', '", req.err_desc, "'"
    return 0

  parser.data = request
  parser.init(HTTP_REQUEST)
  discard parser.execute(settings, body, body.len)

  return request
