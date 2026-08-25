! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!       This file interpolates fluid properties onto the virtual markers       !
!      using the CSPH kernel correction method (with 1st-order accuracy).      !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module interpolate_CSPH_mod
    use global_types        , only: Param_type, SP_type, VM_type, Cell_type
    use kernel_functions_mod, only: cal_W

    implicit none

contains

    pure subroutine interpolate_CSPH(me, param, SP, VM, cell)
        integer         , intent(in)    :: me
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(in)    :: SP
        type(VM_type)   , intent(inout) :: VM
        type(Cell_type) , intent(in)    :: cell

        integer          :: you, my_cell, your_cell
        integer          :: neighbor, neighbor_cell, num_neighbors
        double precision :: h, h_eff_sq, SP_mass
        double precision :: my_x, my_y, x_ij, y_ij, r_ij_sq, r_ij, W_ij, V_j, VW
        double precision :: u, v, pre, tem, sum_W

        ! Initialization
        num_neighbors = 0

        u     = 0.0d0
        v     = 0.0d0
        pre   = 0.0d0
        tem   = 0.0d0
        sum_W = 0.0d0

        SP_mass  = param%SP_mass
        h        = param%h
        h_eff_sq = param%h_eff**2
        
        my_x = VM%x(me)
        my_y = VM%y(me)

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
                x_ij    = my_x - SP%x(you)
                y_ij    = my_y - SP%y(you)
                r_ij_sq = x_ij**2 + y_ij**2
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

                sum_W = sum_W + VW
                u     = u     + VW * SP%u  (you)
                v     = v     + VW * SP%v  (you)
                pre   = pre   + VW * SP%pre(you)
#if (TARGET_PROBLEM == 4)
                tem   = tem   + VW * SP%tem(you)
#endif
                ! ============================================================ !
                !   [End] Calculate the particle interactions
                ! ============================================================ !
            enddo

        enddo

        ! Fail-safe against division by nearly zero
        if (num_neighbors > 0 .and. sum_W > 1.0d-12) then

            ! Normalize by the sum of weights and assign to `VM`
            VM%u  (me) = u   / sum_W
            VM%v  (me) = v   / sum_W
            VM%pre(me) = pre / sum_W
#if (TARGET_PROBLEM == 4)
            VM%tem(me) = tem / sum_W
#endif

        else
            ! Set to zero if no internal fluid particles are nearby
            VM%u  (me) = 0.0d0
            VM%v  (me) = 0.0d0
            VM%pre(me) = 0.0d0
#if (TARGET_PROBLEM == 4)
            VM%tem(me) = 0.0d0
#endif

        endif

    end subroutine interpolate_CSPH

end module interpolate_CSPH_mod