! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!    This file calculates the Right-Hand Sides (RHS) of governing equations    !
!                       using the classical SPH model.                         !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module classical_SPH_mod
    use global_types        , only: Param_type, SP_type, Cell_type
    use kernel_functions_mod, only: cal_dW

    implicit none

    double precision, parameter, private :: pi = acos(-1.0d0)

contains

    pure subroutine classical_SPH(me, param, SP, cell)
        integer         , intent(in)    :: me
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(Cell_type) , intent(in)    :: cell

        integer          :: you, my_cell, your_cell
        integer          :: neighbor, neighbor_cell
        double precision :: h, h_eff_sq, SP_mass
        double precision :: my_x, my_y, my_u, my_v, my_rho, my_pre, my_tem
        double precision :: x_ij, y_ij, r_ij_sq, r_ij, dW_dr, V_j
        double precision :: dW_dx_V, dW_dy_V, du_dx, dv_dy, dp_dx, dp_dy
        double precision :: Lap_u, Lap_v, Lap_tem, Lap_rho, delta

        ! ==================================================================== !
        !   1. Initialization 
        ! ==================================================================== !
        du_dx   = 0.0d0
        dv_dy   = 0.0d0
        dp_dx   = 0.0d0
        dp_dy   = 0.0d0
        Lap_u   = 0.0d0
        Lap_v   = 0.0d0
        Lap_tem = 0.0d0
        Lap_rho = 0.0d0

        SP_mass  = param%SP_mass
        h        = param%h
        h_eff_sq = param%h_eff**2

        my_x   = SP%x(me)
        my_y   = SP%y(me)
        my_u   = SP%u(me)
        my_v   = SP%v(me)
        my_rho = SP%rho(me)
        my_pre = SP%pre(me)
#if (TARGET_PROBLEM == 4)
        my_tem = SP%tem(me)
#endif

        ! ==================================================================== !
        !   2. Calculate the particle interactions 
        ! ==================================================================== !
        ! My cell index
        my_cell = cell%idx_SP(me)

        ! Loop over neighboring cells
        do neighbor_cell = 1, 9
            
            ! Get the neighboring cell index
            your_cell = cell%neighbors(neighbor_cell, my_cell)
            
            ! Skip if `your cell` is out of bounds or empty
            if (your_cell == 0) cycle
            if (cell%num_SP(your_cell) == 0) cycle

            ! Loop over the neighbors
            do neighbor = 1, cell%num_SP(your_cell)

                ! Get the index of the neighboring particle ('you')
                you = cell%list(neighbor, your_cell)

                ! Skip if `me` = `you`
                if (me == you) cycle 

                ! Calculate the particle distance r_ij
                x_ij    = my_x - SP%x(you)
                y_ij    = my_y - SP%y(you)
                r_ij_sq = x_ij**2 + y_ij**2
                if (r_ij_sq > h_eff_sq) cycle
                r_ij = sqrt(r_ij_sq)
                
                ! Calculate the value of the kernel function W_ij
                call cal_dW(r_ij, h, dW_dr)

                ! ============================================================ !
                !   [Start] Calculate the particle interactions
                ! ============================================================ !
                V_j = SP_mass / SP%rho(you)  ! Particle volume

                ! Gradient of kernel function
                dW_dx_V = dW_dr * x_ij / r_ij * V_j  ! dW/dx * V_j
                dW_dy_V = dW_dr * y_ij / r_ij * V_j  ! dW/dy * V_j

                ! du_dx & dv_dy for div u_vec
                du_dx = du_dx + dW_dx_V * (SP%u(you) - my_u)  ! difference model
                dv_dy = dv_dy + dW_dy_V * (SP%v(you) - my_v)

                ! Pressure gradient
#if   (SPH_MODEL == 1)
                dp_dx = dp_dx + dW_dx_V * (SP%pre(you) + my_pre)  ! sum model
                dp_dy = dp_dy + dW_dy_V * (SP%pre(you) + my_pre)
#elif (SPH_MODEL == 2)
                dp_dx = dp_dx + dW_dx_V * (SP%pre(you) - my_pre)  ! difference model
                dp_dy = dp_dy + dW_dy_V * (SP%pre(you) - my_pre)
#endif

                ! Laplacian of u & v
                Lap_u = Lap_u + 2.0d0 * V_j * dW_dr / r_ij * (my_u - SP%u(you))
                Lap_v = Lap_v + 2.0d0 * V_j * dW_dr / r_ij * (my_v - SP%v(you))

                ! Laplacian of temperature
#if (TARGET_PROBLEM == 4)
                Lap_tem = Lap_tem + 2.0d0 * V_j * dW_dr / r_ij * (my_tem - SP%tem(you))
#endif

                ! Laplacian of density for delta-SPH method
                Lap_rho = Lap_rho + 2.0d0 * V_j * dW_dr / r_ij * (my_rho - SP%rho(you))
                ! ============================================================ !
                !   [End] Calculate the particle interactions
                ! ============================================================ !
            enddo

        enddo

        ! ==================================================================== !
        !   3. Calculate RHS of governing equations
        ! ==================================================================== !
#if   (TARGET_PROBLEM == 1)
        SP%RHS_u(me) = Lap_u + 2.0d0 * pi**2 * sin(pi*(my_x - param%WL_thick)) &
                                             * cos(pi*(my_y - param%WL_thick))

#elif (TARGET_PROBLEM >= 2)
        delta = param%coe_delta_sph * param%sound_speed * h* param%zeta_RSST

        SP%RHS_rho(me) = - my_rho * (du_dx + dv_dy) + delta * Lap_rho
        SP%RHS_u  (me) = - dp_dx / my_rho + (param%vis_ref / my_rho) * Lap_u
        SP%RHS_v  (me) = - dp_dy / my_rho + (param%vis_ref / my_rho) * Lap_v

        ! Reduced Speed of Sound Technique (RSST)
        SP%RHS_rho(me) = SP%RHS_rho(me) / param%zeta_RSST**2

#if (TARGET_PROBLEM == 4)
        SP%RHS_v(me) = SP%RHS_v(me) + param%alpha_ref * (my_tem - param%tem_ave) * param%gravity
        
        ! Variable Inertia Method (VIM)
        SP%RHS_u(me) = SP%RHS_u(me) / param%xi_VIM**2
        SP%RHS_v(me) = SP%RHS_v(me) / param%xi_VIM**2

        SP%RHS_tem(me) = param%thermal_dif * Lap_tem
#endif
#endif

    end subroutine classical_SPH

end module classical_SPH_mod