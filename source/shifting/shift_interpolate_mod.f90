! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!          This file shifts and interpolates the particles using PST.          !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module shift_interpolate_mod
    use global_types         , only: Param_type, SP_type, Cell_type
    use kernel_functions_mod , only: cal_W, cal_dW

    implicit none

contains

    subroutine shift_interpolate(me, coe_PST, max_shift, param, SP, cell)
        integer         , intent(in)    :: me
        double precision, intent(in)    :: coe_PST, max_shift
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(Cell_type) , intent(in)    :: cell

        integer          :: you, my_cell, your_cell
        integer          :: neighbor, neighbor_cell, num_neighbors
        double precision :: h, h_eff_sq, SP_mass
        double precision :: my_x, my_y, my_u, my_v, my_rho, my_tem
        double precision :: x_ji, y_ji, r_ij_sq, r_ij, W_ij, V_j, VW
        double precision :: dW_dr, dW_dx_V, dW_dy_V, dx, dy, W_ave

        integer          :: i, INFO
        double precision :: VW_a

        ! k: Maximum order of the Taylor expansion, which should be consistent 
        !    - This order should be consistent with `LSSPH_A_mod.f90`
        ! q: Total number of basis functions (terms) in the Taylor expansion
#if   (SPH_MODEL <= 2)
        integer, parameter :: k = 1,  q = 2   ! 1st-order Taylor expansion
#elif (SPH_MODEL == 3)
        integer, parameter :: k = 2,  q = 5   ! 2nd-order Taylor expansion
#elif (SPH_MODEL == 4)
        integer, parameter :: k = 3,  q = 9   ! 3rd-order Taylor expansion
#elif (SPH_MODEL == 5)
        integer, parameter :: k = 4,  q = 14  ! 4th-order Taylor expansion
#elif (SPH_MODEL == 6)
        integer, parameter :: k = 5,  q = 20  ! 5th-order Taylor expansion
#else
        integer, parameter :: k = 2,  q = 5   ! Dummy value for compilation
#endif

#if   (TARGET_PROBLEM == 4)
        integer, parameter :: num_b_vec = 4  ! u, v, rho tem
#else
        integer, parameter :: num_b_vec = 3  ! u, v, rho
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
        dx    = 0.0d0
        dy    = 0.0d0
        
        SP_mass  = param%SP_mass
        h        = param%h
        h_eff_sq = param%h_eff**2
        W_ave    = param%W_ave

        my_x   = SP%x(me)
        my_y   = SP%y(me)
        my_u   = SP%u(me)
        my_v   = SP%v(me)
        my_rho = SP%rho(me)
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
                
                ! Calculate the value of the kernel function W_ij and its derivative
                call cal_W (r_ij, h, W_ij)
                call cal_dW(r_ij, h, dW_dr)

                ! Count the number of neighbors
                num_neighbors = num_neighbors + 1

                ! ============================================================ !
                !   [Start] Calculate the particle interactions
                ! ============================================================ !
                V_j = SP_mass / SP%rho(you)  ! Particle volume
                VW  = V_j * W_ij

                ! Shift vector
                dW_dx_V = dW_dr * (-x_ji) / r_ij * V_j  ! dW/dx * V_j
                dW_dy_V = dW_dr * (-y_ji) / r_ij * V_j  ! dW/dy * V_j
                
                dx = dx + (1.0d0 + 0.2d0*(W_ij/W_ave)**4) * dW_dx_V
                dy = dy + (1.0d0 + 0.2d0*(W_ij/W_ave)**4) * dW_dy_V

                ! Taylor expansion up to 1st-order terms
                a_vec(1) = x_ji * inv_h(1)
                a_vec(2) = y_ji * inv_h(1)

                ! Taylor expansion up to 2nd-order terms
#if (SPH_MODEL >= 3)
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
#if (SPH_MODEL >= 5)
                a_vec(15) = 1.0d0/120.0d0 * x_ji**5           * inv_h(5)
                a_vec(16) = 1.0d0/120.0d0 * y_ji**5           * inv_h(5)
                a_vec(17) = 1.0d0/24.0d0  * x_ji**4 * y_ji    * inv_h(5)
                a_vec(18) = 1.0d0/24.0d0  * y_ji**4 * x_ji    * inv_h(5)
                a_vec(19) = 1.0d0/12.0d0  * x_ji**3 * y_ji**2 * inv_h(5)
                a_vec(20) = 1.0d0/12.0d0  * y_ji**3 * x_ji**2 * inv_h(5)
