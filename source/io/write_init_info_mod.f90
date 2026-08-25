! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!            This file logs the initial information to the terminal.           !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module write_init_info_mod
    use global_types, only: Param_type, SP_type

    implicit none

contains

    subroutine write_init_info(param, SP)
        type(Param_type), intent(in) :: param
        type(SP_type)   , intent(in) :: SP

        character(len=1024) :: file_name
        integer             :: un

        ! ==================================================================== !
        !   1. Write to Terminal
        ! ==================================================================== !
        write(*, "(a)")         ""
        write(*, "(a)")         "+ ======================================================== +"
        write(*, "(a)")         "|   LS-SPH-Benchmarks Log File                             |"
        write(*, "(a)")         "+ ======================================================== +"

#if   (TARGET_PROBLEM == 1)
        write(*, "(a)")         "   - TARGET_PROBLEM : Diffusion Equation Test"
#elif (TARGET_PROBLEM == 2)
        write(*, "(a)")         "   - TARGET_PROBLEM : Taylor-Green Vortex"
#elif (TARGET_PROBLEM == 3)
        write(*, "(a)")         "   - TARGET_PROBLEM : Lid-driven Cavity Flow"
#elif (TARGET_PROBLEM == 4)
        write(*, "(a)")         "   - TARGET_PROBLEM : Boussinesq Convection (Bottom-heated)"
#endif
        write(*, "(a, a)")      "   - SAVE_NAME      : ", trim(param%save_name)
        write(*, "(a, i0)")     "   - OMP_THREADS    : ", param%omp_threads

#if   (SPH_MODEL == 1)
        write(*, "(a)")         "   - SPH_MODEL      : Classical SPH (sum)"
#elif (SPH_MODEL == 2)
        write(*, "(a)")         "   - SPH_MODEL      : Classical SPH (difference)"
#elif (SPH_MODEL == 3)
        write(*, "(a)")         "   - SPH_MODEL      : LS-SPH (with 2nd-order Taylor expansion)"
#elif (SPH_MODEL == 4)
        write(*, "(a)")         "   - SPH_MODEL      : LS-SPH (with 3rd-order Taylor expansion)"
#elif (SPH_MODEL == 5)
        write(*, "(a)")         "   - SPH_MODEL      : LS-SPH (with 4th-order Taylor expansion)"
#elif (SPH_MODEL == 6)
        write(*, "(a)")         "   - SPH_MODEL      : LS-SPH (with 5th-order Taylor expansion)"
#endif

#if   (WALL_MODEL == 1)
        write(*, "(a)")         "   - WALL_MODEL     : Multi-layer fixed ghost (1st-order interpolation)"
#elif (WALL_MODEL == 2)
        write(*, "(a)")         "   - WALL_MODEL     : Multi-layer fixed ghost (2nd-order interpolation)"
#elif (WALL_MODEL == 3)
        write(*, "(a)")         "   - WALL_MODEL     : Multi-layer fixed ghost (3rd-order interpolation)"
#endif

#if   (TARGET_PROBLEM == 2) || (TARGET_PROBLEM == 3)
        write(*, "(a, es11.4)") "   - Re             :", param%Re
#elif (TARGET_PROBLEM == 4)
        write(*, "(a, es11.4)") "   - Ra             :", param%Ra
        write(*, "(a, es11.4)") "   - Pr             :", param%Pr
#endif

        write(*, "(a)")         "+ ======================================================== +"
        write(*, "(a, i0)")     "   - Total steps : ", param%total_step
        write(*, "(a)")         "   - Number of Particles"
        write(*, "(a, i0)")     "      * Total    : ", SP%num_total
        write(*, "(a, i0)")     "      * Internal : ", SP%num_int
        write(*, "(a, i0)")     "      * External : ", SP%num_ext
        write(*, "(a, es11.4)") "   - dx          :" , param%dx
        write(*, "(a, es11.4)") "   - h           :" , param%h
        write(*, "(a)")         "+ ======================================================== +"

        write(*, "(a)")         "   - Time Step (dt) [s]"

#if (TARGET_PROBLEM == 1)
        write(*, "(a, es11.4)") "                 :", param%dt
    
#else
        write(*, "(a, es11.4)") "      1. CFL                :", param%dt_CFL
        write(*, "(a, es11.4)") "         >> relax           :", param%dt_CFL_relax

        write(*, "(a, es11.4)") "      2. Momentum diffusion :", param%dt_vis
#if (TARGET_PROBLEM == 4)
        write(*, "(a, es11.4)") "         >> relax           :", param%dt_vis_relax
        write(*, "(a, es11.4)") "      3. Thermal diffusion  :", param%dt_th
#endif
        write(*, "(a)")         ""
        write(*, "(a, es11.4)") "    ==> Effective time step :", param%dt
