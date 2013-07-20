import unittest
from ../http import nil

suite "http":
  suite "requests":
    test "basic":
      var test = "GET http://www.google.com HTTP/2.5\r\n" &
                 "Host: localhost\r\n" &
                 "Accept: /\r\n" &
                 "Connection: Keep-Alive\r\n" &
                 "Content-Length: 11\r\n" & 
                 "\r\nHello World"
      var
        req = http.parse_request(test)
        h: http.Header

      check: req.meth == "GET"
      check: req.url  == "http://www.google.com"
      check: req.http_major.int == 2
      check: req.http_minor.int == 5
      check: req.body == "Hello World"
      check:
        req.headers[0].name  == "Content-Length"
        req.headers[0].value == "11"
      check:
        req.headers[1].name  == "Connection"
        req.headers[1].value == "Keep-Alive"
      check:
        req.headers[2].name  == "Accept"
        req.headers[2].value == "/"
      check:
        req.headers[3].name  == "Host"
        req.headers[3].value == "localhost"
      check:
        req.err_no.int == 0
        req.err_name == "HPE_OK"
        req.err_desc == "success"
      check: req.complete

    test "dumbfuck":
      var test = "GET /dumbfuck HTTP/1.1\r\n" &
                 "aaaaaaaaaaaaa:++++++++++\r\n" &
                 "\r\n"

      var req = http.parse_request(test)
      check: req.meth == "GET"
      check: req.url  == "/dumbfuck"
      check: req.http_major.int == 1
      check: req.http_minor.int == 1
      check: req.body == nil
      check: req.complete

    test "no headers no body":
      var test = "GET /get_no_headers_no_body/world HTTP/1.1\r\n\r\n"
      var req = http.parse_request(test)
      check: req.meth == "GET"
      check: req.url  == "/get_no_headers_no_body/world"
      check: req.http_major.int == 1
      check: req.http_minor.int == 1
      check: req.body == nil
      check: req.complete == true

    test "one header no body":
      var test = "GET /get_one_header_no_body HTTP/1.1\r\n" &
                 "Accept: */*\r\n\r\n"
      var req = http.parse_request(test)
      check: req.meth == "GET"
      check: req.url  == "/get_one_header_no_body"
      check: req.http_major.int == 1
      check: req.http_minor.int == 1
      check: req.body == nil
      check:
        req.headers[0].name  == "Accept"
        req.headers[0].value == "*/*"
      check: req.complete == true

    test "post chunked all your base":
      var test = "POST /post_chunked_all_your_base HTTP/1.1\r\n" &
                 "Transfer-Encoding: chunked\r\n" &
                 "\r\n" &
                 "1e\r\nall your base are belong to us\r\n" &
                 "0\r\n" &
                 "\r\n"
      var req = http.parse_request(test)
      check: req.meth == "POST"
      check: req.url  == "/post_chunked_all_your_base"
      check: req.http_major.int == 1
      check: req.http_minor.int == 1
      check: req.body == "all your base are belong to us"
      check:
        req.headers[0].name  == "Transfer-Encoding"
        req.headers[0].value == "chunked"
      check: req.complete == true

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
      var req = http.parse_request(test)
      check: req.meth == "POST"
      check: req.url  == "/chunked_w_trailing_headers"
      check: req.http_major.int == 1
      check: req.http_minor.int == 1
      check: req.body == "hello world"
      check:
        req.headers[0].name  == "Content-Type"
        req.headers[0].value == "text/plain"
      check:
        req.headers[1].name  == "Vary"
        req.headers[1].value == "*"
      check:
        req.headers[2].name  == "Transfer-Encoding"
        req.headers[2].value == "chunked"
      check: req.complete == true

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
      var req = http.parse_request(test)
      check: req.meth == "GET"
      check: req.url  == "/demo"
      check: req.http_major.int == 1
      check: req.http_minor.int == 1
      check: req.body.isNil()

    test "no http version":
      var test = "GET /\r\n\r\n"
      var req = http.parse_request(test)
      check: req.meth == "GET"
      check: req.url  == "/"
      check: req.http_major.int == 0
      check: req.http_minor.int == 9
      check: req.body.isNil()

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
      var req = http.parse_request(test)
      check: req.meth == "GET"
      check: req.meth == "GET"
      check: req.url  == "/favicon.ico"
      check: req.http_major.int == 1
      check: req.http_minor.int == 1
      check: req.body.isNil()
      check:
        req.headers[0].name  == "Connection"
        req.headers[0].value == "keep-alive"
      check:
        req.headers[1].name  == "Keep-Alive"
        req.headers[1].value == "300"
      check:
        req.headers[2].name  == "Accept-Charset"
        req.headers[2].value == "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
      check:
        req.headers[3].name  == "Accept-Encoding"
        req.headers[3].value == "gzip,deflate"
      check:
        req.headers[4].name  == "Accept-Language"
        req.headers[4].value == "en-us,en;q=0.5"
      check:
        req.headers[5].name  == "Accept"
        req.headers[5].value == "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
      check:
        req.headers[6].name  == "User-Agent"
        req.headers[6].value == "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9) Gecko/2008061015 Firefox/3.0"
      check:
        req.headers[7].name  == "Host"
        req.headers[7].value == "0.0.0.0=5000"
      check: req.complete == true
