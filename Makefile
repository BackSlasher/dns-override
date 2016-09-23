.PHONY: clean test

all: clean dns-override.so test

dns-override.so: dns-override.c
	gcc -Wall -Werror -fPIC -shared -o dns-override.so dns-override.c -ldl

clean:
	rm *.so

test: dns-override.so
	bats *.bats
