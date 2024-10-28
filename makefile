ASMBUILD = nasm -f elf64 -g -o 
.PHONY: run
.PHONY: build
.PHONY: test
.PHONY: all
.PHONY: clean
lib.o: lib.asm 
	$(ASMBUILD) $@ $< 
main.o: main.asm dict.inc lib.inc 
	$(ASMBUILD) $@ $< 
dict.o: dict.asm words.inc colon.inc lib.inc
	$(ASMBUILD) $@ $<
prog: main.o lib.o dict.o
	ld -o prog main.o lib.o dict.o
run: prog
	./$<
build: prog
test: prog
	python2 test.py
clean: 
	rm *.o
all: build clean
