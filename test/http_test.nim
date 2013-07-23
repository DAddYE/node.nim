import unittest
from ../http import nil

suite "http":
  suite "requests":
    var req = http.init_request()
    test "basic":
      var test = "GET http://www.google.com HTTP/2.5\r\n" &
                 "Host: localhost\r\n" &
                 "Accept: /\r\n" &
                 "Connection: Keep-Alive\r\n" &
                 "Content-Length: 11\r\n" & 
                 "\r\nHello World"
      var resp = http.parse(req, test)
      check: resp.meth == "GET"
      check: resp.url  == "http://www.google.com"
      check: resp.http_major.int == 2
      check: resp.http_minor.int == 5
      check: resp.body == "Hello World"
      check:
        resp.headers[0].name  == "Content-Length"
        resp.headers[0].value == "11"
      check:
        resp.headers[1].name  == "Connection"
        resp.headers[1].value == "Keep-Alive"
      check:
        resp.headers[2].name  == "Accept"
        resp.headers[2].value == "/"
      check:
        resp.headers[3].name  == "Host"
        resp.headers[3].value == "localhost"
      check:
        resp.err_no.int == 0
        resp.err_name == "HPE_OK"
        resp.err_desc == "success"
      check: resp.complete

    test "dumbfuck":
      var test = "GET /dumbfuck HTTP/1.1\r\n" &
                 "aaaaaaaaaaaaa:++++++++++\r\n" &
                 "\r\n"
      var resp = http.parse(req, test)
      check: resp.meth == "GET"
      check: resp.url  == "/dumbfuck"
      check: resp.http_major.int == 1
      check: resp.http_minor.int == 1
      check: resp.body == nil
      check: resp.complete

    test "no headers no body":
      var test = "GET /get_no_headers_no_body/world HTTP/1.1\r\n\r\n"
      var resp = http.parse(req, test)
      check: resp.meth == "GET"
      check: resp.url  == "/get_no_headers_no_body/world"
      check: resp.http_major.int == 1
      check: resp.http_minor.int == 1
      check: resp.body == nil
      check: resp.complete == true

    test "one header no body":
      var test = "GET /get_one_header_no_body HTTP/1.1\r\n" &
                 "Accept: */*\r\n\r\n"
      var resp = http.parse(req, test)
      check: resp.meth == "GET"
      check: resp.url  == "/get_one_header_no_body"
      check: resp.http_major.int == 1
      check: resp.http_minor.int == 1
      check: resp.body == nil
      check:
        resp.headers[0].name  == "Accept"
        resp.headers[0].value == "*/*"
      check: resp.complete == true

    test "post chunked all your base":
      var test = "POST /post_chunked_all_your_base HTTP/1.1\r\n" &
                 "Transfer-Encoding: chunked\r\n" &
                 "\r\n" &
                 "1e\r\nall your base are belong to us\r\n" &
                 "0\r\n" &
                 "\r\n"
      var resp = http.parse(req, test)
      check: resp.meth == "POST"
      check: resp.url  == "/post_chunked_all_your_base"
      check: resp.http_major.int == 1
      check: resp.http_minor.int == 1
      check: resp.body == "all your base are belong to us"
      check:
        resp.headers[0].name  == "Transfer-Encoding"
        resp.headers[0].value == "chunked"
      check: resp.complete == true

    test "chunked with traling headers":
      var test = "POST /chunked_w_trailing_headers HTTP/1.1\r\n" &
                 "Transfer-Encoding: chunked\r\n" &
                 "\r\n" &
                 "5\r\nhello\r\n" &
                 "6\r\n world\r\n" &
                 "0\r\n" &
                 "Vary: *\r\n" &
                 "Content-Type: text/plain\r\n" &
                 "\r\n"
      var resp = http.parse(req, test)
      check: resp.meth == "POST"
      check: resp.url  == "/chunked_w_trailing_headers"
      check: resp.http_major.int == 1
      check: resp.http_minor.int == 1
      check: resp.body == "hello world"
      check:
        resp.headers[0].name  == "Content-Type"
        resp.headers[0].value == "text/plain"
      check:
        resp.headers[1].name  == "Vary"
        resp.headers[1].value == "*"
      check:
        resp.headers[2].name  == "Transfer-Encoding"
        resp.headers[2].value == "chunked"
      check: resp.complete == true

    test "upgrade request":
      var test = "GET /demo HTTP/1.1\r\n" &
                 "Host: example.com\r\n" &
                 "Connection: Upgrade\r\n" &
                 "Sec-WebSocket-Key2: 12998 5 Y3 1  .P00\r\n" &
                 "Sec-WebSocket-Protocol: sample\r\n" &
                 "Upgrade: WebSocket\r\n" &
                 "Sec-WebSocket-Key1: 4 @1  46546xW%0l 1 5\r\n" &
                 "Origin: http://example.com\r\n" &
                 "\r\n" &
                 "Hot diggity dogg"
      var resp = http.parse(req, test)
      check: resp.meth == "GET"
      check: resp.url  == "/demo"
      check: resp.http_major.int == 1
      check: resp.http_minor.int == 1
      check: resp.body.isNil()

    test "no http version":
      var test = "GET /\r\n\r\n"
      var resp = http.parse(req, test)
      check: resp.meth == "GET"
      check: resp.url  == "/"
      check: resp.http_major.int == 0
      check: resp.http_minor.int == 9
      check: resp.body.isNil()

    test "big header":
      var test = "GET /favicon.ico HTTP/1.1\r\n" &
                 "Host: 0.0.0.0=5000\r\n" &
                 "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9) Gecko/2008061015 Firefox/3.0\r\n" &
                 "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n" &
                 "Accept-Language: en-us,en;q=0.5\r\n" &
                 "Accept-Encoding: gzip,deflate\r\n" &
                 "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\n" &
                 "Keep-Alive: 300\r\n" &
                 "Connection: keep-alive\r\n" &
                 "\r\n"
      var resp = http.parse(req, test)
      check: resp.meth == "GET"
      check: resp.meth == "GET"
      check: resp.url  == "/favicon.ico"
      check: resp.http_major.int == 1
      check: resp.http_minor.int == 1
      check: resp.body.isNil()
      check:
        resp.headers[0].name  == "Connection"
        resp.headers[0].value == "keep-alive"
      check:
        resp.headers[1].name  == "Keep-Alive"
        resp.headers[1].value == "300"
      check:
        resp.headers[2].name  == "Accept-Charset"
        resp.headers[2].value == "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
      check:
        resp.headers[3].name  == "Accept-Encoding"
        resp.headers[3].value == "gzip,deflate"
      check:
        resp.headers[4].name  == "Accept-Language"
        resp.headers[4].value == "en-us,en;q=0.5"
      check:
        resp.headers[5].name  == "Accept"
        resp.headers[5].value == "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      check:
        resp.headers[6].name  == "User-Agent"
        resp.headers[6].value == "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9) Gecko/2008061015 Firefox/3.0"
      check:
        resp.headers[7].name  == "Host"
        resp.headers[7].value == "0.0.0.0=5000"
      check: resp.complete == true
