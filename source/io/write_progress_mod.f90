! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!     This file logs the simulation progress to the terminal and log file.     !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module write_progress_mod
    use global_types, only: Param_type

    implicit none

contains

    subroutine write_progress(step, param, wtime_start, wtime_current)
        integer         , intent(in) :: step
        type(Param_type), intent(in) :: param
        double precision, intent(in) :: wtime_start, wtime_current

        character(len=20)   :: bar_str
        character(len=1024) :: file_name
        integer             :: current_loop_count, num_equals, un
        double precision    :: ratio, percent

        ! ==================================================================== !
        !   1. Calculate progress
        ! ==================================================================== !
        if (trim(adjustl(param%read_name)) == "new") then
            current_loop_count = step
        else
            current_loop_count = step - param%start_step
        endif

        ratio   = dble(current_loop_count) / dble(param%total_step)
        percent = ratio * 100.0d0

        ! ==================================================================== !
        !   2. Create progress bar
        ! ==================================================================== !
        num_equals = int(ratio * 20.0d0)
        bar_str    = repeat("=", num_equals) // repeat(" ", 20 - num_equals)

        ! ==================================================================== !
        !   3. Write to terminal & log file
        ! ==================================================================== !
        ! Log to terminal
        write(*, "(a, a, a, f6.2, a, es11.4, a)") &
            "   Progress: [", bar_str, "] ", percent, "%  |  Elapsed Time: ", &
            wtime_current - wtime_start, " [s]"

        ! Log to `results/SAVE_NAME/config/run.log`
        file_name = "results/" // trim(adjustl(param%save_name)) // &
                    "/config/run.log"

        open(newunit=un, file=trim(file_name), status="unknown", &
             position="append", form="formatted")

        write(un, "(a, a, a, f6.2, a, es11.4, a)") &
            "   Progress: [", bar_str, "] ", percent, "%  |  Elapsed Time: ", &
            wtime_current - wtime_start, " [s]"
            
        close(un)

    end subroutine write_progress

end module write_progress_mod