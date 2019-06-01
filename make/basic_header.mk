# (c) Texas Instruments 

ifndef $(BASIC_HEADER_MK)
BASIC_HEADER_MK = 1

CUR_DIR=$(shell pwd)
CUR_DIR_NAME=$(shell pwd | sed 's,^\(.*/\)\?\([^/]*\),\2,')
OBJPREFIX=$(subst /,_,$(subst ${TOPDIR}/,,${CUR_DIR}))
obj-y:=#targets:xxx.c,xxx.cpp,xxx.S
TARGET=objs#compile this as lib or share or bin
CFLAGS-y:=$(SYSROOT)#c flag
CPPFLAGS-y:=$(SYSROOT)#cpp flag
LDFLAGS-y:=$(SYSROOT)#clear

ifndef V
Q:=@
else
Q:=
endif

BUILD_OUTPUT_DIR?=${TOPDIR}/build/${PRJ}/${APP}
FILE_OBJS?=$(dir $(BUILD_OBJ_DIR)).${CUR_DIR_NAME}_objs
FILE_OBJS_RECREATED?=
BUILD_OBJ_DIR?=$(subst ${TOPDIR}/,${TOPDIR}/build/${PRJ}/${APP}/,${CUR_DIR})

endif # ifndef $(BASIC_HEADER_MK)

