GCC=g++
FLAGS=-std=c++11 -g

argconverters.o: argconverters.h argconverters.cpp
	$(GCC) -c ${FLAGS} argconverters.cpp

argstore.o: argstore.h argstore.cpp
	$(GCC) -c ${FLAGS} argstore.cpp

argstore_tester: argstore_tester.cpp argstore.o argconverters.o
	$(GCC) -o argstore_tester ${FLAGS} argstore_tester.cpp argconverters.o argstore.o


