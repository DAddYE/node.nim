# Original written by Alex Mitchell
# Edited by DAddYE (Davide D'Agostino)

type
  EventArgs*     = object of TObject ## Base object for event arguments that are passed to callback functions.
  EventCallback  = proc(e: EventArgs){.closure.}
  EventListener* = tuple[name: string, listeners: seq[EventCallback]] ## An eventlistener for an event.
  EventEmitter*  = object {.pure, final.} ## An object that fires events and holds event listeners for an object.
    s: seq[EventListener]
  EInvalidEvent* = object of EInvalidValue

proc initEventEmitter* (): EventEmitter =
  ## Creates and returns a new EventEmitter.
  result.s = @[]

proc getEventListener (emitter: var EventEmitter, event: string): int =
  for i in 0..high(emitter.s):
    if emitter.s[i].name == event: return i
  return -1

proc removeAllListeners* (emitter: var EventEmitter, event = "") =
  ## Clears all of the callbacks from the event listener.
  if event.len > 0:
    var i = emitter.getEventListener(event)
    if i > 0: emitter.s[i].listeners.setLen(0)
  else:
    emitter.s.setLen(0)

proc removeListener* (emitter: var EventEmitter, event: string, func: EventCallback) =
  ## Removes the callback from the specified event listener.
  var x = emitter.getEventListener(event)
  if x < 0: return
  var listener = emitter.s[x]
  for i in 0..high(listener.listeners):
    if func == listener.listeners[i]:
      emitter.s[x].listeners.del(i)
      if emitter.s[x].listeners.len == 0: emitter.s.delete(x)
      break

proc getOrInitEventListener (emitter: var EventEmitter, event: string): int =
  ## Get or Initializes an Eventlistener with the specified name and returns it.
  result = getEventListener(emitter, event)
  if result < 0:
    var listener: EventListener
    listener = (event, @[])
    emitter.s.add(listener)
    result = high(emitter.s)

proc on* (emitter: var EventEmitter, event: string, func: EventCallback) =
  ## Assigns a event listener with the specified callback. If the event
  ## doesn't exist, it will be created.
  var i = getOrInitEventListener(emitter, event)
  emitter.s[i].listeners.add(func)

proc addListener* (emitter: var EventEmitter, event: string, func: EventCallback) =
  on(emitter, event, func)

proc emit* (emitter: var EventEmitter, event: string, args: EventArgs) =
  ## Fires an event listener with specified event arguments.
  var i = getOrInitEventListener(emitter, event)
  for func in items(emitter.s[i].listeners): func(args)

proc len* (emitter: var EventEmitter): int =
  ## Get the len of registered listeners
  emitter.s.len

when isMainModule:
  block:
    type args = object of EventArgs
      name: string
    var events = initEventEmitter()
    events.on("foo") do (a: EventArgs):
      var b = args(a)
      assert b.name == "Fox!"
    events.emit("foo", args(name: "Fox!"))
    events.on("bar", nil)
    assert events.len == 2
    events.removeListener("bar", nil)
    assert events.len == 1
    events.on("foxy", nil)
    events.removeAllListeners()
    assert events.len == 0
    events.emit("bar", args())
    echo "\e[32mTest completed!\e[0m"
