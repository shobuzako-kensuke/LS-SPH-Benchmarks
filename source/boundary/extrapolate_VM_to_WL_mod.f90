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

module extrapolate_VM_to_WL_mod
    use global_types, only: Param_type, SP_type, VM_type

    implicit none

contains

    pure subroutine extrapolate_VM_to_WL(me, param, SP, VM)
        integer         , intent(in)    :: me
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(VM_type)   , intent(in)    :: VM

        integer          :: you
        double precision :: n_x, n_y, u_n

        ! Setup
        you = VM%pair_WL_idx(me)  ! Paired ghost wall particle
        n_x = VM%n_x(me)          ! Copy the normal unit vector
        n_y = VM%n_y(me)

        ! ==================================================================== !
        !   1. Bottom
        ! ==================================================================== !
        if (VM%ptype(me) == 1) then

! Velocity boundary condition
#if   (U_BOUNDARY_BOTTOM == 1)
            ! Free-slip
            u_n = VM%u(me)*n_x + VM%v(me)*n_y
            SP%u(you) = VM%u(me) - 2.0d0 * u_n * n_x
            SP%v(you) = VM%v(me) - 2.0d0 * u_n * n_y

#elif (U_BOUNDARY_BOTTOM == 2)
            ! No-slip
            SP%u(you) = - VM%u(me)
            SP%v(you) = - VM%v(me)

#endif

! Pressure boundary condition
#if (TARGET_PROBLEM == 4) && (TEM_BOUNDARY_BOTTOM == 1)
            SP%pre(you) = VM%pre(me) &
                        + param%rho_ref * param%alpha_ref * &
                         (param%tem_bottom - param%tem_ave) * param%gravity * &
                         (SP%y(you) - VM%y(me))
#else
            SP%pre(you) = VM%pre(me)

#endif

! Temperature boundary condition
#if (TARGET_PROBLEM == 4)
#if (TEM_BOUNDARY_BOTTOM == 1)
            ! Isothermal
            SP%tem(you) = 2.0d0 * param%tem_bottom - VM%tem(me)

#elif (TEM_BOUNDARY_BOTTOM == 2)
            ! Adiabatic
            SP%tem(you) = VM%tem(me)

#endif
#endif

        ! ==================================================================== !
        !   2. Top
        ! ==================================================================== !
        elseif (VM%ptype(me) == 2) then

! Velocity boundary condition
#if   (U_BOUNDARY_TOP == 1)
            ! Free-slip
            u_n = VM%u(me)*n_x + VM%v(me)*n_y
            SP%u(you) = VM%u(me) - 2.0d0 * u_n * n_x
            SP%v(you) = VM%v(me) - 2.0d0 * u_n * n_y

#elif (U_BOUNDARY_TOP == 2)
            ! No-slip
            SP%u(you) = - VM%u(me)
            SP%v(you) = - VM%v(me)

#elif (U_BOUNDARY_TOP == 3)
            ! Moving wall
            SP%u(you) = 2.0d0 * param%u_top - VM%u(me)
            SP%v(you) = - VM%v(me)

#endif

! Pressure boundary condition
#if (TARGET_PROBLEM == 4) && (TEM_BOUNDARY_TOP == 1)
            SP%pre(you) = VM%pre(me) &
                        + param%rho_ref * param%alpha_ref * &
                         (param%tem_top - param%tem_ave) * param%gravity * &
                         (SP%y(you) - VM%y(me))
#else
            SP%pre(you) = VM%pre(me)
#endif

! Temperature boundary condition
#if (TARGET_PROBLEM == 4)
#if (TEM_BOUNDARY_TOP == 1)
            ! Isothermal
            SP%tem(you) = 2.0d0 * param%tem_top - VM%tem(me)

#elif (TEM_BOUNDARY_TOP == 2)
            ! Adiabatic
            SP%tem(you) = VM%tem(me)

#endif
#endif


        ! ==================================================================== !
        !   3. Left
        ! ==================================================================== !
        elseif (VM%ptype(me) == 3) then

! Velocity boundary condition
#if   (U_BOUNDARY_LEFT == 1)
            ! Free-slip
            u_n = VM%u(me)*n_x + VM%v(me)*n_y
            SP%u(you) = VM%u(me) - 2.0d0 * u_n * n_x
            SP%v(you) = VM%v(me) - 2.0d0 * u_n * n_y

