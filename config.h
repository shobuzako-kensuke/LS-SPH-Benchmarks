/* ============================================================================ */
/*                                                                              */
/*                              LS-SPH-Benchmarks                               */
/*                                                                              */
/*                     Copyright (c) 2026 Kensuke SHOBUZAKO                     */
/*               This program is licensed under the MIT License.                */
/*                                                                              */
/*                              ~~ Description ~~                               */
/*      This configuration file defines simulation parameters and options.      */
/*      This is included via the Fortran preprocessor (-fpp) in `Makefile`.     */
/*                                                                              */
/* ============================================================================ */


/* ============================================================================ */
/*   1. Target Problem                                                          */
/* ============================================================================ */
/*   Options:                                                                   */
/*       1 : Diffusion Equation Test                                            */
/*       2 : Taylor-Green Vortex                                                */
/*       3 : Lid-driven Cavity Flow                                             */
/*       4 : Boussinesq Convection (Bottom-heated)                              */
/* ============================================================================ */
#define TARGET_PROBLEM 2


/* ============================================================================ */
/*   2. Velocity Boundary Conditions                                            */
/* ============================================================================ */
/*   Options:                                                                   */
/*       1 : Free-slip   boundary condition (Neumann   for the diffusion test)  */
/*       2 : No-slip     boundary condition (Dirichlet for the diffusion test)  */
/*       3 : Moving wall boundary condition (constant velocity)                 */
/* ============================================================================ */
#define U_BOUNDARY_TOP    1
#define U_BOUNDARY_BOTTOM 1
#define U_BOUNDARY_LEFT   1
#define U_BOUNDARY_RIGHT 1

/* Constant velocity in the X-direction at the top wall [Double precision]      */
/* Note: Valid only if the moving wall condition (Option 3) is selected.        */
#define U_TOP 1.0d0


/* ============================================================================ */
/*   3. Temperature Boundary Conditions                                         */
/* ============================================================================ */
/*   Options:                                                                   */
/*       1 : Isothermal boundary condition (constant temperature)               */
/*       2 : Adiabatic  boundary condition (zero heat flux)                     */
/* ============================================================================ */
#define TEM_BOUNDARY_TOP    1
#define TEM_BOUNDARY_BOTTOM 1
#define TEM_BOUNDARY_LEFT   2
#define TEM_BOUNDARY_RIGHT  2

/* Wall Temperatures (K) [Double precision]                                     */
/* Note: Valid only if the isothermal condition (Option 1) is selected.         */
#define TEM_TOP    0.0d0
#define TEM_BOTTOM 1.0d-2
#define TEM_LEFT   0.0d0
#define TEM_RIGHT  0.0d0


/* ============================================================================ */
/*   4. Input/Output Settings                                                   */
/* ============================================================================ */
/* Output directory name [String]                                               */
#define SAVE_NAME "tg_compare_100_write"

/* Write "new" for a fresh start, or the saved name for a restart [String]      */
#define READ_NAME "new"


/* ============================================================================ */
/*   5. Parallel Computing Settings                                             */
/* ============================================================================ */
/* Number of threads for OpenMP [Integer]                                       */
#define OMP_THREADS 8


/* ============================================================================ */
/*   6. Domain (SI Units) & Spatial Resolution                                  */
/* ============================================================================ */
/* System length in the X and Y directions (m) [Double precision]               */
#define LEN_X 1.0d0
#define LEN_Y 1.0d0

/* Number of particles in the X and Y directions [Integer]                      */
/* Note: Initial particle spacing (dx) is defined as LEN_X / NUM_X              */
#define NUM_X 100
#define NUM_Y 100


/* ============================================================================ */
/*   7. Time Integration & Numerical Parameters                                 */
/* ============================================================================ */
/* Order of Runge-Kutta method: 2 or 4 is available                             */
#define RK 4

/* Start step [Integer]:                                                        */
/* Write 1 for a fresh start, or the specified step for a restart               */
#define START_STEP 1

/* End step [Integer]                                                           */
#define END_STEP 10000

/* File output interval [Integer]                                               */
#define WRITE_STEP 100

/* Threshold for checking the steady state [Double precision]                   */
#define THRESHOLD 1.0d-10

