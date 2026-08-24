! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!  This main program file orchestrates the overall flow of the SPH simulation. !
!                                                                              !
! ============================================================================ !

#include "../config.h"

program main

    ! ======================================================================== !
    !   1. Libraries & Modules
    ! ======================================================================== !
    use omp_lib
    use global_types            , only: Param_type, SP_type, VM_type, Cell_type
    use init_param_mod          , only: init_param
    use check_param_mod         , only: check_param
    use init_particle_mod       , only: init_particle
    use init_virtual_markers_mod, only: init_virtual_markers
    use init_cell_mod           , only: init_cell
    use update_cell_mod         , only: update_cell
    use RK2_mod                 , only: RK2
    use RK4_mod                 , only: RK4
    use PST_mod                 , only: PST
    use check_steady_state_mod  , only: check_steady_state
    use write_param_mod         , only: write_param
    use write_data_mod          , only: write_data
    use write_init_info_mod     , only: write_init_info
    use write_progress_mod      , only: write_progress
    implicit none

    ! ======================================================================== !
    !   2. Variable Declarations
    ! ======================================================================== !
    type(Param_type) :: param   ! Simulation parameters
    type(SP_type)    :: SP      ! Smoothed Particles (SP) data
    type(VM_type)    :: VM      ! Virtual Markers (VM) data
    type(Cell_type)  :: cell    ! Cell linked list data

    integer          :: step, is_steady, loop_start, log_interval
    double precision :: wtime_start, wtime_current  ! Wall-clock time

    ! ======================================================================== !
    !   3. Parameter Initialization & Check
    ! ======================================================================== !
    ! Initialize the simulation parameters (`param`)
    call init_param(param)

    ! Check `param` defined by the user
    call check_param(param)

    ! ======================================================================== !
    !   4. OpenMP Setup
    ! ======================================================================== !
    ! Set up the number of threads in OpenMP
    call omp_set_dynamic(.false.)
    call omp_set_num_threads(param%omp_threads)

    ! ======================================================================== !
    !   5. Particle Initialization
    ! ======================================================================== !
    ! Initialize the internal fluid particles and external ghost wall particles
    ! This subroutine drives the following three tasks:
    !    - (1) Set particle positions
    !    - (2) Classify the particle types
    !    - (3) Impose the initial conditions
    call init_particle(param, SP)

    ! Initialize the virtual markers used in the multi-layer ghost particle scheme
#if (WALL_MODEL <= 3)
    call init_virtual_markers(param, SP, VM)
#endif

    ! ======================================================================== !
    !   6. Cell Initialization
    ! ======================================================================== !
    ! Initialize the cell list
    call init_cell(param, SP, VM, cell)
    call update_cell(param, SP, cell)

    ! ======================================================================== !
    !   7. Export Simulation Setup & Fundamental Data
    ! ======================================================================== !
    ! Write parameters and data into the `results/SAVE_NAME/config/` directory
    if (trim(adjustl(param%read_name)) == "new") then
        call write_param(param, SP, VM, cell)
        call write_data(0, param, SP)
    endif

    ! Write initial information to the terminal and log file
    call write_init_info(param, SP)

    ! ======================================================================== !
    !   8. Setup for Time Loop
    ! ======================================================================== !
    ! Determine the starting step
    if (trim(adjustl(param%read_name)) == "new") then
        loop_start = param%start_step
    else
        loop_start = param%start_step + 1
    endif

    ! Record the wall-clock start time
    wtime_start = omp_get_wtime()

    ! Setup for the progress bar
    log_interval = max(param%total_step/100, 1)
    

    ! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> !
    !   9. Time Loop
    ! >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> !
    do step = loop_start, param%end_step

        ! ==================================================================== !
        !   9-1. Time Integration using the Runge-Kutta method
        ! ==================================================================== !
#if   (RK == 2)
        call RK2(param, SP, VM, cell)  ! Using 2nd-order RK
#elif (RK == 4)
        call RK4(param, SP, VM, cell)  ! Using 4th-order RK
#endif
        ! ==================================================================== !
        !   9-2. Particle Shifting Technique
        ! ==================================================================== !
#if (TARGET_PROBLEM != 1)
        call PST(param, SP, VM, cell)
#endif

        ! ==================================================================== !
        !   9-3. Check if the simulation reaches a steady state
        ! ==================================================================== !
#if (TARGET_PROBLEM == 1)
        call check_steady_state(is_steady, param, SP)

        if (is_steady == 1) then
            write(*,*) "  Reached a steady state at step: ", step
            call write_data(step, param, SP)
            wtime_current = omp_get_wtime()
            call write_progress(step, param, wtime_start, wtime_current)
            exit
        endif
#endif

        ! ==================================================================== !
        !   9-4. Export data to `results/SAVE_NAME/data/step.dat`
        ! ==================================================================== !
        if (mod(step, param%write_step) == 0) then
            call write_data(step, param, SP)
        endif

        ! ==================================================================== !
        !   9-5. Log
        ! ==================================================================== !
        if (mod(step, log_interval) == 0 .or. step == param%end_step) then
            wtime_current = omp_get_wtime()
            call write_progress(step, param, wtime_start, wtime_current)
        endif

    enddo

end program main