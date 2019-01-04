# (c) Texas Instruments 

ifndef $(COMMON_HEADER_MK)
COMMON_HEADER_MK = 1

include $(TOPDIR)/make/basic_header.mk

LDFLAGS-y += -L${TOPDIR}/build/${PRJ}/${APP}/.build
OBJCOPYFLAGS=

endif # ifndef $(COMMON_HEADER_MK)