#endif

        write(*, "(a)")         "+ ======================================================== +"

        ! ==================================================================== !
        !   2. Write to Log File
        ! ==================================================================== !
        file_name = "results/" // trim(adjustl(param%save_name)) // &
                    "/config/run.log"
        open(newunit=un, file=trim(file_name), status="replace", form="formatted")

        write(un, "(a)")         ""
        write(un, "(a)")         "+ ======================================================== +"
        write(un, "(a)")         "|   LS-SPH-Benchmarks Log File                             |"
        write(un, "(a)")         "+ ======================================================== +"

#if   (TARGET_PROBLEM == 1)
        write(un, "(a)")         "   - TARGET_PROBLEM : Diffusion Equation Test"
#elif (TARGET_PROBLEM == 2)
        write(un, "(a)")         "   - TARGET_PROBLEM : Taylor-Green Vortex"
#elif (TARGET_PROBLEM == 3)
        write(un, "(a)")         "   - TARGET_PROBLEM : Lid-driven Cavity Flow"
#elif (TARGET_PROBLEM == 4)
        write(un, "(a)")         "   - TARGET_PROBLEM : Boussinesq Convection (Bottom-heated)"
#endif
        write(un, "(a, a)")      "   - SAVE_NAME      : ", trim(param%save_name)
        write(un, "(a, i0)")     "   - OMP_THREADS    : ", param%omp_threads

#if   (SPH_MODEL == 1)
        write(un, "(a)")         "   - SPH_MODEL      : Classical SPH (sum)"
#elif (SPH_MODEL == 2)
        write(un, "(a)")         "   - SPH_MODEL      : Classical SPH (difference)"
#elif (SPH_MODEL == 3)
        write(un, "(a)")         "   - SPH_MODEL      : LS-SPH (with 2nd-order Taylor expansion)"
#elif (SPH_MODEL == 4)
        write(un, "(a)")         "   - SPH_MODEL      : LS-SPH (with 3rd-order Taylor expansion)"
#elif (SPH_MODEL == 5)
        write(un, "(a)")         "   - SPH_MODEL      : LS-SPH (with 4th-order Taylor expansion)"
#elif (SPH_MODEL == 6)
        write(un, "(a)")         "   - SPH_MODEL      : LS-SPH (with 5th-order Taylor expansion)"
#endif

#if   (WALL_MODEL == 1)
        write(un, "(a)")         "   - WALL_MODEL     : Multi-layer fixed ghost (1st-order interpolation)"
#elif (WALL_MODEL == 2)
        write(un, "(a)")         "   - WALL_MODEL     : Multi-layer fixed ghost (2nd-order interpolation)"
#elif (WALL_MODEL == 3)
        write(un, "(a)")         "   - WALL_MODEL     : Multi-layer fixed ghost (3rd-order interpolation)"
#endif

#if   (TARGET_PROBLEM == 2) || (TARGET_PROBLEM == 3)
        write(un, "(a, es11.4)") "   - Re             :", param%Re
#elif (TARGET_PROBLEM == 4)
        write(un, "(a, es11.4)") "   - Ra             :", param%Ra
        write(un, "(a, es11.4)") "   - Pr             :", param%Pr
#endif

        write(un, "(a)")         "+ ======================================================== +"
        write(un, "(a, i0)")     "   - Total steps : ", param%total_step
        write(un, "(a)")         "   - Number of Particles"
        write(un, "(a, i0)")     "      * Total    : ", SP%num_total
        write(un, "(a, i0)")     "      * Internal : ", SP%num_int
        write(un, "(a, i0)")     "      * External : ", SP%num_ext
        write(un, "(a, es11.4)") "   - dx          :" , param%dx
        write(un, "(a, es11.4)") "   - h           :" , param%h
        write(un, "(a)")         "+ ======================================================== +"

        write(un, "(a)")         "   - Time Step (dt) [s]"

#if (TARGET_PROBLEM == 1)
        write(un, "(a, es11.4)") "                 :", param%dt
    
#else
        write(un, "(a, es11.4)") "      1. CFL                :", param%dt_CFL
        write(un, "(a, es11.4)") "         >> relax           :", param%dt_CFL_relax

        write(un, "(a, es11.4)") "      2. Momentum diffusion :", param%dt_vis
#if (TARGET_PROBLEM == 4)
        write(un, "(a, es11.4)") "         >> relax           :", param%dt_vis_relax
        write(un, "(a, es11.4)") "      3. Thermal diffusion  :", param%dt_th
#endif
        write(un, "(a)")         ""
        write(un, "(a, es11.4)") "    ==> Effective time step :", param%dt
#endif

        write(un, "(a)")         "+ ======================================================== +"

        close(un)

    end subroutine write_init_info

end module write_init_info_mod
