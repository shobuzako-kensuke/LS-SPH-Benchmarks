! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!            This file integrates the governing equations over time            !
!                  using the fourth-order Runge-Kutta method.                  !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module RK4_mod
    use omp_lib
    use global_types     , only: Param_type, SP_type, VM_type, Cell_type
    use update_cell_mod  , only: update_cell
    use calculate_RHS_mod, only: calculate_RHS

#if (1 <= WALL_MODEL) && (WALL_MODEL <= 3)
    use ghost_mod        , only: ghost
#endif

    implicit none

contains

    subroutine RK4(param, SP, VM, cell)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(VM_type)   , intent(inout) :: VM
        type(Cell_type) , intent(inout) :: cell

        integer          :: RK_step, n, me
        double precision :: dt_1, dt_2, c_sq, rho_ref

        ! ==================================================================== !
        !   1. Initialize for RK4
        ! ==================================================================== !
        n = SP%num_int

        c_sq    = (param%sound_speed)**2  ! Used for equation of state
        rho_ref = param%rho_ref

        !$omp parallel default(none) &
        !$omp shared(SP, n) &
        !$omp private(me)
        !$omp do
        do me = 1, n
            SP%x_old  (me) = SP%x  (me)  ! Store each value at step n
            SP%y_old  (me) = SP%y  (me)
            SP%u_old  (me) = SP%u  (me)
            SP%v_old  (me) = SP%v  (me)
            SP%rho_old(me) = SP%rho(me)
#if (TARGET_PROBLEM == 4)
            SP%tem_old(me) = SP%tem(me)
#endif

            SP%x_new  (me) = SP%x  (me)  ! Initialize accumulators for step n+1
            SP%y_new  (me) = SP%y  (me)
            SP%u_new  (me) = SP%u  (me)
            SP%v_new  (me) = SP%v  (me)
            SP%rho_new(me) = SP%rho(me)
#if (TARGET_PROBLEM == 4)
            SP%tem_new(me) = SP%tem(me)
#endif
        enddo
        !$omp enddo
        !$omp end parallel

        ! ==================================================================== !
        !   2. RK4 Loop 
        ! ==================================================================== !
        do RK_step = 1, 4

            ! ================================================================ !
            !   2-1. Calculate right-hand sides (RHS) of governing equations
            ! ================================================================ !
            call calculate_RHS(param, SP, cell)

            ! ================================================================ !
            !   2-2. Update each value using RK4
            ! ================================================================ !
            ! Calculate the effective `dt` at each RK stage
            if (RK_step == 1) then
                dt_1 = param%dt / 6.0d0  ! `dt_1` is used for accumulator
                dt_2 = param%dt / 2.0d0  ! `dt_2` is used for intermediate state

            elseif (RK_step == 2) then
                dt_1 = param%dt / 3.0d0
                dt_2 = param%dt / 2.0d0

            elseif (RK_step == 3) then
                dt_1 = param%dt / 3.0d0
                dt_2 = param%dt

            elseif (RK_step == 4) then
                dt_1 = param%dt / 6.0d0
                dt_2 = 0.0d0

            endif

            !$omp parallel default(none) &
            !$omp shared(SP, RK_step, dt_1, dt_2, n, c_sq, rho_ref) &
            !$omp private(me)
            !$omp do
            do me = 1, n

                ! Accumulate the weighted contribution for the final state n+1
                SP%u_new  (me) = SP%u_new  (me) + SP%RHS_u  (me) * dt_1
#if (TARGET_PROBLEM != 1)
                SP%v_new  (me) = SP%v_new  (me) + SP%RHS_v  (me) * dt_1
                SP%x_new  (me) = SP%x_new  (me) + SP%u      (me) * dt_1
                SP%y_new  (me) = SP%y_new  (me) + SP%v      (me) * dt_1
                SP%rho_new(me) = SP%rho_new(me) + SP%RHS_rho(me) * dt_1
#endif
#if (TARGET_PROBLEM == 4)
                SP%tem_new(me) = SP%tem_new(me) + SP%RHS_tem(me) * dt_1
#endif

                ! Calculate the intermediate state for the next RK stage
                if (RK_step < 4) then
#if (TARGET_PROBLEM != 1)
                    SP%x  (me) = SP%x_old  (me) + SP%u      (me) * dt_2
                    SP%y  (me) = SP%y_old  (me) + SP%v      (me) * dt_2
                    SP%v  (me) = SP%v_old  (me) + SP%RHS_v  (me) * dt_2
                    SP%rho(me) = SP%rho_old(me) + SP%RHS_rho(me) * dt_2
#endif
                    ! Note: SP%u is also used for Diffusion Equations Test
                    SP%u  (me) = SP%u_old  (me) + SP%RHS_u  (me) * dt_2

#if (TARGET_PROBLEM == 4)
                    SP%tem(me) = SP%tem_old(me) + SP%RHS_tem(me) * dt_2
#endif

                else
                    SP%u  (me) = SP%u_new  (me)
#if (TARGET_PROBLEM != 1)
                    SP%v  (me) = SP%v_new  (me)
                    SP%x  (me) = SP%x_new  (me)
                    SP%y  (me) = SP%y_new  (me)
                    SP%rho(me) = SP%rho_new(me)
#endif
#if (TARGET_PROBLEM == 4)
                    SP%tem(me) = SP%tem_new(me)
#endif

                endif

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

    end subroutine RK4

end module RK4_mod