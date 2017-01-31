CC?=gcc

.PHONY: clean test

all: clean dns-override.so test

dns-override.so: dns-override.c
	$(CC) -Wall -Werror -fPIC -shared -o dns-override.so dns-override.c -ldl

clean:
	rm -rf *.so

test: dns-override.so
	bats *.bats
