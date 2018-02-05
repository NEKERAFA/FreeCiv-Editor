# Rafael Alcalde Azpiazu - 01 Feb 2018
# Facultade de Informática da Coruña - Universidade da Coruña
#
# Makefile for create the proyect

all: generator.lua parser.lua translator.lua
	lua ./generator.lua -n=Test

%.lua: %.moon
	moonc $<

clean:
	rm -f *.lua *.sav
