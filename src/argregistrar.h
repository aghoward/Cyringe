#include <iostream>
#include <string>
#include <map>

using namespace std;

class ArgumentRegistrar {
    private: 
        map<string, string> descriptions;
        map<int, string> positions;
        map<string, string> shortForms;
        map<string, string> longForms;
        map<string, string> argumentTypes;
        map<string, string> argumentTypeDescriptions;

        string GetNameByShortForm(string shortForm);
        string GetNameByLongForm(string longForm);
        string GetShortFormByName(string name);
        string GetLongFormByName(string name);
        int GetPositionByName(string name);
        string GetArgumentTypeByName(string name);
        string GetArgumentTypeDescriptionByName(string name);

    public:
        ArgumentRegistrar();

        void RegisterArgument(
            string name,
            string description,
            int position
        );

        void RegisterArgument(
            string name,
            string description,
            string shortForm,
            string longForm
        );

        void RegisterArgument(
            string name,
            string description,
            string argumentType,
            string argumentTypeDescription,
            string shortForm,
            string longForm
        );


        string GetNameByPosition(int position);
        string GetNameByParameter(string parameter);

        bool HasParameter(string name);

        string GetPrintableDescriptions();
        string GetUsages();
};
