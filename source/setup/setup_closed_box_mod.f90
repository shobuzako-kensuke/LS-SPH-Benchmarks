! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!     This file sets particle positions and classifies the particle types      !
!                     for problems with a closed box domain.                   !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module setup_closed_box_mod
    use global_types, only: Param_type, SP_type

    implicit none

contains

    subroutine setup_closed_box(param, SP)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP

        integer :: i
        integer :: num_x_fill, num_y_fill, num_total_fill
        double precision :: x_min, x_max, y_min, y_max
        double precision, allocatable :: x_int(:), y_int(:)
        double precision, allocatable :: x_ext(:), y_ext(:)
        double precision, allocatable :: x_sys(:), y_sys(:)
        
        ! ==================================================================== !
        !   1. Set particle positions
        !      - Fill the entire domain with particles
        ! ==================================================================== !
        ! Number of particles
        num_x_fill     = param%num_x + 2*param%num_WL  ! X-direction
        num_y_fill     = param%num_y + 2*param%num_WL  ! Y-direction
        num_total_fill = num_x_fill * num_y_fill       ! Total

        ! Allocate arrays
        ! _int: Internal particles
        ! _ext: External particles (fixed ghost wall particles)
        ! _sys: All particles (Internal + External particles)
        allocate(x_int(num_total_fill), y_int(num_total_fill))
        allocate(x_ext(num_total_fill), y_ext(num_total_fill))
        allocate(x_sys(num_total_fill), y_sys(num_total_fill))
        
        !---------------------------------------------------------------------
        !   Particle arrangement
        !      - Particles are placed with an offset of dx/2 from the origin.
        !---------------------------------------------------------------------
        !
        !     y ^
        !       | 
        !       |       o              o              o    ...
        !       |        <------------>  <------------>
        !       |              dx              dx
        !       |
        !       |       o              o              o    ...
        !       | <---->
        !       |  dx/2
        !       +--------------------------------------------------------> x
        !     (0,0)
        !
        !       o : Particle position
        !
        ! --------------------------------------------------------------------

        x_sys(1) = param%dx / 2.0d0
        y_sys(1) = param%dx / 2.0d0

        do i = 2, num_total_fill
            if (i <= num_x_fill) then
                x_sys(i) = x_sys(i-1) + param%dx
                y_sys(i) = y_sys(i-1)
            else
                x_sys(i) = x_sys(i - num_x_fill)
                y_sys(i) = y_sys(i - num_x_fill) + param%dx
            endif
        enddo

        ! ==================================================================== !
        !   2. Classify the particle types (ptype)
        !      - Internal fluid particles     : ptype = 0
        !      - External ghost wall particles: ptype = 1-8
        !         * External ghost wall particles will be classified later.
        ! ==================================================================== !
        !
        !   [ Schematic of the particle type (ptype) ]
        !
        !                   x_min             x_max
        !                     |                 |
        !      7 (Left Top)   |     2 (Top)     |  8 (Right Top)
        !    -----------------+-----------------+----------------- y_max
        !                     |                 |
        !        3 (Left)     |    0 (Fluid)    |    4 (Right)
        !                     |                 |
        !    -----------------+-----------------+----------------- y_min
        !      5 (Left Bot)   |   1 (Bottom)    |  6 (Right Bot)
        !                     |                 |
        !   O <-------------->
        !         WL_thick
        !
        !   O: Origin (0,0)
        ! ==================================================================== !
        ! Initialize to zero
        SP%num_int = 0
        SP%num_ext = 0

        ! Determine the boundaries of the internal fluid region
        x_min = 0.0d0       + param%WL_thick
        x_max = param%len_x + param%WL_thick
        y_min = 0.0d0       + param%WL_thick
        y_max = param%len_y + param%WL_thick

        ! Classify the particles into the internal or external types.
        do i = 1, num_total_fill
            if ( (x_min < x_sys(i)) .and. &
                 (x_max > x_sys(i)) .and. &
                 (y_min < y_sys(i)) .and. &
                 (y_max > y_sys(i))        ) then
                
                SP%num_int = SP%num_int + 1   ! Count the internal particles
                x_int(SP%num_int) = x_sys(i)  ! Copy to `_int`
                y_int(SP%num_int) = y_sys(i)

            else
                SP%num_ext = SP%num_ext + 1   ! Count the external particles
                x_ext(SP%num_ext) = x_sys(i)  ! Copy to `_ext`
                y_ext(SP%num_ext) = y_sys(i)

            endif
        enddo
        
        ! Total number of particles
        SP%num_total = SP%num_int + SP%num_ext
        
        ! Allocate arrays in `SP_type`
        allocate(SP%ptype(SP%num_total))
        allocate(SP%x    (SP%num_total))
        allocate(SP%y    (SP%num_total))
        allocate(SP%u    (SP%num_total))
        allocate(SP%v    (SP%num_total))
        allocate(SP%rho  (SP%num_total))
        allocate(SP%pre  (SP%num_total))
