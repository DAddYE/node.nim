UNAME := $(shell uname)
RTFLAGS="-lrt"
ifeq ($(UNAME), Darwin)
RTFLAGS=-framework CoreServices
endif

webserver: webserver.c Makefile
	gcc -w -Wall -Werror -O3 $(RTFLAGS) \
		../deps/libuv/libuv.a \
		../deps/http-parser/libhttp_parser.o $< -o $@
