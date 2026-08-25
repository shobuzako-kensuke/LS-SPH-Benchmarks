! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!       This file interpolates fluid properties onto the virtual markers       !
!        using the LS-SPH Type B model (with 2nd or 3rd-order accuracy).       !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module interpolate_LSSPH_B_mod
    use global_types        , only: Param_type, SP_type, VM_type, Cell_type
    use kernel_functions_mod, only: cal_W

    implicit none

contains

    subroutine interpolate_LSSPH_B(me, param, SP, VM, cell)
        integer         , intent(in)    :: me
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(in)    :: SP
        type(VM_type)   , intent(inout) :: VM
        type(Cell_type) , intent(in)    :: cell

        integer          :: you, my_cell, your_cell
        integer          :: neighbor, neighbor_cell, num_neighbors
        double precision :: h, h_eff_sq, SP_mass
        double precision :: my_x, my_y, x_ji, y_ji, r_ij_sq, r_ij, W_ij, V_j, VW

        integer          :: i, INFO
        double precision :: inv_h, inv_h2, VW_a

#if   (WALL_MODEL == 2)
        integer, parameter :: q = 3  ! 2nd-order interpolation
#elif (WALL_MODEL == 3)
        integer, parameter :: q = 6  ! 3rd-order interpolation
#else
        integer, parameter :: q = 2  ! Dummy value for compilation
#endif

#if   (TARGET_PROBLEM == 4)
        integer, parameter :: num_b_vec = 4  ! u, v, pre, tem
#else
        integer, parameter :: num_b_vec = 3  ! u, v, pre
#endif

        integer          :: IPIV(q)
        double precision :: a_vec(q), M_mat(q,q), b_vec(q,num_b_vec)


        ! Initialization
        num_neighbors = 0

        a_vec(1)  = 1.0d0
        a_vec(2:) = 0.0d0
        M_mat     = 0.0d0
        b_vec     = 0.0d0

        SP_mass  = param%SP_mass
        h        = param%h
        h_eff_sq = param%h_eff**2

        my_x = VM%x(me)
        my_y = VM%y(me)

        inv_h  = 1.0d0 / h
        inv_h2 = inv_h * inv_h

        ! My cell index
        my_cell = cell%idx_VM(me)

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

                ! Skip if the particle is not an internal fluid particle
                if (SP%ptype(you) /= 0) cycle

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

                a_vec(2) = x_ji            * inv_h
                a_vec(3) = y_ji            * inv_h
#if (WALL_MODEL >= 3)
                a_vec(4) = x_ji*x_ji*0.5d0 * inv_h2
                a_vec(5) = x_ji*y_ji       * inv_h2
                a_vec(6) = y_ji*y_ji*0.5d0 * inv_h2
#endif

                do i = 1, q

                    VW_a = VW * a_vec(i)

                    ! Calculate the vector b (`b_vec`)
                    b_vec(i,1) = b_vec(i,1) + VW_a * SP%u  (you)
                    b_vec(i,2) = b_vec(i,2) + VW_a * SP%v  (you)
                    b_vec(i,3) = b_vec(i,3) + VW_a * SP%pre(you)
#if (TARGET_PROBLEM == 4)
                    b_vec(i,4) = b_vec(i,4) + VW_a * SP%tem(you)
#endif

                    ! Calculate the moment matrix M (`M_mat`)
                    ! Note: Calculate only the upper triangle of the symmetric `M_mat`
                    M_mat(1:i, i) = M_mat(1:i, i) + VW_a * a_vec(1:i)

                enddo
                ! ============================================================ !
                !   [End] Calculate the particle interactions
                ! ============================================================ !

            enddo

        enddo

        ! Copy the upper triangle to the lower triangle
        do i = 1, q-1
            M_mat(i+1:q, i) = M_mat(i, i+1:q)
        enddo

        ! Fail-safe
        if (num_neighbors >= q) then

            ! Solve Md=b
            call DGESV(q, num_b_vec, M_mat, q, IPIV, b_vec, q, INFO)

            VM%u  (me) = b_vec(1,1)
            VM%v  (me) = b_vec(1,2)
            VM%pre(me) = b_vec(1,3)
#if (TARGET_PROBLEM == 4)
            VM%tem(me) = b_vec(1,4)
#endif

        ! Set to zero if no internal fluid particles are nearby
        else
            VM%u  (me) = 0.0d0
            VM%v  (me) = 0.0d0
            VM%pre(me) = 0.0d0
#if (TARGET_PROBLEM == 4)
            VM%tem(me) = 0.0d0
#endif

        endif

    end subroutine interpolate_LSSPH_B

end module interpolate_LSSPH_B_mod