/* ============================================================================ */
/*                                                                              */
/*                              LS-SPH-Benchmarks                               */
/*                                                                              */
/*                     Copyright (c) 2026 Kensuke SHOBUZAKO                     */
/*               This program is licensed under the MIT License.                */
/*                                                                              */
/*                              ~~ Description ~~                               */
/*   This configuration file sets physical parameters and simulation options.   */
/*    This is included via the Fortran preprocessor (-fpp) in the Makefile.     */
/*                                                                              */
/* ============================================================================ */


/* ---------------------------------------------------------------------------- */
/*   1. Target Problem                                                          */
/* ---------------------------------------------------------------------------- */
/*   Options:                                                                   */
/*       1 : 2D diffusion equation test                                         */
/*       2 : Taylor-Green vortex flow                                           */
/*       3 : Lid-driven cavity flow                                             */
/*       4 : Boussinesq convection                                              */
/* ---------------------------------------------------------------------------- */
#define TARGET_PROBLEM 1


/* ---------------------------------------------------------------------------- */
/*   2. Velocity Boundary Conditions                                            */
/* ---------------------------------------------------------------------------- */
/*   Options:                                                                   */
/*       1 : Free-slip   boundary condition                                     */
/*       2 : Non-slip    boundary condition                                     */
/*       3 : Moving wall boundary condition (constant velocity)                 */
/* ---------------------------------------------------------------------------- */
#define U_BOUNDARY_TOP    1
#define U_BOUNDARY_BOTTOM 1
#define U_BOUNDARY_LEFT   1
#define U_BOUNDARY_RIGHT  1

/* Constant velocity in the X-direction at the top wall [Double precision]      */
/* Note: Valid only if the moving wall condition (Option 3) is selected.        */
#define U_TOP 1.0d0


/* ---------------------------------------------------------------------------- */
/*   3. Temperature Boundary Conditions                                         */
/* ---------------------------------------------------------------------------- */
/*   Options:                                                                   */
/*       1 : Isothermal boundary condition (constant temperature)               */
/*       2 : Adiabatic  boundary condition (zero heat flux)                     */
/* ---------------------------------------------------------------------------- */
#define T_BOUNDARY_TOP    1
#define T_BOUNDARY_BOTTOM 1
#define T_BOUNDARY_LEFT   1
#define T_BOUNDARY_RIGHT  1

/* Wall Temperatures (K) [Double precision]                                     */
/* Note: Valid only if the isothermal condition (Option 1) is selected.         */
#define T_TOP    0.0d0
#define T_BOTTOM 1000.0d0
#define T_LEFT   0.0d0
#define T_RIGHT  0.0d0


/* ---------------------------------------------------------------------------- */
/*   4. File & Input/Output Settings                                            */
/* ---------------------------------------------------------------------------- */

/* Output directory name [String]                                               */
#define SAVE_NAME "test"

/* Write "new" for a fresh start, or the saved name for a restart [String]      */
#define READ_NAME "new"


/* ---------------------------------------------------------------------------- */
/*   5. Parallel Computing Settings                                             */
/* ---------------------------------------------------------------------------- */

/* Number of threads for OpenMP [Integer]                                       */
#define OMP_THREADS 8


/* ---------------------------------------------------------------------------- */
/*   6. Domain (SI Units) & Spatial Resolution                                  */
/* ---------------------------------------------------------------------------- */

/* System length in the X and Y directions (m) [Double precision]               */
#define L_X 1.0d0
#define L_Y 1.0d0

/* Number of particles in the X and Y directions [Integer]                      */
#define N_X 50
#define N_Y 50


/* ---------------------------------------------------------------------------- */
/*   7. Time Integration & Numerical Parameters                                 */
/* ---------------------------------------------------------------------------- */

/* Start step [Integer]:                                                        */
/* Write 1 for a fresh start, or the specified step for a restart               */
#define START_STEP 1

/* End step [Integer]                                                           */
#define END_STEP 1000

