PROGNAME ?= test

CXX ?= g++

CXXFLAGS :=
ifdef DEBUG
  CXXFLAGS := -g -O0
endif

OBJDIR ?= obj

BINDIR ?= bin

SOURCES := $(patsubst ./%,%,$(shell find . -name '*.cpp'))

DEPENDS := $(patsubst %.cpp,$(OBJDIR)/%.d,$(SOURCES))
OBJS := $(patsubst %.cpp,$(OBJDIR)/%.o,$(SOURCES))

# This prevents 'make clean' from regenerating the dependency files only to
# remove them right away. -including something basically adds that file as
# a dependency for every invoked goal.
ifneq ($(MAKECMDGOALS),clean)
 ifneq ($(MAKECMDGOALS),distclean)
   -include $(DEPENDS)
 endif
endif

ifeq ($(OS),Windows_NT)
  # first remove the trailing .exe if it exists ...
  PROGNAME := $(patsubst %.exe,%,$(PROGNAME))
  # and put it back in. This way we only have one .exe at the end.
  PROGNAME := $(PROGNAME).exe
endif

ifneq (,$(BINDIR))
  PROGNAME := $(BINDIR)/$(PROGNAME)
endif

.DEFAULT_GOAL := $(PROGNAME)
$(PROGNAME): $(OBJS)
	@mkdir -p $(@D)
	g++ -o $@ $(OBJS)

.PHONY : clean
clean:
	rm -f $(OBJS) $(DEPENDS) $(PROGNAME)

.PHONY : distclean
distclean: clean
	rm -rf $(OBJDIR) 

# For every file foo.cpp, generate the dependencies for build/foo.o
# file into build/foo.d. Note that build/foo.d itself will have the same
# dependency as build/foo.o. Thus build/foo.d will look something like:
#
# build/foo.o build/foo.d: foo.cpp incfile1.h incfile2.h
#
# Notice both build/foo.o and build/foo.d on the LHS. This handles the case
# when the dependency needs to change because a header file got modified
# and the dependency of the CPP file changes without any change to the CPP
# file itself.
#
# The SECONDEXPANSION magic is to make the .d file depend on a token file
# in the same directory as the .d file. Normally, a pattern rule like this
# cannot have a pre-requisite which depends on special variables like $@
# etc. However, using the second expansion trick, we can make this happen.
# Only works in make 3.81
.SECONDEXPANSION:
$(OBJDIR)/%.d : %.cpp $$(dir $$@)token
	@echo "Updating dependency file $@"
	@gcc -MM $< \
	    | sed 's!\(\w\+\).o!$(basename $@).o $(basename $@).d!' > $@

$(OBJDIR)/%.o : %.cpp $$(dir $$@)token
	@echo "Compiling: $<"
	@$(CXX) $(CXXFLAGS) -c $< -o $@

# WISH: Find out why we have to specify this to be .PRECIOUS even though it
# is an explicit target. This doesn't seem to be necessary with very simple
# one-level directory structures.
.PRECIOUS: %/token
%/token:
	@echo "Creating directory $(dir $@)"
	@mkdir -p $(@D)
	@touch $@
