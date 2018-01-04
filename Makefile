C64SYS?=c64
C64AS?=ca65
C64LD?=ld65
MKD64?=mkd64
EXO?=exomizer

C64ASFLAGS?=-t $(C64SYS) -g
C64LDFLAGS?=-Ln 8192.lbl -m 8192.map -Csrc/8192.cfg

CC?=gcc
CFLAGS?=-std=c11 -Wall -Wextra -pedantic -O3 -g0

MPMC2ZBB:=tools/mpmc2zbb

ifdef DEBUG
C64ASFLAGS+=-DDEBUG
endif

8192_OBJS:=$(addprefix obj/,autoboot.o diskio.o decr.o zp.o charset.o irq.o \
	title.o random.o numconv.o jsinput.o keyboard.o kbinput.o dirinput.o \
	pitches.o instruments.o tunes.o sound.o screen.o board.o menu.o \
	state.o main.o)
8192_BOOTBINS:=8192_boot.bin 8192_load.bin
8192_MAINBINS:=8192_tcode.bin 8192_tbmp.bin 8192_code.bin
8192_STATEBIN:=8192_persist.bin
8192_BINS:=$(8192_BOOTBINS) $(8192_MAINBINS) $(8192_STATEBIN)
8192_EXOS:=$(8192_MAINBINS:.bin=.exo)
8192_PRG:=8192.prg
8192_ARCH:=8192.exa
8192_DISK:=8192.d64

all: $(8192_DISK)

$(8192_DISK): $(8192_PRG) $(8192_ARCH) $(8192_STATEBIN)
	$(MKD64) -o$@ -mcbmdos -d'8192 GAME' -i'ZPROD' -R1 -Da0 -0 \
		-f$(8192_PRG) -n'8192' -S1 -w \
		-f$(8192_STATEBIN) -n'8192DATA' -TU -S0 -i15 -w \
		-f$(8192_ARCH) -n'8192MAIN' -TU -S0 -i15 -w

$(8192_PRG): $(8192_BOOTBINS)
	cat >$@ $^

$(8192_ARCH): $(8192_EXOS)
	cat >$@ $^

%.exo: %.bin
	$(EXO) raw -c -m 2048 -o$@ $<

%.bin: $(8192_OBJS)
	$(C64LD) -o8192 $(C64LDFLAGS) $^

8192_tbmp.bin: multipaint/title.txt $(MPMC2ZBB)
	$(MPMC2ZBB) <$< >$@

obj:
	mkdir obj

obj/%.o: src/%.s src/8192.cfg Makefile | obj
	$(C64AS) $(C64ASFLAGS) -o$@ $<

$(MPMC2ZBB): tools/mpmc2zbb.c
	$(CC) -o$@ $(CFLAGS) $<

clean:
	rm -fr obj *.lbl *.map *.bin

distclean: clean
	rm -f $(8192_DISK) $(MPMC2ZBB) *.prg *.exa *.exo

.PHONY: all clean distclean
.PRECIOUS: $(8192_OBJS) $(8192_BINS)

