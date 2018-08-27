# Rafael Alcalde Azpiazu - 01 Feb 2018
# Facultade de Informática da Coruña - Universidade da Coruña
#
# Makefile for create the proyect

all: run

install:
	sudo add-apt-repository ppa:bartbes/love-stable
	sudo apt-get update
	sudo apt-get install gringo clasp lua5.3 love luarocks
	sudo luarocks install busted

run:
	cd src
	love ./

test:
	busted

clean:
	rm -f *.sav
