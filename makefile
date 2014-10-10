QUICKRANK:=quickrank
SRCDIR:=src
UTESTSDIR:=unit-tests
BINDIR:=bin
INCDIRS:=-Iinclude
OBJSDIR:=_build
DEPSDIR:=_deps
DOCDIR:=documentation

SRCS:=$(wildcard $(SRCDIR)/*.cc) $(wildcard $(SRCDIR)/*/*.cc) $(wildcard $(SRCDIR)/*/*/*.cc)
SRCS:=$(filter-out $(SRCDIR)/main.cc, $(SRCS))
DEPS:=$(subst $(SRCDIR),$(DEPSDIR)/$(SRCDIR),$(SRCS:.cc=.d))
OBJS:=$(subst $(SRCDIR),$(OBJSDIR)/$(SRCDIR),$(SRCS:.cc=.o))

UTESTS:=$(wildcard $(UTESTSDIR)/*.cc) $(wildcard $(UTESTSDIR)/*/*.cc) $(wildcard $(UTESTSDIR)/*/*/*.cc)
UTESTSOBJS:=$(subst $(UTESTSDIR),$(OBJSDIR)/$(UTESTSDIR),$(UTESTS:.cc=.o))

# TODO: Fix what is the file with main.cc


CXX=
CXXFLAGS:=-std=c++11 -Wall -pedantic -march=native -Ofast -fopenmp
LDLIBS:=-lboost_program_options -fopenmp

#		-I/usr/local/boost_1_56_0 -L/usr/local/boost_1_56_0/stage/lib \

# find the compiler
ifneq ($(shell whereis g++-4.8),)
	CXX=g++-4.8
else 
	ifneq ($(shell whereis g++-4.9),)
  	CXX=g++-4.9
  else
    ifneq ($(shell /usr/local/bin/g++-4.9 --version),)
      CXX=/usr/local/bin/g++-4.9
      CXXFLAGS+=-Wa,-q
    endif
	endif
endif

# builds QuickRank
all: quickrank
	
# builds QuickRank
quickrank: $(BINDIR)/$(QUICKRANK)

# builds QuickRank
$(BINDIR)/$(QUICKRANK): $(OBJS)
	@mkdir -p $(BINDIR)
	$(CXX) $(LDLIBS) $(OBJS) -o $(BINDIR)/$(QUICKRANK)
#	strip $@

# runs all the unit tests
unit-tests: $(BINDIR)/unit-tests
	$(BINDIR)/unit-tests --log_level=test_suite

# creates the documentation
doc:
	cd $(DOCDIR); doxygen quickrank.doxygen

# removes intermediate files
clean:
	rm -rf $(OBJSDIR)
	rm -rf $(DEPSDIR)

# removes everything but the source
dist-clean: clean
	@rm -rf $(BINDIR)
	@rm -rf $(DOCDIR)

# build dependency files
$(DEPSDIR)/%.d: %.cc
	@mkdir -p $(dir $@)
	@$(CXX) $(INCDIRS) $(CXXFLAGS) -MM -MT $(OBJSDIR)/$(<:.cc=.o) $< > $@ 

# compilation
$(OBJSDIR)/%.o: %.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCDIRS) -c -o $@ $<

# linking
$(BINDIR)/unit-tests: $(OBJS) $(UTESTSOBJS)
	$(CXX) $(LDLIBS) -lboost_unit_test_framework \
	$(filter-out $(OBJSDIR)/$(SRCDIR)/lm.o,$(OBJS)) $(UTESTSOBJS) \
	-o $(BINDIR)/unit-tests
	
#include dependency files
-include $(DEPS)
 
	
## valgrind do not support instruction produced by option "-march=native"
# # TODO (cla): be moved in the test folder
# # Valgrind debugging commands
# valgrind-lm:
# 	@mkdir -p ../bin
# 	$(cc) -std=c++11 -O0 -g -I "." -o ../bin/qr main.cpp
# 	valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all \
# 	../bin/qr lm 10 0.1 0 8 1 0 ndcg 10 ndcg 10 0 \
# 	../tests/data/msn1.fold1.train.5k.txt ../tests/data/msn1.fold1.vali.5k.txt ../tests/data/msn1.fold1.test.5k.txt - test.out
# #	$(shell export GLIBCXX_FORCE_NEW; # this should avoid stl memory pooling

# valgrind-mn:
# 	@mkdir -p ../bin
# 	$(cc) -std=c++11 -O0 -g -I "." -o ../bin/qr main.cpp
# 	valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all \
# 	../bin/qr mn 10 0.1 0 4 1 0 ndcg 10 ndcg 10 0 \
# 	../tests/data/msn1.fold1.train.5k.txt ../tests/data/msn1.fold1.vali.5k.txt ../tests/data/msn1.fold1.test.5k.txt - test.out