/* File output interval [Integer]                                               */
#define WRITE_STEP 100

/* Coefficients for the CFL and diffusion conditions [Double precision]         */
/* dt = COE_CFL * dx    / (speed of sound), or                                  */
/*      COE_DIF * dx**2 / (diffusion coefficient)                               */
#define COE_CFL 0.5d0
#define COE_DIF 0.2d0

/* Relaxation parameters [Double precision]                                     */
/* ZETA_RSST: Reduced Speed of Sound Technique (RSST)                           */
/* XI_VIM   : Variable Inertial Method (VIM)                                    */
#define ZETA_RSST 1.0d3
#define XI_VIM    1.0d0


/* ---------------------------------------------------------------------------- */
/*   8. Fluid Physical Properties (SI Unit)                                     */
/* ---------------------------------------------------------------------------- */

/* Reference density (kg m-3) [Double precision]                                */
#define RHO_REF 1.0d0

/* Reference viscosity (Pa s) [Double precision]                                */
#define VIS_REF 1.0d-2

/* Reference bulk modulus (Pa) [Double precision]                               */
#define K_BM_REF 2.2d9

/* Reference thermal conductivity (W m-1 K-1) [Double precision]                */
#define K_TH_REF 5.0d0

/* Reference specific heat capacity (J kg-1 K-1) [Double precision]             */
#define CP_REF 1.25d3

/* Reference thermal expansion coefficient (K-1) [Double precision]             */
#define ALPHA_REF 2.5d-5


/* ---------------------------------------------------------------------------- */
/*   9. SPH Parameters                                                          */
/* ---------------------------------------------------------------------------- */

/* Coefficient of the smoothing length h: h = COE_H * dx [Double precision]     */
#define COE_H 1.2d0

/* Parameters for the Particle Shifting Technique [Double precision]            */
/* Shift vector: dr = coe_PS * (1 + PS_R*(W_ij/W_ave)**PS_N) * (dW_ij) * V_j    */
/*               where coe_PS = PS_C * U_max * dt * h                           */
#define PS_C 1.5d0
#define PS_R 0.2d0
#define PS_N 4.0d0

/* Coefficient of the density diffusion term in the EOC [Double precision]      */
/* Note: This is based on the delta-SPH method.                                 */
#define COE_DELTA_SPH 0.0d0


/* ---------------------------------------------------------------------------- */
/*   10. Kernel Function                                                        */
/* ---------------------------------------------------------------------------- */
/*   Options:                                                                   */
/*       1 : Cubic spline   kernel                                              */
/*       2 : Quintic spline kernel                                              */
/*       3 : Wendland C2    kernel                                              */
/*       4 : Wendland C4    kernel                                              */
/*       5 : Wendland C6    kernel                                              */
/* ---------------------------------------------------------------------------- */
#define KERNEL_TYPE 3


/* ---------------------------------------------------------------------------- */
/*   11. SPH Discretization Model (Solver)                                      */
/* ---------------------------------------------------------------------------- */
/*   Options:                                                                   */
/*       1 : Classical SPH (sum model)                                          */
/*       2 : Classical SPH (difference model)                                   */
/*       3 : Corrected SPH                                                      */
/*       4 : LS-SPH including the 2nd-order terms (q=2)                         */
/*       5 : LS-SPH including the 3rd-order terms (q=3)                         */
/*       6 : LS-SPH including the 4th-order terms (q=4)                         */
/* ---------------------------------------------------------------------------- */
#define SPH_MODEL 1


/* ---------------------------------------------------------------------------- */
/*   12. Wall Boundary Model                                                    */
/* ---------------------------------------------------------------------------- */
/*   Options:                                                                   */
/*       1 : Multi-layer ghost particle scheme with 1st-order interpolation     */
/*       2 : Multi-layer ghost particle scheme with 2nd-order interpolation     */
/*       3 : Multi-layer ghost particle scheme with 3rd-order interpolation     */
/* ---------------------------------------------------------------------------- */
#define WALL_MODEL 1