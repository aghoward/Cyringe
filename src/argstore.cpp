#include <iostream>
#include <string>
#include <map>
#include <typeinfo>

#include "argstore.h"
#include "argconverters.h"

using namespace std;

ArgumentStore::ArgumentStore() {
    conversionMap = map<size_t, long*>();
    values = map<string, string>();

    RegisterConverters();
}

string * ArgumentStore::GetRawValue(string key) {
#ifdef DEBUG
    cout << "Getting raw value for key: " << key << " '";
#endif
    if (!values.count(key))
        return NULL;
#ifdef DEBUG
    cout << values[key] << "'" << endl;
#endif
    return &(values[key]);
}

void ArgumentStore::PutValue(string key, string value) {
#ifdef DEBUG
    cout << "Putting value(" << value << ") in raw store for key: " << key << endl;
#endif
    values[key] = value;
}

void ArgumentStore::RegisterConverters() {
    AddConverter(&convert_int);
    AddConverter(&convert_string);
    AddConverter(&convert_long);
    AddConverter(&convert_char);
    AddConverter(&convert_bool);
}
