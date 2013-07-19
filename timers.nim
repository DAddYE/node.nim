import uv

proc check_err (err: int) =
  assert err == 0, "Response was: " & $TErrCode(err)

template set_timer (delay: uint64, repeat: uint64, timer: var TTimer, callback: proc ()) =
  check_err timer_init(Loop, addr timer)
  var cb = proc (handle: ptr TTimer; status: cint){.cdecl.} = callback()
  check_err timer_start(addr timer, cb, delay, repeat)

template set_timer (delay: uint64, repeat: uint64, callback: proc ()) =
  var t: TTimer
  set_timer(delay, repeat, t, callback)

##
# To schedule execution of a one-time `callback` after `delay` milliseconds. Returns a
# `var TTimer` for possible use with `clear_timeout()`.
#
# It is important to note that your callback will probably not be called in exactly
# `delay` milliseconds - Node.nim makes no guarantees about the exact timing of when
# the callback will fire, nor of the ordering things will fire in. The callback will
# be called as close as possible to the time specified.
#
template set_timeout* (delay: uint64, timer: var TTimer, callback: proc ()) =
  set_timer(delay, 0, timer, callback)

##
# set_timeout(delay, callback)
#
template set_timeout* (delay: uint64, callback: proc ()) =
  set_timer(delay, 0, callback)

##
# Prevents a timeout from triggering.
#
proc clear_timeout* (timer: var TTimer) =
  check_err timer_stop(addr timer)

##
# To schedule the repeated execution of `callback` every `delay` milliseconds.
# Returns a `var TTimer` for possible use with `clear_interval()`.
#
template set_interval* (interval: uint64, timer: var TTimer, callback: proc ()) =
  set_timer(interval, interval, timer, callback)

##
# set_interval(delay, callback)
#
template set_interval* (interval: uint64, callback: proc ()) =
  set_timer(interval, interval, callback)

##
# Stops a interval from triggering.
#
proc clear_interval* (timer: var TTimer) =
  clear_timeout(timer)

## TODO: medium

## unref()

# The opaque value returned by `setTimeout` and `setInterval` also has the method
# `timer.unref()` which will allow you to create a timer that is active but if
# it is the only item left in the event loop won't keep the program running.
# If the timer is already `unref`d calling `unref` again will have no effect.

# In the case of `setTimeout` when you `unref` you create a separate timer that
# will wakeup the event loop, creating too many of these may adversely effect
# event loop performance -- use wisely.

# ## ref()

# If you had previously `unref()`d a timer you can call `ref()` to explicitly
# request the timer hold the program open. If the timer is already `ref`d calling
# `ref` again will have no effect.

# ## setImmediate(callback, [arg], [...])

# To schedule the "immediate" execution of `callback` after I/O events
# callbacks and before `setTimeout` and `setInterval` . Returns an
# `immediateId` for possible use with `clearImmediate()`. Optionally you
# can also pass arguments to the callback.

# Callbacks for immediates are queued in the order in which they were created.
# The entire callback queue is processed every event loop iteration. If you queue
# an immediate from a inside an executing callback that immediate won't fire
# until the next event loop iteration.

## clearImmediate(immediateId)

# Stops an immediate from triggering.


when isMainModule:
  var Loop = default_loop()

  var t: TTimer
  set_interval 1000, t:
    echo "Interval every 1s with t"

  # var cb = proc (a: string, b: string) =
  #   echo "Hello ", a, b
  # set_timeout 1000, cb, "Sten", " Smith"

  set_timeout 2000:
    echo "Timeout of 2s without t"
    clear_timeout(t)

  echo "Running LibUV ", version_string()
  check_err run(Loop, RUN_DEFAULT)
