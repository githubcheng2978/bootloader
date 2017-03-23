
CC=gcc
LD=ld
OBJCOPY=objcopy

all: boot.img

boot.img: boot.bin init32_s.bin
#	@dd if=boot.bin of=boot.img bs=512
	@dd if=boot.bin of=boot.img bs=512 count=1
	@dd if=/dev/zero of=boot.img skip=1 seek=1 bs=512 count=2879
	@cp boot.img fufuos/boot/boot.img
	@make -C ./fufuos
#	@cd fufuos
#	@./make_boot_iso
#	@cd ..
init32_s.bin: init32_s.elf
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary init32_s.elf init32_s.bin

init32_s.elf: init32_s.o
	$(LD) init32_s.o -o init32_s.elf -e c -T loader.ld

init32_s.o:init32_s.S
	$(CC) -c init32_s.S 

boot.bin: boot.elf
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary boot.elf boot.bin

boot.elf: boot.o
	$(LD) boot.o -o boot.elf -e c -T fufuos.ld

boot.o: boot.S
	$(CC) -c boot.S 

copy: boot.img

clean: 
	@rm -f boot.o boot.elf boot.bin init32_s.o init32_s.elf init32_s.bin

distclean: clean
	@rm -f boot.img

release: clean
	@cp boot.img fufuos/boot/boot.img
	@bash fufuos/make_boot_iso
