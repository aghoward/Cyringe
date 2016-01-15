#include <string.h>
#include <string>
#include <map>
#include <cstdio>
#include <unistd.h>
#include <sys/mman.h>
#include <type_traits>


using namespace std;

class ArgumentParser {
    public:
        ArgumentParser();
        ~ArgumentParser();
        //template<typename Type> void RegisterArgument(string name, string shortName, Type defaultValue = NULL);
        //template<typename Type> Type GetValue(string name);

        template<typename Type> void RegisterArgumentValue(string name, string shortName, Type defaultValue = NULL) {
            this->argumentStore[name] = this->SaveObjectToMemory(defaultValue);
            this->FinalizeRegistration(name, shortName, defaultValue);

        }

        template<typename Type> void RegisterArgumentReference(string name, string shortName, Type defaultValue = NULL, int actualSize = 0) {
            this->argumentStore[name] = this->SaveReferenceToMemory(defaultValue, actualSize);
            this->FinalizeRegistration(name, shortName, defaultValue);

        }

        template<typename Type> void FinalizeRegistration(string name, string shortName, Type defaultValue = NULL) {
            this->sizeStore[name] = sizeof(defaultValue);

            if (shortName.empty())
                this->shortStore[shortName] = name;
        }


        template<typename Type> Type GetValue(string name) {
            if (this->MapContainsKey(this->shortStore, name))
                name = this->shortStore[name];

            if (!this->MapContainsKey(this->argumentStore, name))
                return NULL;

            return (Type)*(this->argumentStore[name]);
        }

        template<typename Type> Type GetReference(string name) {
            if (this->MapContainsKey(this->shortStore, name))
                name = this->shortStore[name];

            if(!this->MapContainsKey(this->argumentStore, name))
                return NULL;

            return (Type)(this->argumentStore[name]);
        }


    private:
        map<string, long*> argumentStore;
        map<string, string> shortStore;
        map<string, size_t> sizeStore;

        //template<typename ValueType> bool MapContainsKey(map<string, ValueType> mapping, string key);
        //template<typename Type> long * SaveObjectToMemory(Type obj);

        template<typename ValueType> bool MapContainsKey(map<string, ValueType> mapping, string key) {
            auto comparer = mapping.key_comp();
            auto iter = mapping.begin();

            while (iter != mapping.end()) {
                if (iter->first == key)
                    return true;
                iter++;
            }

            return false;
        }

        template<typename Type> long * SaveObjectToMemory(Type obj) {
            auto memorySize = sizeof(obj);
            long * addr = (long*)mmap(NULL, memorySize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

            *addr = obj;

            return addr;
        }

        template<typename Type> long * SaveReferenceToMemory(Type obj, int actualSize = 0) {
            auto memorySize = (actualSize == 0) ? sizeof(*obj) : actualSize;
            long * addr = (long*)mmap(NULL, memorySize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

            memcpy(addr, obj, memorySize);

            return addr;
        }

};
