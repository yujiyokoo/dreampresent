TARGET = dreampresent.elf

TARGET_BIN = dreampresent.bin

FIRST_READ_BIN = 1ST_READ.BIN

MKISOFS = genisoimage

MKDCDISC = /opt/mkdcdisc/bin/mkdcdisc

CDI_IMAGE = dreampresent.cdi

AUTHOR = "Yuji Yokoo"

GAME_NAME = Dreampresent

OBJS = src/dreampresent.o src/main.o romdisk.o src/dckos.o

# order here is important!
MRB_SOURCES = src/dc_kos_rb.rb src/page_data.rb src/presentation.rb src/dreampresent.rb src/start.rb

MRB_BYTECODE = src/dreampresent.c

KOS_ROMDISK_DIR = romdisk

MRB_ROOT = /opt/mruby

CFLAGS = -I$(MRB_ROOT)/include/ -L$(MRB_ROOT)/build/dreamcast/lib/

all: rm-elf $(CDI_IMAGE)

include $(KOS_BASE)/Makefile.rules

clean:
	-rm -f $(TARGET) $(OBJS) romdisk.* $(MRB_BYTECODE)

rm-elf:
	-rm -f $(TARGET) romdisk.*

$(TARGET): $(OBJS) $(MRB_BYTECODE)
	kos-cc $(CFLAGS) -o $(TARGET) $(OBJS) -lmruby -lm -lpng -lkosutils -lz

$(MRB_BYTECODE): src/dreampresent.rb
	$(MRB_ROOT)/bin/mrbc -g -Bdreampresent_bytecode -o $(MRB_BYTECODE) $(MRB_SOURCES)

run: $(TARGET)
	$(KOS_LOADER) $(TARGET)

dist:
	rm -f $(OBJS) romdisk.o romdisk.img
	$(KOS_STRIP) $(TARGET)

$(TARGET_BIN): $(TARGET)
	sh-elf-objcopy -R .stack -O binary $(TARGET) $(TARGET_BIN)

$(FIRST_READ_BIN): $(TARGET_BIN)
	$(KOS_BASE)/utils/scramble/scramble $(TARGET_BIN) $(FIRST_READ_BIN)

$(CDI_IMAGE): $(TARGET)
	$(MKDCDISC) -e $(TARGET) -a $(AUTHOR) -n $(GAME_NAME) -o $(CDI_IMAGE)
