GCC=g++
FLAGS=-std=c++11 -g
OBJDIR=./obj

_OBJS=argconverters.o argstore.o argregistrar.o
OBJS=$(patsubst %,${OBJDIR}/%,${_OBJS})

argstore_tester: argstore_tester.cpp ${OBJS}
	$(GCC) -o argstore_tester ${FLAGS} argstore_tester.cpp ${OBJS}

clean:
	rm ${OBJS}
	rm argstore_tester

${OBJDIR}/argconverters.o: argconverters.h argconverters.cpp
	$(GCC) -c ${FLAGS} argconverters.cpp -o $@

${OBJDIR}/argstore.o: argstore.h argstore.cpp
	$(GCC) -c ${FLAGS} argstore.cpp -o $@

${OBJDIR}/argregistrar.o: argregistrar.h argregistrar.cpp
	$(GCC) -c ${FLAGS} argregistrar.cpp -o $@
