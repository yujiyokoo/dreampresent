# dreampresent: a simple presentation tool for Sega Dreamcast written in Ruby

PROJECT_NAME = dreampresent

# Name of the compiled mruby script
MRB_BYTECODE_IREP_NAME = dreampresent_bytecode

# Ruby sources
# The order here is important!
MRB_SOURCES = src/dc_kos_rb.rb src/page_data.rb src/presentation.rb src/$(PROJECT_NAME).rb src/start.rb

# mruby script output
MRB_BYTECODE = src/$(PROJECT_NAME).c

# KallistiOS Romdisk directory
KOS_ROMDISK_DIR = romdisk

# Binary object sources
OBJS = src/$(PROJECT_NAME).o src/main.o $(KOS_ROMDISK_DIR).o src/dckos.o

# Directory path where mruby is installed
MRB_ROOT = /opt/mruby

# Compiler flags
CFLAGS = -I$(MRB_ROOT)/include/ -L$(MRB_ROOT)/build/dreamcast/lib/

# Program files
TARGETFILE = $(PROJECT_NAME).elf
BINARYFILE = $(PROJECT_NAME).bin
BOOTFILE = cd_root/1ST_READ.BIN

all: rm-elf $(TARGETFILE)

include $(KOS_BASE)/Makefile.rules

rm-elf:
	-rm -f $(TARGETFILE) $(BINARYFILE) $(BOOTFILE)

rm-obj:
	-rm -f $(OBJS) $(KOS_ROMDISK_DIR).img $(MRB_BYTECODE)
	
clean: rm-elf rm-obj

$(TARGETFILE): $(OBJS) $(MRB_BYTECODE)
	kos-cc $(CFLAGS) -o $(TARGETFILE) $(OBJS) -lmruby -lm -lpng -lkosutils -lz
	kos-objcopy -O binary $(TARGETFILE) $(BINARYFILE)
	
$(MRB_BYTECODE): $(MRB_SOURCES)
	$(MRB_ROOT)/bin/mrbc -g -B$(MRB_BYTECODE_IREP_NAME) -o $(MRB_BYTECODE) $(MRB_SOURCES)

run: $(TARGETFILE)
	$(KOS_LOADER) $(TARGETFILE)

dist: $(TARGETFILE)
	$(KOS_BASE)/utils/scramble/scramble $(BINARYFILE) $(BOOTFILE)
