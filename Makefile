# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#         This Makefile manages the compilation of Fortran source code.        #
#                                                                              #
# ============================================================================ #


# ---------------------------------------------------------------------------- #
#   Build Environment Settings
# ---------------------------------------------------------------------------- #

# Fortran Compiler (FC)
FC     = ifx

# Fortran Compiler Flags (FFLAGS)
FFLAGS = -O2 -xHost -ipo -fiopenmp -fpp -convert big_endian -heap-arrays \
		 -qmkl=sequential -static-intel \
		 -module $(BUILD_DIR) -I$(BUILD_DIR) -I. \
		 -I"${MKLROOT}/include"

# Fortran Libraries (FLIBS)
# Intel MKL Link Line advisor:
# https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl-link-line-advisor.html
FLIBS  = -Wl,--start-group \
		 ${MKLROOT}/lib/libmkl_intel_lp64.a \
		 ${MKLROOT}/lib/libmkl_sequential.a \
		 ${MKLROOT}/lib/libmkl_core.a \
		 -Wl,--end-group -liomp5 -lpthread -lm -ldl


#==============================================================================#
#========================== DO NOT CHANGE BELOW ===============================#
#==============================================================================#


BUILD_DIR = ./build            # Directory for intermediate binary files
TARGET    = start_calculation  # Executable file
CONFIG    = config.h           # Configuration header file

# List all Fortran source files in compilation order
SRCS = \
	   source/core/... \
	   source/init/... \
	   source/io/... \
	   source/kernel/... \
	   source/neighbor/... \
	   source/solvers/... \
	   source/boundary/... \
	   source/equations/... \
	   source/shifting/... \
	   source/integrator/... \
	   source/main.f90

# Generate a list of intermediate files (.o) in $(BUILD_DIR) from $(SRCS) (.f90)
OBJS = $(SRCS:%.f90=$(BUILD_DIR)/%.o)


# ---------------------------------------------------------------------------- #
#   Build Rules
# ---------------------------------------------------------------------------- #

# Default goal to build the executable file
all: $(TARGET)

# Generate $(TARGET) from $(OBJS)
# ex) ifx -O2 build/source/core/*.o build/source/main.o -o start_calculation -qmkl
$(TARGET): $(OBJS)
	$(FC) $(FFLAGS) $(OBJS) -o $@ $(FLIBS)
	@echo + -------------------------------------------------------- +
	@echo   [message] All programs have been successfully compiled.
	@echo   [message] Please run: ./$(TARGET)
	@echo + -------------------------------------------------------- +

# Compile all Fortran files (.f90) to generate intermediate files (.o) into BUILD_DIR
# ex) ifx -O2 -c source/main.f90 -o build/source/main.o
$(BUILD_DIR)/%.o: %.f90
	@mkdir -p $(@D)
	$(FC) $(FFLAGS) -c $< -o $@

# Recompile all $(OBJS) if $(CONFIG) is changed
$(OBJS): $(CONFIG)


# ---------------------------------------------------------------------------- #
#   Remove the executable file and intermediate files
# ---------------------------------------------------------------------------- #

.PHONY: clean
clean:
	@rm -rf $(TARGET) $(BUILD_DIR)
	@echo + -------------------------------------------------------- +
	@echo   [message] make clean
	@echo + -------------------------------------------------------- +