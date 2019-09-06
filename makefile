# Makefile for MacOS with LLVM/Clang

#	Naming the target like the parent directory and defining the build paths structure
NAME = $(notdir $(shell pwd))

# Specifying the output directory
BUILD_DIR = build
OBJECT_DIR := $(BUILD_DIR)/obj
DEPENDENCIES_DIR := $(BUILD_DIR)/dep

#	Additional src and include folders
FOLDER = 

TARGET := $(BUILD_DIR)/$(NAME)

#	generating include flags for each includepath
# 	obtaining compiler default includes via "gcc -xc++ -E -v -"
INCLUDE_DIR = $(FOLDER)
INCLUDE_FLAGS := $(INCLUDE_DIR:%=-I %)

SHARED_LIBS_PATHS := 
SHARED_LIBS_PATHS_FLAGS = $(SHARED_LIBS_PATHS:%=-L %) # mind the space between -L and %! Important so ~ in paths are expanded

#	shared libs
SHARED_LIBS = 
SHARED_LIBS_FLAGS := $(SHARED_LIBS:%=-l%)
LIB_FLAGS = $(SHARED_LIBS_PATHS_FLAGS) $(SHARED_LIBS_FLAGS)

#	defines
DEFINES = 
DEFINES_FLAGS := $(DEFINES:%=-D%)

#	collecting all source files in the same directory/subdirs as this makefile
SRC := $(wildcard *.c) $(wildcard */*.c)
CPPSRC := $(wildcard *.cpp) $(wildcard */*.cpp)
ASRC := $(wildcard *.S)

#	creating a list of all object files (compiled sources, but not linked)
OBJ = $(SRC:%.c=$(OBJECT_DIR)/%.o) $(CPPSRC:%.cpp=$(OBJECT_DIR)/%.o) $(ASRC:%.S=$(OBJECT_DIR)/%.o)

#	Toolchain Paths (variables defined with := are expanded once, but variables defined with = are expanded whenever they are used)
LLVM_PATH := /usr/local/opt/llvm

#	Defining Compiler Tools
PREFIX := $(LLVM_PATH)/bin/
CC := $(PREFIX)clang
LD := $(PREFIX)ld64.lld
SIZE := $(PREFIX)llvm-size
NM := $(PREFIX)llvm-nm
RM := rm -f -v
# OBJCOPY := $(PREFIX)llvm-objcopy
# OBJDUMP := $(PREFIX)llvm-objdump

# SYSROOT := --sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk
SYSROOT :=

#	compiler flags
WARNINGS = -Wall -Wextra
CFLAGS = -g $(INCLUDE_FLAGS) $(WARNINGS) $(DEFINES_FLAGS) $(SYSROOT)
LDFLAGS =  -demangle -dynamic -t -lc++ -lSystem $(LIB_FLAGS)
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPENDENCIES_DIR)/$*.Td

all: tree $(TARGET) size
rebuild: clean all

$(TARGET): $(OBJ)
	@echo "Linking $<"
	$(LD) $(LDFLAGS) -o $@ $(OBJ)
	@echo 
	
$(OBJECT_DIR)/%.o: %.cpp $(DEPENDENCIES_DIR)/%.d
	@echo "Compiling $<" and generating Dependencies
	$(CC) $(CFLAGS) $(DEPFLAGS) -c $< -o $@ 
ifeq ($(aux),y)
	$(CC) $(CFLAGS) -E $< -o $(OBJECT_DIR)/$*.i
	$(CC) $(CFLAGS) -S $< -o $(OBJECT_DIR)/$*.s
	$(CC) -emit-llvm -S -c $< -o $(OBJECT_DIR)/$*.ll
endif
	@mv -f $(DEPENDENCIES_DIR)/$*.Td $(DEPENDENCIES_DIR)/$*.d && touch $@
	@echo 

$(OBJECT_DIR)/%.o: %.c $(DEPENDENCIES_DIR)/%.d
	@echo "Compiling $<" and generating Dependencies
	$(CC) $(CFLAGS) $(DEPFLAGS) -c $< -o $@ 
ifeq ($(aux),y)
	$(CC) $(CFLAGS) -E $< -o $(OBJECT_DIR)/$*.i
	$(CC) $(CFLAGS) -S $< -o $(OBJECT_DIR)/$*.s
	$(CC) -emit-llvm -S -c $< -o $(OBJECT_DIR)/$*.ll
endif
	@mv -f $(DEPENDENCIES_DIR)/$*.Td $(DEPENDENCIES_DIR)/$*.d && touch $@
	@echo 

$(DEPENDENCIES_DIR)/%.d: ;
.PRECIOUS: $(DEPENDENCIES_DIR)/%.d

-include $(OBJ:%.o=$(DEPENDENCIES_DIR)/%.d)


.PHONY: clean tree run ast help
run: build
	./$(TARGET)

ast:
	$(CC) -Xclang -ast-dump -fsyntax-only main.cpp > $(TARGET).ast

clean:
	@$(RM) $(TARGET).* 
	@$(RM) $(OBJECT_DIR)/*.*
	@$(RM) $(DEPENDENCIES_DIR)/*.*
	@$(FOLDER:%=$(RM) $(OBJECT_DIR)/%/*.*)
	@echo 

#	create folder structure if not existing
#	"@" in front of line suppresses the output
tree:
	@if [ ! -d "$(BUILD_DIR)" ]; then mkdir -p $(BUILD_DIR); fi
	@if [ ! -d "$(OBJECT_DIR)" ]; then mkdir -p $(OBJECT_DIR); fi
	@if [ ! -d "$(DEPENDENCIES_DIR)" ]; then mkdir -p $(DEPENDENCIES_DIR); fi
	@$(FOLDER:%=mkdir -p $(OBJECT_DIR)/%)
	@$(FOLDER:%=mkdir -p $(DEPENDENCIES_DIR)/%)

#	print final codesize
size: $(TARGET)
	@$(NM) -format=darwin -radix=x -demangle -debug-syms $< > $(TARGET).nm
	@$(SIZE) --format=darwin -l --radix=16 -arch=x86_64 $< > $(TARGET).size
	
help:
	@echo "Supported commands:"
	@echo "all\t\tBuild project"
	@echo "clean\t\tClean up build directory"
	@echo "run\t\tBuild and run target"
	@echo "ast\t\tExtract Abstract Syntax Tree (AST) from clang"
	@echo "size\t\tPrint size information and symbol tables"
	@echo "tree\t\tCreates folder structure"
	@echo
	@echo "Append \033[32;1maux=y\033[0m to a build target (all, run) to produce auxilliary files. E.g. make all aux=y"
