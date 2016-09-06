all: libAttach.so

libAttach.so: libAttach.o
	gcc -shared -o libAttach.so libAttach.o

libAttach.o: attach.c
	gcc -Wall -g -fPIC -c -I/home/equi/.rvm/rubies/ruby-2.3.1/include/ruby-2.3.0 -I/home/equi/.rvm/rubies/ruby-2.3.1/include/ruby-2.3.0/x86_64-linux/ attach.c -o libAttach.o

clean:
	rm libAttach.*
