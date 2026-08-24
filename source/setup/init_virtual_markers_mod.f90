! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!                This file initializes the virtual markers (VM)                !
!              used in the multi-layer fixed ghost particle scheme.            !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module init_virtual_markers_mod
    use global_types, only: Param_type, SP_type, VM_type

    implicit none

contains

    subroutine init_virtual_markers(param, SP, VM)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(in)    :: SP
        type(VM_type)   , intent(inout) :: VM

        integer          :: me, you
        double precision :: x_min, x_max, y_min, y_max

        ! ==================================================================== !
        !   Note: Valid only for the multi-layer fixed ghost particle scheme
        ! ==================================================================== !
#if (WALL_MODEL <= 3)
        
        ! Allocate arrays in `VM_type`
        allocate(VM%ptype      (SP%num_ext))
        allocate(VM%pair_WL_idx(SP%num_ext))
        allocate(VM%x          (SP%num_ext))
        allocate(VM%y          (SP%num_ext))
        allocate(VM%u          (SP%num_ext))
        allocate(VM%v          (SP%num_ext))
        allocate(VM%pre        (SP%num_ext))
#if (TARGET_PROBLEM == 4)
        allocate(VM%tem        (SP%num_ext))
#endif
        allocate(VM%n_x        (SP%num_ext))
        allocate(VM%n_y        (SP%num_ext))

        ! Determine the boundaries of the internal fluid region
        x_min = 0.0d0       + param%WL_thick
        x_max = param%len_x + param%WL_thick
        y_min = 0.0d0       + param%WL_thick
        y_max = param%len_y + param%WL_thick

        ! Set virtual marker positions
        ! me : Index of a virtual marker
        ! you: Index of the paired ghost wall particle
        me = 0

        do you = SP%num_int+1, SP%num_total
            me = me + 1
            VM%pair_WL_idx(me) = you  ! Store the index of the paired ghost wall particle

            ! Bottom
            if (SP%ptype(you) == 1) then
                VM%ptype(me) = 1
                VM%x    (me) = SP%x(you)
                VM%y    (me) = 2.0d0*y_min - SP%y(you)
                VM%n_x  (me) = 0.0d0
                VM%n_y  (me) = -1.0d0

            ! Top
            elseif (SP%ptype(you) == 2) then
                VM%ptype(me) = 2
                VM%x    (me) = SP%x(you)
                VM%y    (me) = 2.0d0*y_max - SP%y(you)
                VM%n_x  (me) = 0.0d0
                VM%n_y  (me) = 1.0d0

            ! Left
            elseif (SP%ptype(you) == 3) then
                VM%ptype(me) = 3
                VM%x    (me) = 2.0d0*x_min - SP%x(you)
                VM%y    (me) = SP%y(you)
                VM%n_x  (me) = -1.0d0
                VM%n_y  (me) = 0.0d0

            ! Right
            elseif (SP%ptype(you) == 4) then
                VM%ptype(me) = 4
                VM%x    (me) = 2.0d0*x_max - SP%x(you)
                VM%y    (me) = SP%y(you)
                VM%n_x  (me) = 1.0d0
                VM%n_y  (me) = 0.0d0

            ! Left bottom
            elseif (SP%ptype(you) == 5) then
                VM%ptype(me) = 5
                VM%x    (me) = 2.0d0*x_min - SP%x(you)
                VM%y    (me) = 2.0d0*y_min - SP%y(you)
                VM%n_x  (me) = -1.0d0 / sqrt(2.0d0)
                VM%n_y  (me) = -1.0d0 / sqrt(2.0d0)
            
            ! Right bottom
            elseif (SP%ptype(you) == 6) then
                VM%ptype(me) = 6
                VM%x    (me) = 2.0d0*x_max - SP%x(you)
                VM%y    (me) = 2.0d0*y_min - SP%y(you)
                VM%n_x  (me) =  1.0d0 / sqrt(2.0d0)
                VM%n_y  (me) = -1.0d0 / sqrt(2.0d0)
            
            ! Left top
            elseif (SP%ptype(you) == 7) then
                VM%ptype(me) = 7
                VM%x    (me) = 2.0d0*x_min - SP%x(you)
                VM%y    (me) = 2.0d0*y_max - SP%y(you)
                VM%n_x  (me) = -1.0d0 / sqrt(2.0d0)
                VM%n_y  (me) =  1.0d0 / sqrt(2.0d0)

            ! Right top
            elseif (SP%ptype(you) == 8) then
                VM%ptype(me) = 8
                VM%x    (me) = 2.0d0*x_max - SP%x(you)
                VM%y    (me) = 2.0d0*y_max - SP%y(you)
                VM%n_x  (me) =  1.0d0 / sqrt(2.0d0)
                VM%n_y  (me) =  1.0d0 / sqrt(2.0d0)

            else
                write(*,*) "+ ======================================================== +"
                write(*,*) "|   Fatal Error in setup:                                  |"
                write(*,*) "|   'source/setup/init_virtual_markers_mod.f90'.           |"
                write(*,*) "+ ======================================================== +"
                error stop
                
            endif
        enddo

#endif

    end subroutine init_virtual_markers

end module init_virtual_markers_mod
