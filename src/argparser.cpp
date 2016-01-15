/**
 * Argument Parsing made easier...
**/

#include <unistd.h>
#include <string>
#include <map>
#include <sys/mman.h>

#include "argparser.h"

using namespace std;

ArgumentParser::ArgumentParser() {
    this->argumentStore = map<string, long*>();
    this->shortStore = map<string, string>();
}

ArgumentParser::~ArgumentParser() {
    auto iter = this->argumentStore.begin();

    while (iter != this->argumentStore.end()) {
        auto key = iter->first;
        auto size = this->sizeStore[key];
        munmap(this->argumentStore[key], size);
        iter++;
    }
}
/*
template<typename Type> void ArgumentParser::RegisterArgument(string name, string shortName, Type defaultValue) {
    this->argumentStore[name] = this->SaveObjectToMemory(defaultValue);
    this->sizeStore[name] = sizeof(defaultValue);

    if (shortName.empty())
        this->shortStore[shortName] = name;
}


template<typename Type> Type ArgumentParser::GetValue(string name) {
    if (this->MapContainsKey(this->shortStore, name))
        name = this->shortStore[name];

    if (!this->MapContainsKey(this->argumentStore, name))
        return NULL;

    return (Type)*this->argumentStore[name];
}


template<typename ValueType> bool ArgumentParser::MapContainsKey(map<string, ValueType> mapping, string key) {
    auto comparer = mapping.key_comp();
    auto last = mapping.rbegin()->first;
    auto iter = mapping.begin();

    while ((*iter).first != last) {
        if (*(iter.first)  == key)
            return true;
        iter++;
    }

    return false;
}

template<typename Type> long * ArgumentParser::SaveObjectToMemory(Type obj) {
    auto memorySize = sizeof(obj);
    long * addr = (long*)mmap(NULL, memorySize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

    *addr = obj;

    return addr;
}

*/