#elif (U_BOUNDARY_LEFT == 2)
            ! No-slip
            SP%u(you) = - VM%u(me)
            SP%v(you) = - VM%v(me)

#endif

! Pressure boundary condition
            SP%pre(you) = VM%pre(me)

! Temperature boundary condition
#if (TARGET_PROBLEM == 4)
#if (TEM_BOUNDARY_LEFT == 1)
            ! Isothermal
            SP%tem(you) = 2.0d0 * param%tem_left - VM%tem(me)

#elif (TEM_BOUNDARY_LEFT == 2)
            ! Adiabatic
            SP%tem(you) = VM%tem(me)

#endif
#endif

        ! ==================================================================== !
        !   4. Right
        ! ==================================================================== !
        elseif (VM%ptype(me) == 4) then

! Velocity boundary condition
#if   (U_BOUNDARY_RIGHT == 1)
            ! Free-slip
            u_n = VM%u(me)*n_x + VM%v(me)*n_y
            SP%u(you) = VM%u(me) - 2.0d0 * u_n * n_x
            SP%v(you) = VM%v(me) - 2.0d0 * u_n * n_y

#elif (U_BOUNDARY_RIGHT == 2)
            ! No-slip
            SP%u(you) = - VM%u(me)
            SP%v(you) = - VM%v(me)

#endif

! Pressure boundary condition
            SP%pre(you) = VM%pre(me)

! Temperature boundary condition
#if (TARGET_PROBLEM == 4)
#if (TEM_BOUNDARY_RIGHT == 1)
            ! Isothermal
            SP%tem(you) = 2.0d0 * param%tem_right - VM%tem(me)

#elif (TEM_BOUNDARY_RIGHT == 2)
            ! Adiabatic
            SP%tem(you) = VM%tem(me)

#endif
#endif


        ! ==================================================================== !
        !   5. Left & Right Bottom
        ! ==================================================================== !
        elseif (VM%ptype(me) == 5 .or. VM%ptype(me) == 6) then

! Velocity boundary condition
            SP%u(you) = - VM%u(me)
            SP%v(you) = - VM%v(me)

! Pressure boundary condition
#if (TARGET_PROBLEM == 4) && (TEM_BOUNDARY_BOTTOM == 1)
            SP%pre(you) = VM%pre(me) &
                        + param%rho_ref * param%alpha_ref * &
                         (param%tem_bottom - param%tem_ave) * param%gravity * &
                         (SP%y(you) - VM%y(me))
#else
            SP%pre(you) = VM%pre(me)

#endif

! Temperature boundary condition
#if (TARGET_PROBLEM == 4)
#if (TEM_BOUNDARY_BOTTOM == 1)
            ! Isothermal
            SP%tem(you) = 2.0d0 * param%tem_bottom - VM%tem(me)

#elif (TEM_BOUNDARY_BOTTOM == 2)
            ! Adiabatic
            SP%tem(you) = VM%tem(me)

#endif
#endif

        ! ==================================================================== !
        !   6. Left & Right Top
        ! ==================================================================== !
        elseif (VM%ptype(me) == 7 .or. VM%ptype(me) == 8) then

! Velocity boundary condition
#if (U_BOUNDARY_TOP == 3)
            ! Moving wall
            SP%u(you) = 2.0d0 * param%u_top - VM%u(me)
            SP%v(you) = - VM%v(me)

#else
            SP%u(you) = - VM%u(me)
            SP%v(you) = - VM%v(me)

#endif

! Pressure boundary condition
#if (TARGET_PROBLEM == 4) && (TEM_BOUNDARY_TOP == 1)
            SP%pre(you) = VM%pre(me) &
                        + param%rho_ref * param%alpha_ref * &
                         (param%tem_top - param%tem_ave) * param%gravity * &
                         (SP%y(you) - VM%y(me))
#else
            SP%pre(you) = VM%pre(me)

#endif

! Temperature boundary condition
#if (TARGET_PROBLEM == 4)
#if (TEM_BOUNDARY_TOP == 1)
            ! Isothermal
            SP%tem(you) = 2.0d0 * param%tem_top - VM%tem(me)

#elif (TEM_BOUNDARY_TOP == 2)
            ! Adiabatic
            SP%tem(you) = VM%tem(me)

#endif
#endif

        endif

    end subroutine extrapolate_VM_to_WL

end module extrapolate_VM_to_WL_mod