template debug* (args: varargs[string, `$`]) =
  when defined(trace):
    for i in args.items(): stdout.write(i)
    stdout.write("\n")
