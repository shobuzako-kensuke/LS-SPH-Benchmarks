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


# ============================================================================ #
#   Build Environment Settings
# ============================================================================ #
#   Instructions:
#      - Uncomment the compiler block you want to use, and comment out the other
#      - FC: Fortran Compiler
#      - FFLAGS: Fortran Compiler Flags
#      - FLIBS: Fortran Libraries*
#
#   *See Intel MKL Link Line Advisor:
#    https://www.intel.com/content/www/us/en/developer/tools/oneapi/onemkl-link-line-advisor.html
#
#   Note:
#      If a "Segmentation fault" occurs (stack overflow), 
#      add the heap allocation flag to FFLAGS:
#         - ifx      : -heap-arrays
#         - gfortran : -fmax-stack-var-size=0
# ============================================================================ #

# ---------------------------------------------------------------------------- #
#  Option 1: Intel Fortran Compiler (ifx) + Intel MKL
# ---------------------------------------------------------------------------- #
FC     = ifx
FFLAGS = -O2 -xHost -ipo -fiopenmp -fpp \
		 -qmkl=sequential -static-intel -fpscomp logicals -qopt-report=3 \
		 -module $(BUILD_DIR) -I$(BUILD_DIR) -I. \
		 -I"${MKLROOT}/include"
FLIBS  = -Wl,--start-group \
		 ${MKLROOT}/lib/libmkl_intel_lp64.a \
		 ${MKLROOT}/lib/libmkl_sequential.a \
		 ${MKLROOT}/lib/libmkl_core.a \
		 -Wl,--end-group -liomp5 -lpthread -lm -ldl


# ---------------------------------------------------------------------------- #
#  Option 2: GNU Fortran Compiler (gfortran) + Standard LAPACK/BLAS
# ---------------------------------------------------------------------------- #
# FC     = gfortran
# FFLAGS = -O2 -march=native -flto -fopenmp -cpp \
# 		 -J$(BUILD_DIR) -I$(BUILD_DIR) -I.
# FLIBS  = -llapack -lblas


#==============================================================================#
#========================== DO NOT CHANGE BELOW ===============================#
#==============================================================================#
# Directory for the intermediate binary files
BUILD_DIR = ./build

# Executable file
TARGET    = start_calculation

# Configuration header file
CONFIG    = config.h

# List all Fortran source files in compilation order
SRCS = \
	   source/core/global_types.f90                   \
	   source/core/kernel_functions_mod.f90           \
	   source/io/file_operations_mod.f90              \
	   source/check/check_param_mod.f90               \
	   source/setup/init_param_mod.f90                \
	   source/setup/setup_closed_box_mod.f90          \
	   source/setup/impose_initial_conditions_mod.f90 \
	   source/setup/restart_mod.f90                   \
	   source/setup/init_particle_mod.f90             \
	   source/setup/init_virtual_markers_mod.f90      \
	   source/neighbor/init_cell_mod.f90              \
	   source/neighbor/update_cell_mod.f90            \
	   source/boundary/interpolate_CSPH_mod.f90       \
	   source/boundary/interpolate_LSSPH_B_mod.f90    \
	   source/boundary/extrapolate_VM_to_WL_mod.f90   \
	   source/boundary/extrapolate_diff_test_mod.f90  \
	   source/boundary/ghost_mod.f90                  \
	   source/equation/classical_SPH_mod.f90          \
	   source/equation/LSSPH_A_mod.f90                \
	   source/equation/calculate_RHS_mod.f90          \
	   source/equation/RK2_mod.f90                    \
	   source/equation/RK4_mod.f90                    \
	   source/shifting/shift_interpolate_mod.f90      \
	   source/shifting/PST_mod.f90                    \
	   source/io/write_param_mod.f90                  \
	   source/io/write_data_mod.f90                   \
	   source/io/write_init_info_mod.f90              \
	   source/io/write_progress_mod.f90               \
	   source/check/check_steady_state_mod.f90        \
	   source/main.f90

# Generate a list of intermediate files (.o) in $(BUILD_DIR) from $(SRCS) (.f90)
OBJS = $(SRCS:%.f90=$(BUILD_DIR)/%.o)


# ============================================================================ #
#   Build Rules
# ============================================================================ #
# Default goal to build the executable file
all: $(TARGET)

# Generate $(TARGET) from $(OBJS)
# ex) ifx -O2 build/source/core/*.o build/source/main.o -o start_calculation -qmkl
$(TARGET): $(OBJS)
	$(FC) $(FFLAGS) $(OBJS) -o $@ $(FLIBS)
	@echo ""
	@echo "+ -------------------------------------------------------- +"
	@echo "|   All programs have been successfully compiled.          |"
	@echo "|   Please run: ./$(TARGET)                        |"
	@echo "+ -------------------------------------------------------- +"
	@echo ""

# Compile all Fortran files (.f90) to generate intermediate files (.o) into BUILD_DIR
# ex) ifx -O2 -c source/main.f90 -o build/source/main.o
$(BUILD_DIR)/%.o: %.f90
	@mkdir -p $(@D)
	$(FC) $(FFLAGS) -c $< -o $@

# Recompile all $(OBJS) if $(CONFIG) is changed
$(OBJS): $(CONFIG)


# ============================================================================ #
#   Remove the executable file and intermediate files
# ============================================================================ #
.PHONY: clean
clean:
	@rm -rf $(TARGET) $(BUILD_DIR)
	@echo ""
	@echo "+ -------------------------------------------------------- +"
	@echo "|   Removed 'build' directory and the executable file.     |"
	@echo "+ -------------------------------------------------------- +"
	@echo ""