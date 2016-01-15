#include <iostream>
#include <string>
#include "argparser.h"

using namespace std;

int main(int argc, char * argv[]) {
    ArgumentParser args = ArgumentParser();
    args.RegisterArgumentValue(string("bool"), "", true);
    args.RegisterArgumentValue(string("int"), "", 1024);
    args.RegisterArgumentReference(string("string"), "", "Hello Motto...", 14);

    bool defaultValue = args.GetValue<bool>(string("bool"));
    int intValue = args.GetValue<int>(string("int"));
    auto strValue = args.GetReference<char *>(string("string"));

    cout << "bool: " << defaultValue << endl;
    cout << "int: " << intValue << endl;
    cout << "string: " << strValue << endl;

    return 0;
}
