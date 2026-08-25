! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!        This file reads and restores the simulation data for a restart.       !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module restart_mod
    use global_types, only: Param_type, SP_type

    implicit none

contains

    subroutine restart_closed_box(param, SP)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP

        character(len=1024) :: restart_id, file_name
        integer             :: un

        ! ======================================================================== !
        !   1. Setup of directory paths
        ! ======================================================================== !
        write(restart_id, *) param%start_step
        file_name = "results/" // trim(adjustl(param%read_name)) // &
                    "/data/" // trim(adjustl(restart_id)) // ".dat"

        ! ======================================================================== !
        !   2. Read and restore the simulation data
        ! ======================================================================== !
        open(newunit=un, file=trim(adjustl(file_name)), status="old", &
             form="unformatted", access="stream")
             
        read(un) SP%ptype(1 : SP%num_total)
        read(un) SP%x    (1 : SP%num_total)
        read(un) SP%y    (1 : SP%num_total)
        read(un) SP%u    (1 : SP%num_total)
        read(un) SP%v    (1 : SP%num_total)
        read(un) SP%rho  (1 : SP%num_total)
        read(un) SP%pre  (1 : SP%num_total)
#if (TARGET_PROBLEM == 4)
        read(un) SP%tem  (1 : SP%num_total)
#endif

        close(un)

    end subroutine restart_closed_box

end module restart_mod