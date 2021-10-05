all:
	gcc -Wall -fPIC -I./include -I./include/axiom -o libnewrelic.o -c libnewrelic.c
	ld -shared -o libnewrelic.so libnewrelic.o

#client:
#	gcc  client.c -fPIC -Wall -Wl,-rpath=. -I./include -L. -lnewrelic -o client
