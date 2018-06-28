#ifndef _DEBUG_H_
#define _DEBUG_H_

#include <stdio.h>

#define _DEBUG_
#ifdef _DEBUG_
#define debug(format,...) printf("DEBUG:"__FILE__",%d,%s:>"format,__LINE__,__func__,##__VA_ARGS__)
//#define debug(format) cout << "DEBUG:" << __FILE__ << ","<< __LINE__ <<"L,"<< __func__ <<":>" << format << endl;
#else
#define debug(format,...)
#endif

#endif
