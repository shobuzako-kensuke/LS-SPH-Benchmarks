! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!            This file integrates the governing equations over time            !
!                  using the second-order Runge-Kutta method.                  !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module RK2_mod
    use omp_lib
    use global_types     , only: Param_type, SP_type, VM_type, Cell_type
    use update_cell_mod  , only: update_cell
    use calculate_RHS_mod, only: calculate_RHS

#if (1 <= WALL_MODEL) && (WALL_MODEL <= 3)
    use ghost_mod        , only: ghost
#endif

    implicit none

contains

    subroutine RK2(param, SP, VM, cell)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(VM_type)   , intent(inout) :: VM
        type(Cell_type) , intent(inout) :: cell

        integer          :: RK_step, n, me
        double precision :: dt_eff, c_sq, rho_ref

        ! ==================================================================== !
        !   1. Initialize for RK2
        ! ==================================================================== !
        n = SP%num_int

        c_sq    = (param%sound_speed)**2  ! Used for equation of state
        rho_ref = param%rho_ref

        !$omp parallel default(none) &
        !$omp shared(SP, n) &
        !$omp private(me)
        !$omp do
        do me = 1, n
            SP%x_old  (me) = SP%x  (me)
            SP%y_old  (me) = SP%y  (me)
            SP%u_old  (me) = SP%u  (me)
            SP%v_old  (me) = SP%v  (me)
            SP%rho_old(me) = SP%rho(me)
#if (TARGET_PROBLEM == 4)
            SP%tem_old(me) = SP%tem(me)
#endif
        enddo
        !$omp enddo
        !$omp end parallel

        ! ==================================================================== !
        !   2. RK2 Loop 
        ! ==================================================================== !
        do RK_step = 1, 2

            ! ================================================================ !
            !   2-1. Calculate right-hand sides (RHS) of governing equations
            ! ================================================================ !
            call calculate_RHS(param, SP, cell)

            ! ================================================================ !
            !   2-2. Update each value using RK2 (Midpoint method)
            ! ================================================================ !
            if (RK_step == 1) then
                dt_eff = param%dt / 2.0d0  ! Used for intermediate state (t + dt/2)
            else
                dt_eff = param%dt          ! Used for final state (t + dt)
            endif

            !$omp parallel default(none) &
            !$omp shared(SP, dt_eff, n, c_sq, rho_ref) &
            !$omp private(me)
            !$omp do
            do me = 1, n

#if (TARGET_PROBLEM != 1)
                SP%x  (me) = SP%x_old  (me) + SP%u      (me) * dt_eff
                SP%y  (me) = SP%y_old  (me) + SP%v      (me) * dt_eff
                SP%v  (me) = SP%v_old  (me) + SP%RHS_v  (me) * dt_eff
                SP%rho(me) = SP%rho_old(me) + SP%RHS_rho(me) * dt_eff
#endif
                ! Note: SP%u is also used for Diffusion Equations Test
                SP%u  (me) = SP%u_old  (me) + SP%RHS_u  (me) * dt_eff

#if (TARGET_PROBLEM == 4)
                SP%tem(me) = SP%tem_old(me) + SP%RHS_tem(me) * dt_eff
#endif

            ! ================================================================ !
            !   2-3. Update pressure using equation of state
            ! ================================================================ !
#if (TARGET_PROBLEM != 1)
                SP%pre(me) = c_sq * (SP%rho(me) - rho_ref)
#endif
            enddo
            !$omp enddo
            !$omp end parallel

            ! ================================================================ !
            !   2-4. Update Cell List
            ! ================================================================ !
#if (TARGET_PROBLEM != 1)
            call update_cell(param, SP, cell)
#endif

            ! ================================================================ !
            !   2-5. Update virtual markers' values
            ! ================================================================ !
#if (WALL_MODEL <= 3)
            call ghost(param, SP, VM, cell)
#endif

        enddo

    end subroutine RK2

end module RK2_mod