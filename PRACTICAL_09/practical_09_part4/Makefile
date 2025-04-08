EXECUTABLE=Ariel_C.exe

all:
	nasm -f elf add.asm -o add.o -l starter.lst
	nasm -f elf sub.asm -o sub.o
	gcc -m32 -c main.c
	gcc -m32 main.o add.o sub.o -o $(EXECUTABLE)
	./$(EXECUTABLE)

#Clean folder
clean:
	rm -rf *o *.lst $(EXECUTABLE)