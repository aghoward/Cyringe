#include <iostream>
#include <string>
#include <map>

#include "argregistrar.h"

using namespace std;

string GetKeyByValue(string value, map<string, string> mapping) {
    for (auto it = mapping.begin(); it != mapping.end(); it++) {
        if (it->second == value)
            return it->first;
    }

    return string();
}

int GetKeyByValue(string value, map<int, string> mapping) {
    for (auto it = mapping.begin(); it != mapping.end(); it++) {
        if (it->second == value)
            return it->first;
    }

    return -1;
}

ArgumentRegistrar::ArgumentRegistrar() {
    descriptions = map<string, string>();
    positions = map<int, string>();
    shortForms = map<string, string>();
    longForms = map<string, string>();
    argumentTypes = map<string, string>();
    argumentTypeDescriptions = map<string, string>();
}

string ArgumentRegistrar::GetShortFormByName(string shortForm) {
    if (!shortForms.count(shortForm))
        return string();

    return shortForms[shortForm];
}

string ArgumentRegistrar::GetNameByShortForm(string name) {
    return GetKeyByValue(name, shortForms);
}

string ArgumentRegistrar::GetLongFormByName(string longForm) {
    if (!longForms.count(longForm))
        return string();

    return longForms[longForm];
}

string ArgumentRegistrar::GetNameByLongForm(string name) {
    return GetKeyByValue(name, longForms);
}

string ArgumentRegistrar::GetNameByPosition(int position) {
    if (!positions.count(position))
        return string();

    return positions[position];
}

int ArgumentRegistrar::GetPositionByName(string name) {
    return GetKeyByValue(name, positions);
}

string ArgumentRegistrar::GetArgumentTypeByName(string name) {
    if (!argumentTypes.count(name))
        return string();

    return argumentTypes[name];
}

string ArgumentRegistrar::GetArgumentTypeDescriptionByName(string name) {
    if (!argumentTypeDescriptions.count(name))
        return string();

    return argumentTypeDescriptions[name];
}

string ArgumentRegistrar::GetNameByParameter(string parameter) {
    auto name = GetNameByShortForm(parameter);
    if (!name.empty())
        return name;
    return GetNameByLongForm(parameter);
}

bool ArgumentRegistrar::HasParameter(string name) {
    return argumentTypes.count(name) != 0;
}

void ArgumentRegistrar::RegisterArgument(string name, string description, int position) {
    descriptions[name] = description;
    positions[position] = name;
}

void ArgumentRegistrar::RegisterArgument(string name, string description, string shortForm, string longForm) {
    descriptions[name] = description;
    shortForms[name] = shortForm;
    if (!longForm.empty())
        longForms[name] = longForm;
}

void ArgumentRegistrar::RegisterArgument(
        string name,
        string description,
        string argumentType,
        string argumentTypeDescription,
        string shortForm,
        string longForm) {
    descriptions[name] = description;
    argumentTypes[name] = argumentType;
    argumentTypeDescriptions[name] = argumentTypeDescription;
    shortForms[name] = shortForm;
    if (!longForm.empty())
        longForms[name] = longForm;
}

string ArgumentRegistrar::GetPrintableDescriptions() {
    auto ret = string();

    for (auto posIt = positions.begin(); posIt != positions.end(); posIt++) {
        ret += string("\t");
        auto key = posIt->second;
        ret += key + string("\t") + descriptions[key] + string("\n\n");
    }


    for (auto posIt = shortForms.begin(); posIt != shortForms.end(); posIt++) {
        auto key = posIt->first;
        ret += string("\t") + posIt->second;
        
        auto longForm = GetLongFormByName(key);
        if (!longForm.empty())
            ret += string(", ") + longForm;

        auto argumentType = GetArgumentTypeByName(key);
        if (!argumentType.empty()) {
            ret += string(" <") + argumentType + string(">");
        }

        ret += string("\t") + descriptions[key];
        if (!argumentType.empty())
            ret += string("\n\t\t") + GetArgumentTypeDescriptionByName(key);

        ret += string("\n\n");
    }

    return ret;
}

string ArgumentRegistrar::GetUsages() {
    auto ret = string();

    for (auto posIt = positions.begin(); posIt != positions.end(); posIt++) {
        ret += string("<") + posIt->second + string("> ");
    }

    for (auto it = shortForms.begin(); it != shortForms.end(); it++) {
        auto shortForm = it->second;
        auto key = it->first;
        auto longForm = GetLongFormByName(key);
        auto argType = GetArgumentTypeByName(key);

        ret += string("[") + shortForm; 
        if (!longForm.empty())
            ret += string("|") + longForm;

        if (!argType.empty())
            ret += string(" ") + argType;

        ret += string("] ");
    }

    return ret;
}
