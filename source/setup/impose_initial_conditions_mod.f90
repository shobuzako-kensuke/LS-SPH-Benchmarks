! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!   This file imposes the initial conditions of the specified target problem.  !
!                                                                              !
! ============================================================================ !

module impose_initial_conditions_mod
    use global_types, only: Param_type, SP_type

    implicit none
    
    double precision, parameter, private :: pi = acos(-1.0d0)

contains
    ! ======================================================================== !
    !   Diffusion Equation Test
    ! ======================================================================== !
    subroutine impose_diffusion_equation(param, SP)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP

        integer              :: i, seed_size, clock
        integer, allocatable :: seed(:)
        double precision     :: rnd

        ! Density is set to param%rho_ref
        SP%rho(:) = param%rho_ref

        ! SP%u corresponds to the function value f of the diffusion equation
        SP%u(:) = 0.0d0

        ! Initialize to zero for safety
        SP%pre(:) = 0.0d0
        SP%v  (:) = 0.0d0

        ! Initialize the random number generator
        call random_seed(size = seed_size)  ! Get the required size
        allocate(seed(seed_size))
        call system_clock(count = clock)    ! Set the seed using the system clock
        
        do i = 1, seed_size
            seed(i) = clock + 2026 * i
        enddo

        call random_seed(put = seed(:))

        ! Positions are perturbed ranging from (- pos_pert *dx) to (+ pos_pert * dx)
        do i = 1, SP%num_int
            call random_number(rnd)
            SP%x(i) = SP%x(i) + param%pos_pert * param%dx * (2.0d0*rnd - 1.0d0)

            call random_number(rnd)
            SP%y(i) = SP%y(i) + param%pos_pert * param%dx * (2.0d0*rnd - 1.0d0)
        enddo

    end subroutine impose_diffusion_equation


    ! ======================================================================== !
    !   Taylor-Green Vortex
    ! ======================================================================== !
    subroutine impose_TG_vortex(param, SP)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP

        integer          :: i
        double precision :: x, y, a, b, Lx, Ly, ratio

        a  = dble(param%tg_a)
        b  = dble(param%tg_b)
        Lx = param%len_x
        Ly = param%len_y
        ratio = (a * Ly) / (b * Lx)
        
        do i = 1, SP%num_int

            ! Note: The simulation domain is offset by WL_thick.
            x = SP%x(i) - param%WL_thick
            y = SP%y(i) - param%WL_thick

            SP%u(i) = + 1.0d0         * sin(a*pi*x / Lx) * cos(b*pi*y / Ly)
            SP%v(i) = - 1.0d0 * ratio * cos(a*pi*x / Lx) * sin(b*pi*y / Ly)

            SP%pre(i) = 0.25d0 * param%rho_ref * 1.0d0**2 * &
                        (cos(2.0d0*a*pi*x / Lx) + (ratio**2) * cos(2.0d0*b*pi*y / Ly))
            
            SP%rho(i) = param%rho_ref + SP%pre(i) / param%sound_speed**2
        enddo

    end subroutine impose_TG_vortex


    ! ======================================================================== !
    !   Lid-driven Cavity Flow
    ! ======================================================================== !
    subroutine impose_cavity(param, SP)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP

        SP%rho(:) = param%rho_ref
        SP%pre(:) = 0.0d0
        SP%u  (:) = 0.0d0
        SP%v  (:) = 0.0d0

    end subroutine impose_cavity


    ! ======================================================================== !
    !   Boussinesq Convection
    ! ======================================================================== !
    subroutine impose_boussinesq_convection(param, SP)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP

        integer          :: i
        double precision :: x, y

        SP%rho(:) = param%rho_ref
        SP%pre(:) = 0.0d0
        SP%u  (:) = 0.0d0
        SP%v  (:) = 0.0d0

        do i = 1, SP%num_int

            ! Note: The simulation domain is offset by WL_thick.
            x = SP%x(i) - param%WL_thick
            y = SP%y(i) - param%WL_thick

            ! Linear temperature profile
            SP%tem(i) = - (param%delta_tem / param%len_y) * y + param%tem_bottom

            ! Temperature perturbation
            if (y <= 0.1d0 * param%len_y) then
                SP%tem(i) = SP%tem(i) + 1.0d-2 * param%delta_tem * cos(pi*x / param%len_x)
            endif
            
        enddo

    end subroutine impose_boussinesq_convection

end module impose_initial_conditions_mod
