# Rafael Alcalde Azpiazu - 01 Feb 2018
# Facultade de Informática da Coruña - Universidade da Coruña
#
# Makefile for create the proyect

all: install run

install:
	sudo apt-get install luarocks
	sudo luarocks install busted loverocks

run:
	love src

test:
	busted

clean:
	rm -f *.sav
