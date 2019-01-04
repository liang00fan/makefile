# (c) Texas Instruments 

ifndef $(COMMON_FOOTER_MK)
COMMON_FOOTER_MK = 1

ifdef USE_LAST_FILE_OBJS
FILE_OBJS=${USE_LAST_FILE_OBJS}
endif
#check target type
ifeq ($(strip $(TARGET)),lib)
BUILD_OUTPUT_DIR=${TOPDIR}/build/${PRJ}/${APP}/.build
FILE_OBJS=$(dir $(BUILD_OBJ_DIR)).${CUR_DIR_NAME}_objs
FILE_OBJS_RECREATED=dummy
BUILD_OBJ_DIR=$(subst ${TOPDIR}/,${TOPDIR}/build/${PRJ}/${APP}/,${CUR_DIR})
endif

ifeq ($(strip $(TARGET)),share)
BUILD_OUTPUT_DIR=${TOPDIR}/build/${PRJ}/share
FILE_OBJS=$(dir $(BUILD_OBJ_DIR)).${CUR_DIR_NAME}_objs
FILE_OBJS_RECREATED=dummy
BUILD_OBJ_DIR=$(subst ${TOPDIR}/,${TOPDIR}/build/${PRJ}/,${CUR_DIR})
endif

ifeq ($(strip $(TARGET)),bin)
BUILD_OUTPUT_DIR=${TOPDIR}/build/${PRJ}/${APP}
FILE_OBJS=$(dir $(BUILD_OBJ_DIR)).${CUR_DIR_NAME}_objs
FILE_OBJS_RECREATED=dummy
BUILD_OBJ_DIR=$(subst ${TOPDIR}/,${TOPDIR}/build/${PRJ}/${APP}/,${CUR_DIR})
endif

include $(TOPDIR)/make/basic_footer.mk

$(BUILD_OUTPUT_DIR)/lib$(CUR_DIR_NAME).a: dummy
	$(Q)BUILD_OUTPUT_DIR=$(BUILD_OUTPUT_DIR) \
		CUR_DIR_NAME=$(CUR_DIR_NAME) \
		Q=$(Q) \
		FILE_OBJS=$(FILE_OBJS) \
		$(MAKE) -f Makefile.build \
			-C $(TOPDIR)/make $@ --no-print-directory
			
$(BUILD_OUTPUT_DIR)/lib$(CUR_DIR_NAME).o: dummy
	$(Q)BUILD_OUTPUT_DIR=$(BUILD_OUTPUT_DIR) \
		CUR_DIR_NAME=$(CUR_DIR_NAME) \
		Q=$(Q) \
		FILE_OBJS=$(FILE_OBJS) \
		$(MAKE) -f Makefile.build \
			-C $(TOPDIR)/make $@ --no-print-directory		
	
$(BINARY):dummy
	$(Q)LDFLAGS="$(LDFLAGS-y) $(GLOBAL_LDFLAGS)" \
	BINARY=$(BINARY) \
	Q=$(Q) \
	OBJCOPYFLAGS="$(OBJCOPYFLAGS)" \
	FILE_OBJS=$(FILE_OBJS) \
	$(MAKE) -f Makefile.build \
		-C $(TOPDIR)/make $(BINARY) --no-print-directory
		
endif # ifndef $(COMMON_FOOTER_MK)
