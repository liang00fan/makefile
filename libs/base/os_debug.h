/*******************************************************************************
 Workfile:      os_debug.h
 Revision:      1.00
 Last Modtime:  2012-6-5
 Author:        hunter.fang
 Description:

 *******************************************************************************/

#ifndef OS_DEBUG_H_
#define OS_DEBUG_H_
#include "os_common.h"
 
//#define OS_DEBUG_MODE

#define OS_printf(...)          printf(__VA_ARGS__)
#define OS_putc(...)            printf("%c",__VA_ARGS__)

/*enable debug message*/
#ifdef OS_DEBUG_MODE
#define OS_debug                OS_printf("(%s|%d)\n", __func__, __LINE__)
#define OS_debug_char(...)      OS_putc(__VA_ARGS__)
#define OS_debug_msg(...)       OS_printf(__VA_ARGS__)
#define OS_assert(x)    \
    if(!(x)) \
    {\
        OS_printf("A:"); \
        OS_debug; \
    }
#else   //#ifdef OS_DEBUG_MODE
#define OS_debug
#define OS_debug_char(...)
#define OS_debug_msg(...)
#define OS_assert(...)
#endif

#define OS_ERROR(...) \
     do{\
      OS_debug; \
      OS_printf("ERROR:");\
      OS_printf(__VA_ARGS__);\
      OS_printf("\n");\
    }while(0)

#endif /* OS_DEBUG_H_ */
