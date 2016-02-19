#include <iostream>
#include <string>

#include "argconverters.h"

using namespace std;

int convert_int(string value) {
    return stoi(value, NULL, 0);
}

long convert_long(string value) {
    return stol(value, NULL, 0);
}

string convert_string(string value) {
    return string(value);
}

char convert_char(string value) {
    return value.at(0);
}

bool convert_bool(string value) {
    return !value.empty();
}
