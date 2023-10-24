DEFINES += -DNDEBUG
CXXFLAGS += -m64 -fPIC -Wall -lstdc++

SRCS := $(wildcard *.c*)
OBJS := $(patsubst %.cpp, %.o, $(SRCS))

LIBNAME= libmeasure64
LIBSHARED = $(LIBNAME).so
LIBSHARED_DBG = $(LIBNAME)_dbg.so
LIBSTATIC = $(LIBNAME).a

.PHONY: all
all: $(LIBSHARED) $(LIBSHARED_DBG) $(LIBSTATIC)

%.o: %.c*
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

$(LIBSHARED): $(OBJS)
	@$(CXX) -shared -o $@ $^ $(CXXFLAGS)

$(LIBSHARED_DBG): $(OBJS)
	@$(CXX) -shared -o $@ $^ $(CXXFLAGS) $(DEFINES)

$(LIBSTATIC): $(OBJS)
	@$(AR) r $@ $^

.PHONY: clean
clean:
	rm *.o *.a *.so
