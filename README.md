Generic Makefile
================

This is a "generic" Makefile which can be dropped into any directory
containing C++ files and things will then "just work" if you invoke "make".
In other words, you do not need to manually include the list of source
files, dependencies etc.  All of those are automatically handled.

The Makefile creates all *.o and *.d files in a separate subdirectory
called build/ under the current directory. It however puts the final
executable (by default named "test") in the current directory.

Current Limitations
-------------------
# There is no support for multiple sub-directories. All sources need to be
in the current directory.