#if (TARGET_PROBLEM == 4)
        allocate(SP%tem  (SP%num_total))
#endif

        allocate(SP%x_old  (SP%num_int))
        allocate(SP%y_old  (SP%num_int))
        allocate(SP%u_old  (SP%num_int))
        allocate(SP%v_old  (SP%num_int))
        allocate(SP%rho_old(SP%num_int))
#if (TARGET_PROBLEM == 4)
        allocate(SP%tem_old(SP%num_int))
#endif

#if (RK == 4)
        allocate(SP%x_new  (SP%num_int))
        allocate(SP%y_new  (SP%num_int))
        allocate(SP%u_new  (SP%num_int))
        allocate(SP%v_new  (SP%num_int))
        allocate(SP%rho_new(SP%num_int))
#if (TARGET_PROBLEM == 4)
        allocate(SP%tem_new(SP%num_int))
#endif
#endif

        allocate(SP%RHS_u  (SP%num_int))
        allocate(SP%RHS_v  (SP%num_int))
        allocate(SP%RHS_rho(SP%num_int))
#if (TARGET_PROBLEM == 4)
        allocate(SP%RHS_tem(SP%num_int))
#endif

#if (TARGET_PROBLEM == 1)
        allocate(SP%f_previous(SP%num_int))
        SP%f_previous = 1.0d0
#endif

        ! For internal fluid particles
        SP%ptype(1 : SP%num_int)    = 0
        SP%x    (1 : SP%num_int)    = x_int(1 : SP%num_int)
        SP%y    (1 : SP%num_int)    = y_int(1 : SP%num_int)

        ! For external ghost wall particles
        SP%ptype((SP%num_int + 1):) = 10                     ! Temporary
        SP%x    ((SP%num_int + 1):) = x_ext(1 : SP%num_ext)
        SP%y    ((SP%num_int + 1):) = y_ext(1 : SP%num_ext)

        ! ==================================================================== !
        !   3. Classify the ghost wall particles
        !      - Bottom      : ptype = 1
        !      - Top         : ptype = 2
        !      - Left        : ptype = 3
        !      - Right       : ptype = 4
        !      - Left Bottom : ptype = 5
        !      - Right Bottom: ptype = 6
        !      - Left Top    : ptype = 7
        !      - Right Top   : ptype = 8
        ! ==================================================================== !
        
        do i = SP%num_int + 1, SP%num_total
            
            SP%rho(i) = param%rho_ref                 ! Reference density

            if (SP%y(i) < y_min) then
                SP%ptype(i) = 1                       ! Bottom
                if (SP%x(i) < x_min) SP%ptype(i) = 5  ! Left  Bottom
                if (SP%x(i) > x_max) SP%ptype(i) = 6  ! Right Bottom
            
            elseif (SP%y(i) > y_max) then
                SP%ptype(i) = 2                       ! Top
                if (SP%x(i) < x_min) SP%ptype(i) = 7  ! Left  Top
                if (SP%x(i) > x_max) SP%ptype(i) = 8  ! Right Top
            
            elseif (SP%x(i) < x_min) then
                SP%ptype(i) = 3                       ! Left
            
            elseif (SP%x(i) > x_max) then
                SP%ptype(i) = 4                       ! Right

            else
                write(*,*) "+ ======================================================== +"
                write(*,*) "|   Fatal Error in setup:                                  |"
                write(*,*) "|   'source/setup/setup_closed_box_mod.f90'.               |"
                write(*,*) "+ ======================================================== +"
                error stop

            endif
        enddo

    end subroutine setup_closed_box

end module setup_closed_box_mod