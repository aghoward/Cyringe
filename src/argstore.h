#include <iostream>
#include <string>
#include <map>
#include <typeinfo>

using namespace std;

class ArgumentStore {
    public:
        ArgumentStore();

        template <typename T> T GetValue(string key) {
            auto converter = GetConverter<T>(typeid(T).hash_code());
            if (converter == NULL)
                return NULL;

            auto rawValue = GetRawValue(key);
            if (rawValue == NULL)
                return NULL;

            return converter(*rawValue);
        }

        void PutValue(string key, string value);
        
        template <typename T> void AddConverter(T (*converter)(string)) {
#ifdef DEBUG
            cout << "Adding conversion function (" << (long*)converter << ") with code " << typeid(T).hash_code() << endl;
#endif
            conversionMap[typeid(T).hash_code()] = (long*)converter;
        }

    private:
        map<size_t, long*> conversionMap;
        map<string, string> values;

        template <typename T> T (*GetConverter(size_t key)) (string) {
#ifdef DEBUG
            cout << "Getting conversion function for key " << key;
#endif
            if (!conversionMap.count(key))
                return NULL;
#ifdef DEBUG
            cout << " at location (" << conversionMap[key] << ")" << endl;
#endif
            return (T (*)(string))conversionMap[key];
        }

        string * GetRawValue(string key);
        void RegisterConverters();

};
