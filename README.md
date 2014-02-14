Generic Makefile
================

This is a "generic" Makefile which can be dropped into any directory
containing C++ files and things will then "just work" if you invoke "make".
In other words, you do not need to manually include the list of source
files, dependencies etc.  All of those are automatically handled.

The Makefile creates all *.o and *.d files in a separate subdirectory
called obj/ under the current directory and the final executable in a
subdirectory called bin/ under the current directory.

Current Features/Limitations
----------------------------

* Arbitrarily deep source trees.
* Automatically handles dependencies between sources and headers
