#
#compile:
#VERSION=1 SUBLEVEL=0 PATCHLEVEL=1 PRJ=demo_config APP=demo make
#
VERSION ?= 1
SUBLEVEL ?= 4
PATCHLEVEL ?= 3
PRJ ?= main
APP ?= src

ifndef RELEASE
GLOBAL_CFLAGS := -g
else
GLOBAL_CFLAGS :=
endif

##################################################
SDKRELEASE=$(VERSION).$(SUBLEVEL).$(PATCHLEVEL)
CONFIG_SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
	else if [ -x /bin/bash ]; then echo /bin/bash; \
	else echo sh; fi ; fi)
TOPDIR	:= $(shell /bin/pwd)

SDKPATH         = $(TOPDIR)/include
HOSTCC          = gcc
HOSTCFLAGS      = -Wall -Wstrict-prototypes -O2 -fomit-frame-pointer
CROSS_COMPILE   = 
#
# Include the make variables (CC, etc...)
#
AS              = $(CROSS_COMPILE)as
LD              = $(CROSS_COMPILE)ld
CC              = $(CROSS_COMPILE)gcc
CPP             = $(CROSS_COMPILE)c++
AR              = $(CROSS_COMPILE)ar
NM              = $(CROSS_COMPILE)nm
STRIP           = $(CROSS_COMPILE)strip
OC      		= $(CROSS_COMPILE)objcopy
OBJDUMP         = $(CROSS_COMPILE)objdump
RANLIB			= $(CROSS_COMPILE)ranlib
OD      		= $(CROSS_COMPILE)objdump
MD5SUM			= md5sum
PERL            = perl
AWK				= awk
GLOBAL_CFLAGS 	+=-I. -I${TOPDIR}/include -I$(TOPDIR)/libs -Wall
GLOBAL_LDFLAGS	:= #clear
export  CONFIG_SHELL TOPDIR SDKPATH HOSTCC HOSTCFLAGS CROSS_COMPILE AS LD CC \
	CPP AR NM STRIP OC OBJDUMP MAKE MAKEFILES MD5SUM PERL AWK \
	GLOBAL_CFLAGS GLOBAL_LDFLAGS

BINARY=$(TOPDIR)/build/${PRJ}/${APP}.bin
FULLOBJ=$(TOPDIR)/build/${PRJ}/${APP}.ba2
MMOBJ=$(TOPDIR)/build/${PRJ}/${APP}.map

export PRJ APP BINARY

all:ram
	
ram:$(TOPDIR)/include/version.h $(TOPDIR)/include/compile.h $(TOPDIR)/include/config.h dummy
	$(MAKE) -C $(TOPDIR)/$@/
#
# Create config.h for each app
#
$(TOPDIR)/build/${PRJ}/${APP}/config/autoconfig.h:dummy
	@echo "  [GE] $@"
	@touch $@

$(TOPDIR)/include/config.h:
	@touch $@
	
$(TOPDIR)/include/compile.h: $(TOPDIR)/include/version.h
	@echo -n \#define UTS_VERSION \"\#$(SDKRELEASE) > .ver
	@if [ -f .name ]; then  echo -n \-`cat .name` >> .ver; fi
	@echo ' '`date`'"' >> .ver
	@echo \#define SDK_COMPILE_TIME \"`date +%T`\" >> .ver
	@echo \#define SDK_COMPILE_BY \"`whoami`\" >> .ver
	@echo \#define SDK_COMPILE_HOST \"`hostname`\" >> .ver
	@if [ -x /bin/dnsdomainname ]; then \
	   echo \#define SDK_COMPILE_DOMAIN \"`dnsdomainname`\"; \
	 elif [ -x /bin/domainname ]; then \
	   echo \#define SDK_COMPILE_DOMAIN \"`domainname`\"; \
	 else \
	   echo \#define SDK_COMPILE_DOMAIN ; \
	 fi >> .ver
	@echo \#define SDK_COMPILER \"`$(CC) $(CFLAGS) -v 2>&1 | tail -1`\" >> .ver
	@mv -f .ver $@

$(TOPDIR)/include/version.h:Makefile
	@if [ -f .svn/entries ] ; then \
        	echo "#define FW_VERSION `svn info . | grep "Last Changed Rev" | sed -e "s/^.*: //g"`" >> .ver; \
    	else \
        	echo "#define FW_VERSION 0" >> .ver; \
    	fi;
	@echo \#define SDK_RELEASE \"$(SDKRELEASE)\" >> .ver
	@echo \#define SDK_VERSION_CODE `expr $(VERSION) \\* 65536 + $(SUBLEVEL) \\* 256 + $(PATCHLEVEL)` >> .ver
	@echo '#define SDK_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))' >>.ver
	@mv -f .ver $@

CLEAN_PATH="$(TOPDIR)/build/$(PRJ)/$(APP)"

CLEAN_FILES = ${BINARY} ${FULLOBJ} ${MMOBJ}
clean:dummy
	@echo "--clean $(subst $(TOPDIR)/,,$(CLEAN_PATH))"
	@if [ -d ${CLEAN_PATH} ]; then  \
		find ${CLEAN_PATH} \( -name "*.o" \
					-o -name "*.bin" \
					-o -name "*.or32" \
					-o -name "*.map" \
					-o -name "ar.mac" \
					-o -name "*.a" \
					-o -name "*.init_internal" \
					-o -name "*.d.tmp" \
					-o -name "*.d" \) -type f -print \
					| xargs rm -f ;\
	fi
	@if [ -d $(TOPDIR)/build/$(PRJ)/share ]; then  \
		find $(TOPDIR)/build/$(PRJ)/share \( -name "*.o" \
					-o -name "*.map" \
					-o -name "*.a" \
					-o -name "*.init_internal" \
					-o -name "*.d.tmp" \
					-o -name "*.d" \) -type f -print \
					| xargs rm -f ;\
	fi
	@rm -f $(TOPDIR)/build/$(PRJ)/share/share.o \
		$(TOPDIR)/build/$(PRJ)/share/share.d \
		$(TOPDIR)/build/$(PRJ)/share/libshare.a
	@rm -f $(CLEAN_FILES)

DISTCLEAN_FILES = \
	$(TOPDIR)/include/version.h $(TOPDIR)/include/compile.h \
	$(TOPDIR)/include/autoconfig.h \
	$(TOPDIR)/make/kconfig/kconf/lxdialog/*.o \
	$(TOPDIR)/make/kconfig/kconf/*.o \
	$(TOPDIR)/make/kconfig/kconf/mconf \
	$(TOPDIR)/make/kconfig/basic/fixdep \
	$(TOPDIR)/make/kconfig/conv_conf/convconf \
	$(TOPDIR)/make/kconfig/kconf/lxdialog/.*.o.cmd \
	$(TOPDIR)/make/kconfig/kconf/.*.cmd \
	$(TOPDIR)/make/kconfig/basic/.fixdep.cmd \
	$(TOPDIR)/make/kconfig/conv_conf/.*.cmd \
	.config .config.old
distclean: clean
	@echo "--distclean"
	@rm -f $(DISTCLEAN_FILES)
	@rm -rf $(TOPDIR)/build/

Makefile:dummy

dummy:

.PHONY:dummy