/* Coefficients for the CFL and diffusion conditions [Double precision]         */
/* dt = COE_CFL * dx    / (speed of sound), or                                  */
/*      COE_DIF * dx**2 / (diffusion coefficient)                               */
#define COE_CFL 0.5d0
#define COE_DIF 0.2d0

/* Relaxation parameters [Double precision]                                     */
/* ZETA_RSST: Reduced Speed of Sound Technique (RSST)                           */
/* XI_VIM   : Variable Inertial Method (VIM)                                    */
#define ZETA_RSST 1.0d0
#define XI_VIM    1.0d0


/* ============================================================================ */
/*   8. Fluid Physical Properties (SI Unit)                                     */
/* ============================================================================ */
/* Reference density (kg m^-3) [Double precision]                               */
#define RHO_REF 1.0d0

/* Reference viscosity (Pa s) [Double precision]                                */
#define VIS_REF 1.0d-2

/* Reference bulk modulus (Pa) [Double precision]                               */
#define K_REF 1.0d2

/* Reference thermal conductivity (W m^-1 K^-1) [Double precision]              */
#define K_TH_REF 1.0d-2

/* Reference specific heat capacity (J kg^-1 K^-1) [Double precision]           */
#define CP_REF 1.0d3

/* Reference thermal expansion coefficient (K^-1) [Double precision]            */
#define ALPHA_REF 7.1d-3

/* ============================================================================ */
/*   9. Simulation Parameters (SI Unit)                                         */
/* ============================================================================ */
/* Magnitude of Gravitational acceleration (m s^-2) [Double precision]          */
#define GRAVITY 10.0d0

/* Positional perturbation for the diffusion equation test [Double precision]   */
#define POS_PERT 0.0d0

/* Number of vortices for Taylor-Green vortex [Integer]                         */
#define TG_A 1
#define TG_B 1


/* ============================================================================ */
/*   10. SPH Parameters                                                         */
/* ============================================================================ */
/* Coefficient of the smoothing length h: h = COE_H * dx [Double precision]     */
#define COE_H 1.2d0

/* Parameters for the Particle Shifting Technique [Double precision]            */
/* Shift vector: dr = - coe_PS * (1 + 0.2*(W_ij/W_ave)**4) * (dW_ij) * V_j,     */
/*               where coe_PS = PST_C * U_max * dt * h                          */
#define PST_C 1.5d0

/* Coefficient of the density diffusion term in the EOC [Double precision]      */
/* Note: The recommended value is 0.1 in the delta-SPH method.                  */
#define COE_DELTA_SPH 0.0d0


/* ============================================================================ */
/*   11. Kernel Function                                                        */
/* ============================================================================ */
/*   Options:                                                                   */
/*       1 : Cubic spline   kernel                                              */
/*       2 : Quintic spline kernel                                              */
/*       3 : Wendland C2    kernel                                              */
/*       4 : Wendland C4    kernel                                              */
/*       5 : Wendland C6    kernel                                              */
/* ============================================================================ */
#define KERNEL_TYPE 3


/* ============================================================================ */
/*   12. SPH Discretization Model                                               */
/* ============================================================================ */
/*   Options:                                                                   */
/*       1 : Classical SPH (sum model)                                          */
/*       2 : Classical SPH (difference model)                                   */
/*       3 : LS-SPH (with 2nd-order Taylor expansion)                           */
/*       4 : LS-SPH (with 3rd-order Taylor expansion)                           */
/*       5 : LS-SPH (with 4th-order Taylor expansion)                           */
/*       6 : LS-SPH (with 5th-order Taylor expansion)                           */
/* ============================================================================ */
#define SPH_MODEL 3


/* ============================================================================ */
/*   13. Wall Boundary Model                                                    */
/* ============================================================================ */
/*   Options:                                                                   */
/*       1 : Multi-layer fixed ghost particle scheme (1st-order interpolation)  */
/*       2 : Multi-layer fixed ghost particle scheme (2nd-order interpolation)  */
/*       3 : Multi-layer fixed ghost particle scheme (3rd-order interpolation)  */
/* ============================================================================ */
#define WALL_MODEL 2