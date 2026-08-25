! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!    This file calculates the Right-Hand Sides (RHS) of governing equations.   !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module calculate_RHS_mod
    use omp_lib
    use global_types     , only: Param_type, SP_type, Cell_type

#if   (SPH_MODEL <= 2)
    use classical_SPH_mod, only: classical_SPH
#elif (SPH_MODEL >= 3)
    use LSSPH_A_mod      , only: LSSPH_A
#endif

    implicit none

contains

    subroutine calculate_RHS(param, SP, cell)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(Cell_type) , intent(in)    :: cell

        integer :: me

        !$omp parallel default(none) &
        !$omp shared(param, SP, cell) &
        !$omp private(me)
        !$omp do
        do me = 1, SP%num_int

#if   (SPH_MODEL <= 2)
            call classical_SPH(me, param, SP, cell)
#elif (SPH_MODEL >= 3)
            call LSSPH_A(me, param, SP, cell)
#endif

        enddo
        !$omp enddo
        !$omp end parallel

    end subroutine calculate_RHS

end module calculate_RHS_mod