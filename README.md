## What is this?

The idea behind is to add to the **awesome** [Nimrod](https://github.com/Araq/Nimrod) a new layer
to deal with asynchronous calls, coroutines and threads.

Indeed, Nimrod contains already an async module (for sockets) and a great support for threads.

But I want to do something different more high-level and also learn a bit more how to use this
amazing language.

Obviously I need to thank @araq for two main reason: 1) Nimrod 2) The infinite patience with me!

## Modules

Right now I wrote **c wrappers** for:

- [libuv 0.11.5](http://github.com/joyent/libuv/tree/v0.11.5)
- [http-parser 2.1](https://github.com/joyent/http-parser/tree/v2.1)
- [lthread](https://github.com/halayli/lthread)

Then I started prototyping an [http server](/http_server.nim). To do that I used a similar approach to node with an
[event emitter](/events.nim), you can find more on the [http parser](/http.nim)

## How fast it is?

Seems close to C. Here some purely _fun_ indications:

The [C version](/examples/webserver.c) of our http server (which has less overhead) perform:

```
Concurrency Level:      100
Time taken for tests:   0.276 seconds
Complete requests:      5000
Failed requests:        0
Write errors:           0
Total transferred:      390000 bytes
HTML transferred:       65000 bytes
Requests per second:    18085.01 [#/sec] (mean)
Time per request:       5.529 [ms] (mean)
Time per request:       0.055 [ms] (mean, across all concurrent requests)
Transfer rate:          1377.57 [Kbytes/sec] received
```

The **Nimrod** version:

```
Concurrency Level:      100
Time taken for tests:   0.286 seconds
Complete requests:      5000
Failed requests:        0
Write errors:           0
Total transferred:      375000 bytes
HTML transferred:       70000 bytes
Requests per second:    17476.28 [#/sec] (mean)
Time per request:       5.722 [ms] (mean)
Time per request:       0.057 [ms] (mean, across all concurrent requests)
Transfer rate:          1280.00 [Kbytes/sec] received
```

A bench with `lthread` is planned soon after that I think I can have an idea more clear on the
direction of this project.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
