ifdef PLATFORM
override PLATFORM := $(shell echo $(PLATFORM) | tr "[A-Z]" "[a-z]")
else
PLATFORM = $(shell sh -c 'uname -s | tr "[A-Z]" "[a-z]"')
endif

ifeq (darwin,$(PLATFORM))
SOEXT = dylib
else
ifneq (,$(findstring mingw,$(PLATFORM)))
SOEXT = dll
else
SOEXT = so
endif
endif

CFLAGS += -O3
CC = gcc

all: http_parser libuv

http_parser:
	$(MAKE) -C deps/http-parser library CC=${CC} CFLAGS=${CFLAGS}

libuv:
	$(MAKE) -C deps/libuv libuv.${SOEXT}  CC=${CC} CFLAGS=${CFLAGS}

clean:
	$(MAKE) -C deps/http-parser clean
	$(MAKE) -C deps/libuv clean

.PHONY: all http_parser libuv clean
