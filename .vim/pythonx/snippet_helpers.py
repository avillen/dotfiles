######################################################################
# Autocomplete
#
# t    - Text input
# opts - List of options to autocomplete
#
def complete(t, opts):
  if t:
    opts = [ m[len(t):] for m in opts if m.startswith(t) ]
  if len(opts) == 1:
    return opts[0]
  return '[' + '|'.join(opts) + ']'


######################################################################
# Insert spaces
#
# n - Number of spaces
#
def tab(n):
  return " " * n
