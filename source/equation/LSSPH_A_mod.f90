! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!    This file calculates the Right-Hand Sides (RHS) of governing equations    !
!                            using the LS-SPH model.                           !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module LSSPH_A_mod
    use global_types        , only: Param_type, SP_type, Cell_type
    use kernel_functions_mod, only: cal_W

    implicit none

    double precision, parameter, private :: pi = acos(-1.0d0)

contains

    subroutine LSSPH_A(me, param, SP, cell)
        integer         , intent(in)    :: me
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(Cell_type) , intent(in)    :: cell

        integer          :: you, my_cell, your_cell
        integer          :: neighbor, neighbor_cell, num_neighbors
        double precision :: h, h_eff_sq, SP_mass
        double precision :: my_x, my_y, my_u, my_v, my_rho, my_pre, my_tem
        double precision :: x_ji, y_ji, r_ij_sq, r_ij, W_ij, V_j, VW, delta
        double precision :: du(5), dv(5), drho(5), dpre(5), dtem(5)

        integer          :: i, INFO
        double precision :: VW_a

        ! k: Maximum order of the Taylor expansion
        !    - 1st derivatives: kth-order accuracy
        !    - 2nd derivatives: (k-1)-th-order accuracy
        ! q: Total number of basis functions (terms) in the Taylor expansion
#if   (SPH_MODEL == 3)
        integer, parameter :: k = 2,  q = 5   ! 2nd-order (1st derivatives) / 1st-order (Laplacian)
#elif (SPH_MODEL == 4)
        integer, parameter :: k = 3,  q = 9   ! 3rd-order (1st derivatives) / 2nd-order (Laplacian)
#elif (SPH_MODEL == 5)
        integer, parameter :: k = 4,  q = 14  ! 4th-order (1st derivatives) / 3rd-order (Laplacian)
#elif (SPH_MODEL == 6)
        integer, parameter :: k = 5,  q = 20  ! 5th-order (1st derivatives) / 4th-order (Laplacian)
#else
        integer, parameter :: k = 2,  q = 5   ! Dummy value for compilation
#endif

#if   (TARGET_PROBLEM == 4)
        integer, parameter :: num_b_vec = 5  ! u, v, rho, pre, tem
#else
        integer, parameter :: num_b_vec = 4  ! u, v, rho, pre
#endif

        integer          :: IPIV(q)
        double precision :: inv_h(k), a_vec(q), M_mat(q,q), b_vec(q, num_b_vec)

        ! ==================================================================== !
        !   1. Initialization 
        ! ==================================================================== !
        num_neighbors = 0

        a_vec = 0.0d0
        M_mat = 0.0d0
        b_vec = 0.0d0
        
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

        inv_h(1) = 1.0d0 / h  ! Used for normalization
        do i = 2, k
            inv_h(i) = inv_h(i-1) / h
        enddo

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
                x_ji    = SP%x(you) - my_x
                y_ji    = SP%y(you) - my_y
                r_ij_sq = x_ji**2 + y_ji**2
                if (r_ij_sq > h_eff_sq) cycle
                r_ij = sqrt(r_ij_sq)
                
                ! Calculate the value of the kernel function W_ij
                call cal_W(r_ij, h, W_ij)

                ! Count the number of neighbors
                num_neighbors = num_neighbors + 1

                ! ============================================================ !
                !   [Start] Calculate the particle interactions
                ! ============================================================ !
                V_j = SP_mass / SP%rho(you)  ! Particle volume
                VW  = V_j * W_ij

                ! Taylor expansion up to 2nd-order terms
                a_vec(1) = x_ji * inv_h(1)
                a_vec(2) = y_ji * inv_h(1)

                a_vec(3) = 0.5d0 * x_ji**2 * inv_h(2)
                a_vec(4) = 0.5d0 * y_ji**2 * inv_h(2)
                a_vec(5) = x_ji  * y_ji    * inv_h(2)

                ! Taylor expansion up to 3rd-order terms
#if (SPH_MODEL >= 4)
                a_vec(6) = 1.0d0/6.0d0 * x_ji**3  * inv_h(3)
                a_vec(7) = 1.0d0/6.0d0 * y_ji**3  * inv_h(3)
                a_vec(8) = 0.5d0 * x_ji**2 * y_ji * inv_h(3)
                a_vec(9) = 0.5d0 * y_ji**2 * x_ji * inv_h(3)

                ! Taylor expansion up to 4th-order terms
#if (SPH_MODEL >= 5)
                a_vec(10) = 1.0d0/24.0d0 * x_ji**4           * inv_h(4)
                a_vec(11) = 1.0d0/24.0d0 * y_ji**4           * inv_h(4)
                a_vec(12) = 1.0d0/6.0d0  * x_ji**3 * y_ji    * inv_h(4)
                a_vec(13) = 1.0d0/6.0d0  * y_ji**3 * x_ji    * inv_h(4)
                a_vec(14) = 1.0d0/4.0d0  * x_ji**2 * y_ji**2 * inv_h(4)

                ! Taylor expansion up to 5th-order terms
