TARGET = lfs.js

CC = emcc
AR = ar
SIZE = size

SRC += $(wildcard *.c littlefs/*.c)
OBJ := $(SRC:.c=.o)
DEP := $(SRC:.c=.d)
ASM := $(SRC:.c=.s)

TEST := $(patsubst tests/%.sh,%,$(wildcard tests/test_*))

ifdef DEBUG
CFLAGS += -O0 -g3
else
CFLAGS += -Os
endif
ifdef WORD
CFLAGS += -m$(WORD)
endif
CFLAGS += -I. -Ilittlefs
CFLAGS += -std=c99 -Wall -pedantic
CFLAGS += -s WASM=0
CFLAGS += -s EXPORTED_RUNTIME_METHODS=ccall,cwrap,addFunction,lengthBytesUTF8
CFLAGS += -s EXPORTED_FUNCTIONS=_free,_malloc
CFLAGS += -s RESERVED_FUNCTION_POINTERS=20


all: $(TARGET)

asm: $(ASM)

size: $(OBJ)
	$(SIZE) -t $^

.SUFFIXES:
test: test_format test_dirs test_files test_seek test_parallel \
	test_alloc test_paths test_orphan test_move test_corrupt
test_%: tests/test_%.sh
	./$<

-include $(DEP)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) $^ $(LFLAGS) -o $@

%.a: $(OBJ)
	$(AR) rcs $@ $^

%.o: %.c
	$(CC) -c -MMD $(CFLAGS) $< -o $@

%.s: %.c
	$(CC) -S $(CFLAGS) $< -o $@

clean:
	rm -f $(TARGET)
	rm -f $(OBJ)
	rm -f $(DEP)
	rm -f $(ASM)
