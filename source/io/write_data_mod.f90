! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!                    This file exports the simulation data.                    !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module write_data_mod
    use global_types, only: Param_type, SP_type

    implicit none

contains

    subroutine write_data(step, param, SP)
        integer         , intent(in) :: step
        type(Param_type), intent(in) :: param
        type(SP_type)   , intent(in) :: SP
        
        character(len=1024) :: step_str, file_name
        integer             :: un
        
        ! ==================================================================== !
        !   1. Setup
        ! ==================================================================== !
        write(step_str, *) step
        file_name = "results/" // trim(adjustl(param%save_name)) // &
                    "/data/" // trim(adjustl(step_str)) // ".dat"

        ! ==================================================================== !
        !   2. Export Data
        ! ==================================================================== !
        open(newunit=un, file=trim(file_name), &
             status="replace", form="unformatted", access="stream")
        
        write(un) SP%ptype(1 : SP%num_total)
        write(un) SP%x    (1 : SP%num_total)
        write(un) SP%y    (1 : SP%num_total)
        write(un) SP%u    (1 : SP%num_total)
        write(un) SP%v    (1 : SP%num_total)
        write(un) SP%rho  (1 : SP%num_total)
        write(un) SP%pre  (1 : SP%num_total)
#if (TARGET_PROBLEM == 4)
        write(un) SP%tem  (1 : SP%num_total)
#endif

        close(un)

    end subroutine write_data

end module write_data_mod