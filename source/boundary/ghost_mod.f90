! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!         This file drives the following two tasks:                            !
!         (1) Interpolate fluid properties onto the virtual markers            !
!         (2) Extrapolate them to the paired ghost wall particles              !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module ghost_mod
    use omp_lib
    use global_types, only: Param_type, SP_type, VM_type, Cell_type

! Module for interpolation
#if   (WALL_MODEL == 1)
    use interpolate_CSPH_mod,     only: interpolate_CSPH

#elif (WALL_MODEL == 2) || (WALL_MODEL == 3)
    use interpolate_LSSPH_B_mod,  only: interpolate_LSSPH_B

#endif

! Module for extrapolation
#if (TARGET_PROBLEM == 1)
    use extrapolate_diff_test_mod, only: extrapolate_diff_test

#else
    use extrapolate_VM_to_WL_mod , only: extrapolate_VM_to_WL

#endif

    implicit none

contains

    subroutine ghost(param, SP, VM, cell)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(VM_type)   , intent(inout) :: VM
        type(Cell_type) , intent(in)    :: cell

        integer :: me

        !$omp parallel default(none) &
        !$omp shared(param, SP, VM, cell) &
        !$omp private(me)
        !$omp do
        do me = 1, SP%num_ext
            ! ================================================================ !
            !   1. Interpolate fluid properties onto the virtual markers
            ! ================================================================ !
#if   (WALL_MODEL == 1)
            call interpolate_CSPH   (me, param, SP, VM, cell)
#elif (WALL_MODEL == 2) || (WALL_MODEL == 3)
            call interpolate_LSSPH_B(me, param, SP, VM, cell)
#endif

            ! ================================================================ !
            !   2. Extrapolate to the paired ghost wall particles
            ! ================================================================ !
#if (TARGET_PROBLEM == 1)
            call extrapolate_diff_test(me, param, SP, VM)
#else
            call extrapolate_VM_to_WL (me, param, SP, VM)
#endif

        enddo
        !$omp enddo
        !$omp end parallel

    end subroutine ghost

end module ghost_mod