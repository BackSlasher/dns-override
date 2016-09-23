
dns-override.so: dns-override.c
	gcc -Wall -Werror -fPIC -shared -o dns-override.so dns-override.c -ldl
