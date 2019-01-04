/*******************************************************************************
 Workfile:      os_common.h
 Revision:      1.00
 Last Modtime:  2012-6-5
 Author:        hunter.fang
 Description:

 *******************************************************************************/
 
#ifndef OS_COMMON_H_
#define OS_COMMON_H_
#include "os_debug.h"
 
#ifndef TRUE
#define TRUE 	(0)
#endif
#ifndef FALSE
#define FALSE (1)
#endif

#define OS_OK               (0)
#define OS_FAIL             (1)

#define BIT_HIGH            1
#define BIT_LOW             0

#define OS_ON 	            BIT_HIGH
#define OS_OFF 	            BIT_LOW
 
#define OS_memcpy           memcpy
#define OS_memset           memset

#define OS_EFAIL            -1
#define OS_TIMEOUT_NONE     2
#define OS_TIMEOUT_FOREVER  1

#define OS_MIN(X,Y) ({ \
  typeof (X) x_ = (X); \
  typeof (Y) y_ = (Y); \
  (x_ < y_) ? x_ : y_; })
 
#define OS_MAX(X,Y) ({ \
  typeof (X) x_ = (X); \
  typeof (Y) y_ = (Y); \
  (x_ > y_) ? x_ : y_; })
 
#define offsetof(TYPE, MEMBER)  ((size_t) & ((TYPE *)0)->MEMBER)
#define OS_align(value, align)  ((( (value) + ( (align) - 1 ) ) / (align) ) * (align) )
 
#define container_of(ptr, type, member) ({ \
        const typeof( ((type *)0)->member ) *__mptr = (ptr); \
        (type *)( (char *)__mptr - offsetof(type,member) );})
 
#endif /* OS_COMMON_H_ */
