cwd=$(shell pwd)

messages.mo:  messages.po
	@echo "\tCompiling ${cwd}/$<"
	@msgfmt -f $<


all:  messages.mo
