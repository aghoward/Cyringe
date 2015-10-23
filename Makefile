GPP=g++
GCC=gcc
CONV=tools/otosc.sh

ASMDir=./assemblies
OBJDir=./obj

cyringe: cyringe.cpp
	$(GPP) -o $@ $@.cpp

clean:
	rm ${OBJDir}/* cyringe


%:
	$(GCC) -c -o ${OBJDir}/$@.o ${ASMDir}/$@.s
	$(CONV) ${OBJDir}/$@.o ${OBJDir}/$@.sc
