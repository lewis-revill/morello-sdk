CC=clang
ELF_PATCH=morello_elf
CMP=cmp -l
GAWK=gawk

OUT=../bin

all:
	mkdir -p $(OUT)
	$(CC) -c -g -nostdinc -isystem ../musl-bin/include \
		-march=morello+c64 -mabi=purecap main.c -o $(OUT)/main.c.o
	$(CC) -fuse-ld=lld -Wl,--morello-c64-plt \
		../musl-bin/lib/crt1.o \
		../musl-bin/lib/crti.o \
		../llvm/lib/clang/11.0.0/lib/linux/clang_rt.crtbegin-morello.o \
		$(OUT)/main.c.o \
		../llvm/lib/clang/11.0.0/lib/linux/clang_rt.crtend-morello.o \
		../musl-bin/lib/crtn.o \
		-nostdlib -L../musl-bin/lib -lc -lm -lgcc -o $(OUT)/main -static
	$(ELF_PATCH) $(OUT)/main

clean:
	rm $(OUT)/main.c.o
	rm $(OUT)/main
