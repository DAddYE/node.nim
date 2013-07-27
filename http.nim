{.pragma: http_l, cdecl, dynlib: "./deps/http-parser/libhttp_parser.so.2.1", importc: "http_$1".}

import utils
import unsigned
import events
import uv

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

  Any {.inheritable.} = object
  Request* = object of Any
    headers*: Headers
    err_no*: uint8
    err_name*: string
    err_desc*: string
    body*: string
    last_header_was_value : bool
    meth*: string
    url*: string
    http_major*: uint16
    http_minor*: uint16
    complete*: bool
    settings: ref ParserSettings
    parser*: ref Parser
    events*: EventEmitter
    stream*: ref Stream
    writer*: ref Write

  EventArg* = object of EventArgs
    request*: ref Request

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
    data           : ref Request

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

proc to_request* (t: ref Any): ref Request =
  cast[ref Request](t)

proc init_request* (): ref Request =
  var req = Request.new
  req.parser.new
  req.settings.new
  req.parser.data = req
  req.parser.init(HTTP_REQUEST)
  req.complete = false
  req.events = initEventEmitter()
  req.headers = @[]

  # req.settings.on_message_begin = proc (p: ref Parser): int8 {.cdecl.} =
  #   debug "-- message begin"
  #   return 0

  req.settings.on_url = proc (p: ref Parser, at: cstring, length: csize): int8 {.cdecl.} =
    var req = p.data.to_request
    if req.url.isNil(): req.url = $at else: req.url.add($at)
    req.url.setLen(length)
    req.meth = $method_str(p.meth)
    debug "-> got url: '", req.url, "', '", req.meth, "'"
    return 0

  req.settings.on_header_field = proc (p: ref Parser, at: cstring, length: csize): int8 {.cdecl.} =
    var req  = p.data.to_request
    var field = $at
    field.setLen(length)
    var header: Header
    if req.headers.len > 0 and not req.last_header_was_value:
      req.headers[req.headers.high].name.add(field)
    else:
      header.name = field
      req.headers.add header
    req.last_header_was_value = false
    debug "-> got header field: '", field, "'"
    return 0

  req.settings.on_header_value = proc (p: ref Parser, at: cstring, length: csize): int8 {.cdecl.} =
    var req   = p.data.to_request
    var field = $at
    field.setLen(length)
    if req.headers.len == 0:
      var header: Header
      header.value = field
      req.headers.add header
    else:
      req.headers[req.headers.high].value = field
    req.last_header_was_value = true
    debug "-> got header value: '", field, "'"
    return 0

  req.settings.on_headers_complete = proc (p: ref Parser): int8 {.cdecl.} =
    var req = p.data.to_request
    req.http_major = p.http_major
    req.http_minor = p.http_minor
    req.events.emit "headers", EventArg(request: req)
    debug "-> got header complete HTTP/", req.http_major, ".", req.http_minor
    return 0

  # req.settings.on_status_complete = proc (p: ref Parser): int8 {.cdecl.} =
  #   debug "-> got status complete"
  #   return 0

  req.settings.on_body = proc (p: ref Parser, at: cstring, length: csize): int8 {.cdecl.} =
    var req  = p.data.to_request
    var body = $at
    body.setLen(length)
    if req.body.isNil(): req.body = body else: req.body.add(body)
    debug "-> got the body '", body, "'"
    return 0

  req.settings.on_message_complete = proc (p: ref Parser): int8 {.cdecl.} =
    var req      = p.data.to_request
    req.err_no   = p.err_no
    req.err_name = $err_no_name(p.err_no)
    req.err_desc = $err_no_description(p.err_no)
    req.complete = true
    req.events.emit "message", EventArg(request: req)
    debug "-- message complete: '", req.err_no, "', '",
              req.err_name, "', '", req.err_desc, "'"
    return 0

  return req

proc parse* (req: ref Request, body: cstring, len: int=0): int =
  req.parser.execute(req.settings, body, (if len > 0: len else: body.len))

if isMainModule:
  block:
    # see test/http_test.nim
    var req = http.init_request()
    for i in 0..5_000:
      var test = "GET http://www.google.com HTTP/2.5\r\n" &
                 "Host: localhost\r\n" &
                 "Accept: /\r\n" &
                 "Connection: Keep-Alive\r\n" &
                 "Content-Length: 11\r\n" & 
                 "\r\nHello World"
      var resp = http.parse(req, test)
      assert resp == test.len
