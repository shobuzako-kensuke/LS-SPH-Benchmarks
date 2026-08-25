! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!              This file checks the user-defined configurations.               !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module check_param_mod
    use global_types, only: Param_type
    
    implicit none

contains

    subroutine check_param(param)
        type(Param_type), intent(in) :: param
        double precision :: dx, dy

        ! ==================================================================== !
        !   1. Macro Option Check
        ! ==================================================================== !
#if (TARGET_PROBLEM < 1 || TARGET_PROBLEM > 4)
        write(*,*) "+ ======================================================== +"
        write(*,*) "|   Fatal Error in setup:                                  |"
        write(*,*) "|      - TARGET_PROBLEM must be between 1 and 4.           |"
        write(*,*) "|      - Please check 'config.h'.                          |"
        write(*,*) "+ ======================================================== +"
        error stop
#endif

#if (KERNEL_TYPE < 1 || KERNEL_TYPE > 5)
        write(*,*) "+ ======================================================== +"
        write(*,*) "|   Fatal Error in setup:                                  |"
        write(*,*) "|      - KERNEL_TYPE must be between 1 and 5.              |"
        write(*,*) "|      - Please check 'config.h'.                          |"
        write(*,*) "+ ======================================================== +"
        error stop
#endif

#if (SPH_MODEL < 1 || SPH_MODEL > 6)
        write(*,*) "+ ======================================================== +"
        write(*,*) "|   Fatal Error in setup:                                  |"
        write(*,*) "|      - SPH_MODEL must be between 1 and 6.                |"
        write(*,*) "|      - Please check 'config.h'.                          |"
        write(*,*) "+ ======================================================== +"
        error stop
#endif

#if (WALL_MODEL < 1 || WALL_MODEL > 3)
        write(*,*) "+ ======================================================== +"
        write(*,*) "|   Fatal Error in setup:                                  |"
        write(*,*) "|      - WALL_MODEL must be between 1 and 3.               |"
        write(*,*) "|      - Please check 'config.h'.                          |"
        write(*,*) "+ ======================================================== +"
        error stop
#endif

        ! ==================================================================== !
        !   2. Boundary Condition Check
        ! ==================================================================== !
#if (TARGET_PROBLEM == 1)
#if (U_BOUNDARY_TOP    != 1 && U_BOUNDARY_TOP    != 2) || \
    (U_BOUNDARY_BOTTOM != 1 && U_BOUNDARY_BOTTOM != 2) || \
    (U_BOUNDARY_LEFT   != 1 && U_BOUNDARY_LEFT   != 2) || \
    (U_BOUNDARY_RIGHT  != 1 && U_BOUNDARY_RIGHT  != 2)
        write(*,*) "+ ======================================================== +"
        write(*,*) "|   Fatal Error in setup:                                  |"
        write(*,*) "|      - TARGET_PROBLEM: Diffusion Equation Test           |"
        write(*,*) "|      - U_BOUNDARY_* must be 1 or 2.                      |"
        write(*,*) "|      - Please check 'config.h'.                          |"
        write(*,*) "+ ======================================================== +"
        error stop
#endif
#endif

#if (TARGET_PROBLEM == 2)
#if (U_BOUNDARY_TOP    != 1) || \
    (U_BOUNDARY_BOTTOM != 1) || \
    (U_BOUNDARY_LEFT   != 1) || \
    (U_BOUNDARY_RIGHT  != 1)
        write(*,*) "+ ======================================================== +"
        write(*,*) "|   Fatal Error in setup:                                  |"
        write(*,*) "|      - TARGET_PROBLEM: Taylor-Green Vortex               |"
        write(*,*) "|      - U_BOUNDARY_* must be 1.                           |"
        write(*,*) "|      - Please check 'config.h'.                          |"
        write(*,*) "+ ======================================================== +"
        error stop
#endif
#endif

#if (TARGET_PROBLEM == 3)
#if (U_BOUNDARY_TOP    != 3) || \
    (U_BOUNDARY_BOTTOM != 2) || \
    (U_BOUNDARY_LEFT   != 2) || \
    (U_BOUNDARY_RIGHT  != 2)
        write(*,*) "+ ======================================================== +"
        write(*,*) "|   Fatal Error in setup:                                  |"
        write(*,*) "|      - TARGET_PROBLEM: Lid-driven Cavity Flow            |"
        write(*,*) "|      - U_BOUNDARY_TOP         must be 3.                 |"
        write(*,*) "|      - All other U_BOUNDARY_* must be 2.                 |"
        write(*,*) "|      - Please check 'config.h'.                          |"
        write(*,*) "+ ======================================================== +"
        error stop
#endif
#endif