#endif
#endif
#endif
#endif
                
                do i = 1, q
                    VW_a = VW * a_vec(i)

                    ! Calculate the vector b
                    b_vec(i,1) = b_vec(i,1) + VW_a * (SP%u  (you) - my_u)
                    b_vec(i,2) = b_vec(i,2) + VW_a * (SP%v  (you) - my_v)
                    b_vec(i,3) = b_vec(i,3) + VW_a * (SP%rho(you) - my_rho)
#if (TARGET_PROBLEM == 4)
                    b_vec(i,4) = b_vec(i,4) + VW_a * (SP%tem(you) - my_tem)
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
        !   3. Calculate the new position
        !      - Note: New position is stored into `x_old` and 'y_old'
        !      - Note: `_old` was used for the Runge-Kutta method
        ! ==================================================================== !
        ! Shift vector
        dx = - coe_PST * dx
        dy = - coe_PST * dy

        ! Safety guard for maximum shift distance
        r_ij = sqrt(dx**2 + dy**2)

        if (r_ij > max_shift) then
            dx = max_shift * dx / r_ij
            dy = max_shift * dy / r_ij
        endif

        ! Store the new position into `_old`
        SP%x_old(me) = SP%x(me) + dx
        SP%y_old(me) = SP%y(me) + dy

        ! ==================================================================== !
        !   4. Calculate the inverse of matrix to determine the derivatives
        ! ==================================================================== !
        ! Copy the upper triangle to the lower triangle
        do i = 1, q-1
            M_mat(i+1:q, i) = M_mat(i, i+1:q)
        enddo

        ! Solve Md=b
        if (num_neighbors >= q) then
            call DGESV(q, num_b_vec, M_mat, q, IPIV, b_vec, q, INFO)
        
        ! Set to zero if the number of neighboring particles is insufficient
        else
            b_vec = 0.0d0

        endif

        ! ==================================================================== !
        !   5. Interpolate the properties using LS-SPH type A
        !      - Note: New properties are stored into `_old`
        !      - Note: `_old` was used for the Runge-Kutta method
        ! ==================================================================== !
        ! Taylor expansion up to 1st-order terms
        a_vec(1) = dx * inv_h(1)
        a_vec(2) = dy * inv_h(1)

        ! Taylor expansion up to 2nd-order terms
#if (SPH_MODEL >= 3)
        a_vec(3) = 0.5d0 * dx**2 * inv_h(2)
        a_vec(4) = 0.5d0 * dy**2 * inv_h(2)
        a_vec(5) = dx * dy       * inv_h(2)

        ! Taylor expansion up to 3rd-order terms
#if (SPH_MODEL >= 4)
        a_vec(6) = 1.0d0/6.0d0 * dx**3 * inv_h(3)
        a_vec(7) = 1.0d0/6.0d0 * dy**3 * inv_h(3)
        a_vec(8) = 0.5d0 * dx**2 * dy  * inv_h(3)
        a_vec(9) = 0.5d0 * dy**2 * dx  * inv_h(3)

        ! Taylor expansion up to 4th-order terms
#if (SPH_MODEL >= 5)
        a_vec(10) = 1.0d0/24.0d0 * dx**4         * inv_h(4)
        a_vec(11) = 1.0d0/24.0d0 * dy**4         * inv_h(4)
        a_vec(12) = 1.0d0/6.0d0  * dx**3 * dy    * inv_h(4)
        a_vec(13) = 1.0d0/6.0d0  * dy**3 * dx    * inv_h(4)
        a_vec(14) = 1.0d0/4.0d0  * dx**2 * dy**2 * inv_h(4)

        ! Taylor expansion up to 5th-order terms
#if (SPH_MODEL >= 6)
        a_vec(15) = 1.0d0/120.0d0 * dx**5           * inv_h(5)
        a_vec(16) = 1.0d0/120.0d0 * dy**5           * inv_h(5)
        a_vec(17) = 1.0d0/24.0d0  * dx**4 * dy      * inv_h(5)
        a_vec(18) = 1.0d0/24.0d0  * dy**4 * dx      * inv_h(5)
        a_vec(19) = 1.0d0/12.0d0  * dx**3 * dy**2   * inv_h(5)
        a_vec(20) = 1.0d0/12.0d0  * dy**3 * dx**2   * inv_h(5)
#endif
#endif
#endif
#endif

        ! Store the new properties into `old`
        SP%u_old  (me) = SP%u  (me) + dot_product(a_vec, b_vec(:,1))
        SP%v_old  (me) = SP%v  (me) + dot_product(a_vec, b_vec(:,2))
        SP%rho_old(me) = SP%rho(me) + dot_product(a_vec, b_vec(:,3))
#if (TARGET_PROBLEM == 4)
        SP%tem_old(me) = SP%tem(me) + dot_product(a_vec, b_vec(:,4))
#endif

    end subroutine shift_interpolate

end module shift_interpolate_mod