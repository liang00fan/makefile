# (c) Texas Instruments 

ifndef $(BASIC_FOOTER_MK)
BASIC_FOOTER_MK = 1

cobj-y=$(patsubst %.c, %.o, $(filter %.c,$(obj-y)))
cppobj-y=$(patsubst %.cpp, %.o, $(filter %.cpp,$(obj-y)))
sobj-y=$(patsubst %.S, %.o, $(filter %.S,$(obj-y)))
robj-y=$(patsubst %.rel, %.o, $(filter %.rel,$(obj-y)))
subdir-y=$(sort $(filter %/,$(obj-y)))

C_DEPENDS=$(patsubst %.o, $(BUILD_OBJ_DIR)/depend_%.d, $(cobj-y))
CPP_DEPENDS=$(patsubst %.o, $(BUILD_OBJ_DIR)/depend_%.d, $(cppobj-y))
ASM_DEPENDS=$(patsubst %.o, $(BUILD_OBJ_DIR)/depend_%.d, $(sobj-y))
REL_DEPENDS=$(patsubst %.o, $(BUILD_OBJ_DIR)/depend_%.d, $(robj-y))

all-to-do:$(BUILD_OBJ_DIR) subdirs $(TARGET)
	
# Remove same rules
$(sort $(BUILD_OBJ_DIR) $(BUILD_LIB_SHARE_DIR) $(BUILD_LIB_DIR) $(BUILD_OUTPUT_DIR)):
	@mkdir -p $@
#
# A rule to make subdirectories
#
subdirs:$(patsubst %,_subdir_%,$(subdir-y))

ifneq ($(strip $(subdir-y)),)
$(patsubst %,_subdir_%,$(subdir-y)):$(FILE_OBJS)
	$(Q)$(MAKE) USE_LAST_FILE_OBJS=$(FILE_OBJS) -C $(patsubst _subdir_%,%,$@)
endif

#
#all of depends will be created there
#
$(C_DEPENDS):$(BUILD_OBJ_DIR)/depend_%.d:%.c
	-$(Q)mkdir -p $(dir $@)	#as this is first target
	$(Q)set -o errexit; rm -f $@; \
		$(CC) -MM $(CFLAGS-y) $(GLOBAL_CFLAGS) $< > $@.tmp; \
		sed -e 's,\($(*F)\)\.o,$(BUILD_OBJ_DIR)/& $@,g' < $@.tmp > $@; \
		rm -f $@.tmp

$(CPP_DEPENDS):$(BUILD_OBJ_DIR)/depend_%.d:%.cpp
	-$(Q)mkdir -p $(dir $@)	#as this is first target
	$(Q)set -o errexit; rm -f $@; \
		$(CPP) -MM $(CPPFLAGS-y) $(CFLAGS-y)	$(GLOBAL_CFLAGS) $< > $@.tmp;  \
		sed -e 's,\($(*F)\)\.o,$(BUILD_OBJ_DIR)/& $@,g' < $@.tmp > $@; \
		rm -f $@.tmp

$(ASM_DEPENDS):$(BUILD_OBJ_DIR)/depend_%.d:%.S
	-$(Q)mkdir -p $(dir $@)	#as this is first target
	$(Q)set -o errexit; rm -f $@; \
		$(CC) -MM $(CFLAGS-y) $(GLOBAL_CFLAGS) $< > $@.tmp; \
		sed -e 's,\($(*F)\)\.o,$(BUILD_OBJ_DIR)/& $@,g'< $@.tmp > $@; \
		rm -f $@.tmp

$(REL_DEPENDS):$(BUILD_OBJ_DIR)/depend_%.d:%.rel
	-$(Q)mkdir -p $(dir $@)	#as this is first target
	$(Q)set -o errexit; rm -f $@; \
		echo $(BUILD_OBJ_DIR)/$(*F).o\:$< > $@
	
sinclude $(C_DEPENDS) $(CPP_DEPENDS) $(ASM_DEPENDS) $(REL_DEPENDS)

#compile here
cobj-y-out=$(patsubst %.o,$(BUILD_OBJ_DIR)/%.o,$(notdir $(cobj-y)))
cppobj-y-out=$(patsubst %.o,$(BUILD_OBJ_DIR)/%.o,$(notdir $(cppobj-y)))
sobj-y-out=$(patsubst %.o,$(BUILD_OBJ_DIR)/%.o,$(notdir $(sobj-y)))
robj-y-out=$(patsubst %.o,$(BUILD_OBJ_DIR)/%.o,$(notdir $(robj-y)))
all-objs-y=$(cobj-y-out) $(cppobj-y-out) $(sobj-y-out) $(robj-y-out)

$(cobj-y-out):
	$(Q)echo "  [CC] $(notdir $@)"
	$(Q)$(CC) $(CFLAGS-y) $(GLOBAL_CFLAGS) -c $< -o $@

$(cppobj-y-out):
	$(Q)echo "  [CPP] $(notdir $@)"
	$(Q)$(CPP) $(CPPFLAGS-y) $(GLOBAL_CFLAGS) -c $< -o $@
	
$(sobj-y-out):
	$(Q)echo "  [CC] $(notdir $@)"
	$(Q)$(CC) $(CFLAGS-y) $(GLOBAL_CFLAGS) -c $< -o $@

$(robj-y-out):
	$(Q)echo "  [CC] $(notdir $@)"
	$(Q)cp $< $@

ifneq ($(strip $(FILE_OBJS)),)
$(FILE_OBJS):$(FILE_OBJS_RECREATED)
	@echo RAM_OBJS\:\= > $(FILE_OBJS)
endif

objs: $(FILE_OBJS) $(all-objs-y)
ifneq ($(strip $(all-objs-y)),)
	@echo RAM_OBJS\+\=$(all-objs-y) >> $(FILE_OBJS)
endif
#
# Rule to compile library 
#
lib:objs $(BUILD_OUTPUT_DIR) $(BUILD_OUTPUT_DIR)/lib$(CUR_DIR_NAME).a
	
share:objs $(BUILD_OUTPUT_DIR) $(BUILD_OUTPUT_DIR)/lib$(CUR_DIR_NAME).o
	
bin:objs $(BINARY)
	
dummy:
	
.PHONY:dummy
	
endif # ifndef $(BASIC_FOOTER_MK)
