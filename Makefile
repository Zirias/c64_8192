C64SYS?=c64
C64AS?=ca65
C64LD?=ld65
MKD64?=mkd64

C64ASFLAGS?=-t $(C64SYS) -g
C64LDFLAGS?=-Ln 8192.lbl -m 8192.map -Csrc/8192.cfg

8192_OBJS:=$(addprefix obj/,autoboot.o zp.o charset.o irq.o screen.o \
	main.o)
8192_BIN:=8192.prg
8192_DISK:=8192.d64

all: $(8192_DISK)

$(8192_DISK): $(8192_BIN)
	$(MKD64) -o$@ -mcbmdos -d'8192 GAME' -i'ZPROD' -R1 -Da0 -0 \
		-f$< -n'8192' -S1 -w

$(8192_BIN): $(8192_OBJS)
	$(C64LD) -o$@ $(C64LDFLAGS) $^
	cat >$@ $@_boot $@_code

obj:
	mkdir obj

obj/%.o: src/%.s src/8192.cfg Makefile | obj
	$(C64AS) $(C64ASFLAGS) -o$@ $<

clean:
	rm -fr obj *.lbl *.map

distclean: clean
	rm -f $(8192_DISK) $(8192_BIN)*

.PHONY: all clean distclean