#if (SPH_MODEL >= 6)
                a_vec(15) = 1.0d0/120.0d0 * x_ji**5           * inv_h(5)
                a_vec(16) = 1.0d0/120.0d0 * y_ji**5           * inv_h(5)
                a_vec(17) = 1.0d0/24.0d0  * x_ji**4 * y_ji    * inv_h(5)
                a_vec(18) = 1.0d0/24.0d0  * y_ji**4 * x_ji    * inv_h(5)
                a_vec(19) = 1.0d0/12.0d0  * x_ji**3 * y_ji**2 * inv_h(5)
                a_vec(20) = 1.0d0/12.0d0  * y_ji**3 * x_ji**2 * inv_h(5)
#endif
#endif
#endif
                
                do i = 1, q
                    VW_a = VW * a_vec(i)

                    ! Calculate the vector b
                    b_vec(i,1) = b_vec(i,1) + VW_a * (SP%u  (you) - my_u)
                    b_vec(i,2) = b_vec(i,2) + VW_a * (SP%v  (you) - my_v)
                    b_vec(i,3) = b_vec(i,3) + VW_a * (SP%rho(you) - my_rho)
                    b_vec(i,4) = b_vec(i,4) + VW_a * (SP%pre(you) - my_pre)
#if (TARGET_PROBLEM == 4)
                    b_vec(i,5) = b_vec(i,5) + VW_a * (SP%tem(you) - my_tem)
#endif

                    ! Calculate the moment matrix M
                    ! Note: Calculate only the upper triangle of the symmetric matrix M
                    M_mat(1:i, i) = M_mat(1:i, i) + VW_a * a_vec(1:i)

                enddo
                
                ! ============================================================ !
                !   [End] Calculate the particle interactions
                ! ============================================================ !
            enddo

        enddo

        ! ==================================================================== !
        !   3. Calculate the inverse of matrix M
        ! ==================================================================== !
        ! Copy the upper triangle to the lower triangle
        do i = 1, q-1
            M_mat(i+1:q, i) = M_mat(i, i+1:q)
        enddo

        ! Fail-safe
        if (num_neighbors >= q) then

            ! Solve Md=b
            call DGESV(q, num_b_vec, M_mat, q, IPIV, b_vec, q, INFO)

            du(1:2)   = b_vec(1:2,1) * inv_h(1)  ! d_x, d_y
            du(3:5)   = b_vec(3:5,1) * inv_h(2)  ! d_xx, d_yy, d_xy

            dv(1:2)   = b_vec(1:2,2) * inv_h(1)  ! d_x, d_y
            dv(3:5)   = b_vec(3:5,2) * inv_h(2)  ! d_xx, d_yy, d_xy

            drho(1:2) = b_vec(1:2,3) * inv_h(1)  ! d_x, d_y
            drho(3:5) = b_vec(3:5,3) * inv_h(2)  ! d_xx, d_yy, d_xy

            dpre(1:2) = b_vec(1:2,4) * inv_h(1)  ! d_x, d_y
            dpre(3:5) = b_vec(3:5,4) * inv_h(2)  ! d_xx, d_yy, d_xy

#if (TARGET_PROBLEM == 4)
            dtem(1:2) = b_vec(1:2,5) * inv_h(1)  ! d_x, d_y
            dtem(3:5) = b_vec(3:5,5) * inv_h(2)  ! d_xx, d_yy, d_xy

#endif

        ! Set to zero if the number of neighboring particles is insufficient
        else
            du   = 0.0d0
            dv   = 0.0d0
            drho = 0.0d0
            dpre = 0.0d0
#if (TARGET_PROBLEM == 4)
            dtem = 0.0d0
#endif

        endif

        ! ==================================================================== !
        !   4. Calculate RHS of governing equations
        ! ==================================================================== !
#if   (TARGET_PROBLEM == 1)
        SP%RHS_u(me) = (du(3) + du(4)) + 2.0d0 * pi**2 * sin(pi*(my_x - param%WL_thick)) &
                                                       * cos(pi*(my_y - param%WL_thick))

#elif (TARGET_PROBLEM >= 2)
        delta = param%coe_delta_sph * param%sound_speed * h* param%zeta_RSST

        SP%RHS_rho(me) = - my_rho * (du(1) + dv(2)) + delta * (drho(3) + drho(4))
        SP%RHS_u  (me) = - dpre(1) / my_rho + (param%vis_ref / my_rho) * (du(3) + du(4))
        SP%RHS_v  (me) = - dpre(2) / my_rho + (param%vis_ref / my_rho) * (dv(3) + dv(4))

        ! Reduced Speed of Sound Technique (RSST)
        SP%RHS_rho(me) = SP%RHS_rho(me) / param%zeta_RSST**2

#if (TARGET_PROBLEM == 4)
        SP%RHS_v(me) = SP%RHS_v(me) + param%alpha_ref * (my_tem - param%tem_ave) * param%gravity
        
        ! Variable Inertia Method (VIM)
        SP%RHS_u(me) = SP%RHS_u(me) / param%xi_VIM**2
        SP%RHS_v(me) = SP%RHS_v(me) / param%xi_VIM**2

        SP%RHS_tem(me) = param%thermal_dif * (dtem(3) + dtem(4))
#endif
#endif

    end subroutine LSSPH_A

end module LSSPH_A_mod