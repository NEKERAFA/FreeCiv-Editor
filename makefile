all: generate.lua parser.lua translator.lua
	lua ./generate.lua

%.lua: %.moon
	moonc $<

clean:
	rm -f *.lua *.sav
