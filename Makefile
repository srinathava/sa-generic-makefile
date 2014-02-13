PROGNAME := test

CXX := g++
CXXFLAGS := -g -O0

SOURCES := $(wildcard *.cpp)

BUILDDIR := build

DEPENDS := $(patsubst %.cpp,$(BUILDDIR)/%.d,$(SOURCES))
OBJS := $(patsubst %.cpp,$(BUILDDIR)/%.o,$(SOURCES))

-include $(DEPENDS)

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
$(BUILDDIR)/%.d : %.cpp
	@echo "Regenerating $@"
	@mkdir -p $(BUILDDIR)
	@gcc -MM $< \
	    | sed 's/\(\w\+\).o/$(BUILDDIR)\/\1.o $(BUILDDIR)\/\1.d/' > $@

$(BUILDDIR)/%.o : %.cpp
	@mkdir -p $(BUILDDIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

.DEFAULT_GOAL := $(PROGNAME)
$(PROGNAME): $(OBJS)
	g++ -o $@ $(OBJS)

.PHONY : clean
clean:
	\rm -f $(OBJS) $(PROGNAME)

.PHONY : distclean
distclean: clean
	\rm -rf build 

