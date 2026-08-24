! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!             This file extrapolates the values of virtual markers             !
!                      to the paired ghost wall particles.                     !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module extrapolate_diff_test_mod
    use global_types, only: Param_type, SP_type, VM_type

    implicit none
    
    double precision, parameter, private :: pi = acos(-1.0d0)

contains
    pure subroutine extrapolate_diff_test(me, param, SP, VM)
        integer         , intent(in)    :: me
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(VM_type)   , intent(in)    :: VM

        integer :: you

        ! Setup
        you = VM%pair_WL_idx(me)  ! Paired ghost wall particle

        ! ==================================================================== !
        !   1. Bottom
        ! ==================================================================== !
        if (VM%ptype(me) == 1) then
    
#if   (U_BOUNDARY_BOTTOM == 1)
            ! Neumann condition
            SP%u(you) = VM%u(me)

#elif (U_BOUNDARY_BOTTOM == 2)
            ! Dirichlet condition
            SP%u(you) = 2.0d0* (sin(pi * (VM%x(me) - param%WL_thick))) - VM%u(me)

#endif

        ! ==================================================================== !
        !   2. Top
        ! ==================================================================== !
        elseif (VM%ptype(me) == 2) then

#if   (U_BOUNDARY_TOP == 1)
            ! Neumann condition
            SP%u(you) = VM%u(me)

#elif (U_BOUNDARY_TOP == 2)
            ! Dirichlet condition
            SP%u(you) = 2.0d0* (-sin(pi * (VM%x(me) - param%WL_thick))) - VM%u(me)

#endif

        ! ==================================================================== !
        !   3. Left
        ! ==================================================================== !
        elseif (VM%ptype(me) == 3) then

#if   (U_BOUNDARY_LEFT == 1)
            ! Neumann condition
            SP%u(you) = VM%u(me) &
                      + pi * cos(pi * (VM%y(me) - param%WL_thick)) * (SP%x(you) - VM%x(me))

#elif (U_BOUNDARY_LEFT == 2)
            ! Dirichlet condition
            SP%u(you) = - VM%u(me)

#endif

        ! ==================================================================== !
        !   4. Right
        ! ==================================================================== !
        elseif (VM%ptype(me) == 4) then

#if   (U_BOUNDARY_RIGHT == 1)
            ! Neumann condition
            SP%u(you) = VM%u(me) &
                      + (-pi) * cos(pi * (VM%y(me) - param%WL_thick)) * (SP%x(you) - VM%x(me))

#elif (U_BOUNDARY_RIGHT == 2)
            ! Dirichlet condition
            SP%u(you) = - VM%u(me)

#endif

        ! ==================================================================== !
        !   5. Corners: Dirichlet conditions
        ! ==================================================================== !
        elseif ((VM%ptype(me) == 5) .or. (VM%ptype(me) == 6).or. &
                (VM%ptype(me) == 7) .or. (VM%ptype(me) == 8)) then
                SP%u(you) = - VM%u(me)

        endif

    end subroutine extrapolate_diff_test
    
end module extrapolate_diff_test_mod