#if (TARGET_PROBLEM == 4)
#if (U_BOUNDARY_TOP      != 1 && U_BOUNDARY_TOP    != 2) || \
    (U_BOUNDARY_BOTTOM   != 1 && U_BOUNDARY_BOTTOM != 2) || \
    (U_BOUNDARY_LEFT     != 1 && U_BOUNDARY_LEFT   != 2) || \
    (U_BOUNDARY_RIGHT    != 1 && U_BOUNDARY_RIGHT  != 2) || \
    (TEM_BOUNDARY_TOP    != 1) || \
    (TEM_BOUNDARY_BOTTOM != 1) || \
    (TEM_BOUNDARY_LEFT   != 2) || \
    (TEM_BOUNDARY_RIGHT  != 2)
        write(*,*) "+ ======================================================== +"
        write(*,*) "|   Fatal Error in setup:                                  |"
        write(*,*) "|      - TARGET_PROBLEM: Boussinesq Convection             |"
        write(*,*) "|      - U_BOUNDARY_*                  must be 1 or 2.     |"
        write(*,*) "|      - TEM_BOUNDARY_TOP  and _BOTTOM must be 1.          |"
        write(*,*) "|      - TEM_BOUNDARY_LEFT and _RIGHT  must be 2.          |"
        write(*,*) "|      - Please check 'config.h'.                          |"
        write(*,*) "+ ======================================================== +"
        error stop
#endif
#endif

        ! ==================================================================== !
        !   3. Valid Range Check
        ! ==================================================================== !
#if (TARGET_PROBLEM == 1)
        if (param%len_x /= 1.0d0 .or. param%len_y /= 1.0d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - For Diffusion Equation Test, LEN_X and LEN_Y      |"
            write(*,*) "|        must be exactly 1.0.                              |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif
#endif

#if (TARGET_PROBLEM == 2)
        if (param%tg_a <= 0 .or. param%tg_b <= 0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - TG_A and TG_B must be positive.                   |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif
#endif

        if (param%len_x <= 0.0d0 .or. param%len_y <= 0.0d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - LEN_X and LEN_Y must be positive.                 |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        if (param%num_x <= 0 .or. param%num_y <= 0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - NUM_X and NUM_Y must be positive.                 |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        if (param%start_step <= 0 .or. param%end_step <= 0 .or. param%write_step <= 0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - START_STEP must be positive.                      |"
            write(*,*) "|      - END_STEP   must be positive.                      |"
            write(*,*) "|      - WRITE_STEP must be positive.                      |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        if (param%start_step >= param%end_step) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - START_STEP must be less than END_STEP.            |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        if (param%coe_CFL <= 0.0d0 .or. param%coe_dif <= 0.0d0 .or. &
            param%coe_CFL >= 1.0d0 .or. param%coe_dif >= 1.0d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - COE_CFL and COE_DIF must be between 0 and 1.      |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        if (param%zeta_RSST < 1.0d0 .or. param%xi_VIM < 1.0d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - ZETA_RSST and XI_VIM must be 1.0 or greater.      |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        if (param%rho_ref <= 0.0d0 .or. param%vis_ref   <= 0.0d0 .or. &
            param%K_ref   <= 0.0d0 .or. param%k_th_ref  <= 0.0d0 .or. &
            param%cp_ref  <= 0.0d0 .or. param%alpha_ref <= 0.0d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - Physical properties must be positive.             |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        if (param%gravity < 0.0d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - GRAVITY must be non-negative.                     |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

#if (TARGET_PROBLEM == 1)
        if (param%pos_pert < 0.0d0 .or. param%pos_pert >= 0.5d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - POS_PERT must be between 0.0 and 0.5              |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif
#endif

        if (param%coe_h <= 0.0d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - COE_H must be positive.                           |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        if (param%PST_c < 0.0d0 .or. param%coe_delta_sph < 0.0d0) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - PST_C and COE_DELTA_SPH must be non-negative.     |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

        ! ==================================================================== !
        !   4. Isotropic Particle Spacing Check
        ! ==================================================================== !
        ! Check if dx is exactly equal to dy
        dx = param%len_x / dble(param%num_x)
        dy = param%len_y / dble(param%num_y)
        if (abs(dx - dy) > 1.0d-8) then
            write(*,*) "+ ======================================================== +"
            write(*,*) "|   Fatal Error in setup:                                  |"
            write(*,*) "|      - Particle spacing must be isotropic (dx == dy).    |"
            write(*,*) "|      - The ratio of LEN_X to LEN_Y must exactly match    |"
            write(*,*) "|        the ratio of NUM_X to NUM_Y.                      |"
            write(*,*) "|      - Please check 'config.h'.                          |"
            write(*,*) "+ ======================================================== +"
            error stop
        endif

    end subroutine check_param

end module check_param_mod