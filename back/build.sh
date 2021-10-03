nasm -f bin -o boot.bin boot.asm
nasm -f bin -o loader.bin loader.asm

dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
dd if=loader.bin of=boot.img bs=512 count=10 seek=1 conv=notrunc