# Rafael Alcalde Azpiazu - 01 Feb 2018
# Facultade de Informática da Coruña - Universidade da Coruña
#
# Makefile for create the proyect

all: run

install:
	sudo apt install luarocks
	sudo luarocks install busted
	sudo add-apt-repository ppa:bartbes/love-stable
	sudo apt update
	sudo apt install love

run:
	love src

test:
	busted

clean:
	rm -f *.sav
