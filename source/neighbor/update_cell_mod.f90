! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!         This file updates Cell List for the internal fluid particles.        !
!                                                                              !
! ============================================================================ !

module update_cell_mod
    use omp_lib
    use global_types, only: Param_type, SP_type, Cell_type
    
    implicit none

contains

    subroutine update_cell(param, SP, cell)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(in)    :: SP
        type(Cell_type) , intent(inout) :: cell

        integer          :: me, my_cell, cell_x, cell_y
        integer          :: current_count, idx_start, idx_end
        double precision :: inv_h_eff

        inv_h_eff = 1.0d0 / param%h_eff

        !$omp parallel default(none) &
        !$omp shared(SP, cell, inv_h_eff) &
        !$omp private(me, my_cell, cell_x, cell_y) &
        !$omp private(current_count, idx_start, idx_end)

        ! ==================================================================== !
        !   1. Initialize to zero
        ! ==================================================================== !
        !$omp do
        do my_cell = 1, cell%idx_max
            cell%num_SP(my_cell) = 0
        enddo
        !$omp enddo

        ! ==================================================================== !
        !   2. Calculate cell index & register to Cell List
        ! ==================================================================== !
        !$omp do
        do me = 1, SP%num_int  ! Loop only for the internal fluid particles
            
            ! Calculate my cell index
            cell_x  = ceiling(SP%x(me) * inv_h_eff)
            cell_y  = ceiling(SP%y(me) * inv_h_eff)
            my_cell = cell_x + (cell_y - 1) * cell%idx_x_max

            ! Store my cell index
            cell%idx_SP(me) = my_cell

            ! Count particles and safely capture the current count
            !$omp atomic capture
            cell%num_SP(my_cell) = cell%num_SP(my_cell) + 1
            current_count = cell%num_SP(my_cell)
            !$omp end atomic

            ! Register the particle index to the cell linked list using the captured index
            cell%list(current_count, my_cell) = me

        enddo
        !$omp enddo

        ! ==================================================================== !
        !   3. Combine cell%list with cell%list_WL
        ! ==================================================================== !
        !$omp do
        do my_cell = 1, cell%idx_max

            ! If a ghost wall particle exists
            if (cell%num_WL(my_cell) > 0) then
                
                ! Calculate index bounds for the ghost wall particles in my cell
                idx_start = cell%num_SP(my_cell) + 1
                idx_end   = cell%num_SP(my_cell) + cell%num_WL(my_cell)

                ! Combine arrays
                  cell%list   (idx_start : idx_end     , my_cell) &
                = cell%list_WL(1 : cell%num_WL(my_cell), my_cell)

                ! Update the number of particles in my cell
                cell%num_SP(my_cell) = idx_end
            endif
        enddo
        !$omp enddo

        !$omp end parallel

    end subroutine update_cell

end module update_cell_mod