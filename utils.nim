template debug* (args: varargs[string, `$`]) =
  # if os.get_env("DEBUG") != "":
  #   for i in args.items(): stdout.write(i)
  #   stdout.write("\n")

template withoutGC* (expr: stmt) =
  # GC_disable()
  expr
  # GC_enable()
