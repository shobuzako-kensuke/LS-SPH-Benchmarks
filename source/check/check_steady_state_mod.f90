! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!          This file checks if the simulation reaches a steady state.          !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module check_steady_state_mod
    use omp_lib
    use global_types      , only: Param_type, SP_type
    
    implicit none

contains

    subroutine check_steady_state(is_steady, param, SP)
        integer         , intent(out)   :: is_steady
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP

        integer :: me
        double precision :: df_max, df_tmp

        df_max = 0.0d0

        ! ==================================================================== !
        !   1. Calculate the maximum difference
        ! ==================================================================== !
        !$omp parallel default(none) &
        !$omp shared(SP, df_max) &
        !$omp private(me, df_tmp)
        !$omp do reduction(max: df_max)
        do me = 1, SP%num_int
            df_tmp = abs(SP%f_previous(me) - SP%u(me))  ! Difference between (n-1) step and current step
            df_max = max(df_tmp, df_max)
        enddo
        !$omp enddo
        !$omp end parallel


        ! ==================================================================== !
        !   2. Check the steady-state criterion
        ! ==================================================================== !
        if (df_max < param%threshold) then
            is_steady = 1

        else
            is_steady = 0

            !$omp parallel default(none) &
            !$omp shared(SP) &
            !$omp private(me)
            !$omp do
            do me = 1, SP%num_int
                SP%f_previous(me) = SP%u(me)  ! Store the value at current step to `f_previous`
            enddo
            !$omp enddo
            !$omp end parallel

        endif

    end subroutine check_steady_state

end module check_steady_state_mod