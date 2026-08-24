! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!            This file drives the Particle Shifting Technique (PST).           !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module PST_mod
    use global_types         , only: Param_type, SP_type, VM_type, Cell_type
    use shift_interpolate_mod, only: shift_interpolate
    use update_cell_mod      , only: update_cell

#if (1 <= WALL_MODEL) && (WALL_MODEL <= 3)
    use ghost_mod            , only: ghost
#endif

    implicit none

contains

    subroutine PST(param, SP, VM, cell)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(VM_type)   , intent(inout) :: VM
        type(Cell_type) , intent(inout) :: cell

        integer :: me
        double precision :: U_max, U_tmp, coe_PST, c_sq, rho_ref

        U_max = 0.0d0

        c_sq    = (param%sound_speed)**2  ! Used for equation of state
        rho_ref = param%rho_ref

        !$omp parallel default(none) &
        !$omp shared(param, SP, cell, U_max, coe_PST, c_sq, rho_ref) &
        !$omp private(me, U_tmp)

        ! ==================================================================== !
        !   1. Calculate the coefficient of PST
        ! ==================================================================== !
        !$omp do reduction(max: U_max)
        do me = 1, SP%num_int
            U_tmp = sqrt(SP%u(me)**2 + SP%v(me)**2)  ! Speed of particle i
            U_max = max(U_max, U_tmp)                ! Store the max speed
        enddo
        !$omp enddo

        ! Coefficient of PST
        !$omp single
        coe_PST = param%PST_c * U_max * param%dt * param%h
        !$omp end single

        ! ==================================================================== !
        !   2. Shift and interpolate the particles using PST
        ! ==================================================================== !
        !$omp do
        do me = 1, SP%num_int
            
#if (TARGET_PROBLEM <= 4)
            call shift_interpolate(me, coe_PST, param, SP, cell)  ! No free surface

#else
            ! メモ：自由表面が存在する場合の計算を書く
            !    - 今のところ，SP%ptypeでif分岐させるアイデア
            !    - if文があまりに遅いなら，ソートする方法も検討すること
            !    - 自由表面が存在する場合，calculate_RHSの方も#if分岐を導入すること

#endif

        enddo
        !$omp enddo

        ! ==================================================================== !
        !   3. Update properties
        !      - Note: `_old` means the new property (`_old` was used for RK)
        ! ==================================================================== !
        !$omp do
        do me = 1, SP%num_int
            SP%x  (me) = SP%x_old  (me)
            SP%y  (me) = SP%y_old  (me)
            SP%u  (me) = SP%u_old  (me)
            SP%v  (me) = SP%v_old  (me)
            SP%rho(me) = SP%rho_old(me)
#if (TARGET_PROBLEM == 4)
            SP%tem(me) = SP%tem_old(me)
#endif

            ! Update pressure using equation of state
            SP%pre(me) = c_sq * (SP%rho(me) - rho_ref)
        enddo
        !$omp enddo
        !$omp end parallel

        ! ==================================================================== !
        !   4. Update Cell List
        ! ==================================================================== !
#if (TARGET_PROBLEM != 1)
        call update_cell(param, SP, cell)
#endif

        ! ==================================================================== !
        !   5. Update virtual markers' values
        ! ==================================================================== !
#if (1 <= WALL_MODEL) && (WALL_MODEL <= 3)
        call ghost(param, SP, VM, cell)
#endif

    end subroutine PST

end module PST_mod