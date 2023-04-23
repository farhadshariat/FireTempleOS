FILES = ./build/kernel.asm.o ./build/kernel.o ./build/idt/idt.asm.o ./build/idt/idt.o ./build/memory/memory.o ./build/io/io.asm.o
INCLUDES = -I./src
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

###NOTES : -nostdlib because we are going to implement our standard libarary for our own OS

#2: remove our previous built os.bin
#3: concat our boot flat binary into os.bin
#4: concat our kernel flat binary into os.bin
#5: allocate 0 to 512(BYTE)* 100(ENOUGH-SIZE) and then concat it into os.bin
all: ./bin/boot.bin	./bin/kernel.bin
	rm -rf ./bin/os.bin					
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin
#Creating kernel.bin
#2:build our kernel.asm.o into kernelfull object with our cross compiler linker(x.o x1.o x2.o => xfull.o)
#3:build our kernel.bin with kernelfull object with our own linker script (x.o x1.o x2.o => xfull.o)
./bin/kernel.bin: ${FILES}
	i686-elf-ld -g -relocatable ${FILES} -o ./build/kernelfull.o
	i686-elf-gcc ${FLAGS} -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o
#Creating boot.bin
./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

#Creating kernel
./build/kernel.asm.o: ./src/kernel.asm
	nasm -f elf -g $< -o $@

./build/kernel.o: ./src/kernel.c
	i686-elf-gcc ${INCLUDES} ${FLAGS} -std=gnu99 -c $< -o $@

#Creating idt
./build/idt/idt.asm.o: ./src/idt/idt.asm
	nasm -f elf -g $< -o $@

./build/idt/idt.o: ./src/idt/idt.c
	i686-elf-gcc ${INCLUDES} -I./src/idt -I./src/memory ${FLAGS} -std=gnu99 -c $< -o $@

#Creating memory
./build/memory/memory.o: ./src/memory/memory.c
	i686-elf-gcc ${INCLUDES} -I./src/memory ${FLAGS} -std=gnu99 -c $< -o $@

#Creating io
./build/io/io.asm.o: ./src/io/io.asm
	nasm -f elf -g $< -o $@

vm:
	qemu-system-x86_64 -hda ./bin/os.bin

bless:
	bless ./bin/os.bin

clean:
	rm -rf ./bin/*.bin
	rm -rf ./build/*.o
	rm -rf ${FILES}