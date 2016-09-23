.PHONY: clean test

all: clean *.so test

dns-override.so: dns-override.c
	gcc -Wall -Werror -fPIC -shared -o dns-override.so dns-override.c -ldl

clean:
	rm *.so

test: *.so
	bats *.bats
