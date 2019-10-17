from snippet_helpers import (
  tab
)

######################################################################
# Concatenate the variables name of the case options
#
# t - Text input
#
def build_opts(t):
  if t:
    lines = t.splitlines()
    if lines:
      result = ""
      for line in lines:
        result += ":" + str.strip(line).split('=', 1)[0]
      return result
    return ":" + t
  else:
    return ":"

######################################################################
# Creates the diferents options cases
#
# t - Text input
#
def build_case(t):
  if t:
    lines = t.splitlines()
    if len(lines) > 0:
      result = ""
      for line in lines:
        aux = str.strip(line).split('=', 1)[0]
        result += tab(6) + aux + ")\n"
        result += tab(8) + aux + "=\"${OPTARGS:-$" + aux + "}\"\n"
        result += tab(8) + ";;\n"
      return result
    return ""

######################################################################
# Creates a helper function
#
# t - Text input
#
def build_helper(t):
  if t:
    lines = t.splitlines()
    if len(lines) > 0:
      result = ""
      for line in lines:
        aux = str.strip(line).split('=', 1)[0]
        result += tab(2) + "echo \" -" + aux + " <>\"" + "\n"
      return result
    return ""
