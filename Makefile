#! /usr/bin/make -f

all:
	ocamlbuild -yaccflag -v -lib unix main.native #on dit de fabriquer main.native

byte:
	ocamlbuild -yaccflag -v main.byte

clean:
	ocamlbuild -clean
