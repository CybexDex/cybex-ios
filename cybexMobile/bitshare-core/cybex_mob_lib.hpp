#ifndef CYBEX_MOB_LIB_HPP
#define CYBEX_MOB_LIB_HPP

#include <string>
using namespace std;

extern string get_user_key(string user_name, string password);
extern string call_method(string json);

#endif
