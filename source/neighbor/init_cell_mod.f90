! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!                      This file initializes Cell List.                        !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module init_cell_mod
    use omp_lib
    use global_types, only: Param_type, SP_type, VM_type, Cell_type

    implicit none

contains

    subroutine init_cell(param, SP, VM, cell)
        type(Param_type), intent(in)  :: param
        type(SP_type)   , intent(in)  :: SP
        type(VM_type)   , intent(in)  :: VM
        type(Cell_type) , intent(out) :: cell

        integer          :: me, my_cell, cell_x, cell_y
        integer          :: neighbor_cell, your_cell_x, your_cell_y, dx, dy
        double precision :: x_max, y_max

        ! ==================================================================== !
        !   1. Calculate and store the number of cells
        ! ==================================================================== !
        x_max = param%len_x + 2.0d0 * param%WL_thick
        y_max = param%len_y + 2.0d0 * param%WL_thick

        cell%idx_x_max = ceiling(x_max / param%h_eff)     ! X-direction
        cell%idx_y_max = ceiling(y_max / param%h_eff)     ! Y-direction
        cell%idx_max   = cell%idx_x_max * cell%idx_y_max  ! Total

        ! ==================================================================== !
        !   2. Allocate and initialize arrays in `Cell_type`
        ! ==================================================================== !
        allocate(cell%idx_SP(SP%num_total))  ! Cell index of each particle
        allocate(cell%num_SP(cell%idx_max))  ! Number of particles in a cell
        allocate(cell%num_WL(cell%idx_max))  ! Number of ghost wall particles in a cell
        cell%idx_SP = 0
        cell%num_SP = 0
        cell%num_WL = 0

        ! Valid only for the multi-layer fixed ghost particle scheme
#if (WALL_MODEL <= 3)
        allocate(cell%idx_VM(SP%num_ext))  ! Cell index of each virtual marker
        cell%idx_VM = 0
#endif

        allocate(cell%neighbors(9, cell%idx_max))  ! Indices of 9 neighboring cells
        cell%neighbors = 0

        ! -------------------------------------------------------------------- !

        !$omp parallel default(none) &
        !$omp shared(param, SP, VM, cell) &
        !$omp private(me, my_cell, cell_x, cell_y) &
        !$omp private(neighbor_cell, your_cell_x, your_cell_y, dx, dy)

        ! ==================================================================== !
        !   3. Count the number of particles in a cell
        ! ==================================================================== !
        !$omp do
        do me = 1, SP%num_total

            ! Calculate my cell index
            cell_x  = ceiling(SP%x(me) / param%h_eff)
            cell_y  = ceiling(SP%y(me) / param%h_eff)
            my_cell = cell_x + (cell_y - 1) * cell%idx_x_max

            ! Store my cell index
            cell%idx_SP(me) = my_cell

            ! Count the number of particles in my cell
            !$omp atomic
            cell%num_SP(my_cell) = cell%num_SP(my_cell) + 1

        enddo
        !$omp enddo

        ! ==================================================================== !
        !   4. Initialize Cell List
        ! ==================================================================== !
        !$omp single

        ! Maximum number of particles in a cell (cell capacity)
        cell%capacity = maxval(cell%num_SP(:))

        ! Allocate arrays for Cell List (with a safety margin of 2x)
        allocate(cell%list   (2*cell%capacity, cell%idx_max))  ! (particle indices, cell indices)
        allocate(cell%list_WL(2*cell%capacity, cell%idx_max))
        cell%list    = 0
        cell%list_WL = 0

        ! Generate Cell List for the ghost wall particles
        do me = SP%num_int + 1, SP%num_total
            my_cell = cell%idx_SP(me)
            cell%num_WL(my_cell) = cell%num_WL(my_cell) + 1   ! Count the number of ghost wall particles in the cell
            cell%list_WL(cell%num_WL(my_cell), my_cell) = me  ! Store the index of the ghost wall particle
        enddo

        !$omp end single

        ! ==================================================================== !
        !   5. Determine 9 neighboring cells
        ! ==================================================================== !
        !   [ Neighbor Cell Indexing Order ]
        !
        !         -------------------------
        !   y + 1 |   7   |   8   |   9   |
        !         -------------------------
        !     y   |   4   | 5(my) |   6   |
        !         -------------------------
        !   y - 1 |   1   |   2   |   3   |
        !         -------------------------
        !           x - 1     x     x + 1
        ! ==================================================================== !
        !$omp do
        do my_cell = 1, cell%idx_max

            cell_x = mod((my_cell - 1) , cell%idx_x_max) + 1  ! X-component of my cell index
            cell_y =     (my_cell - 1) / cell%idx_x_max  + 1  ! Y-component of my cell index

            neighbor_cell = 0
            do dy = -1, 1
                do dx = -1, 1

                    ! Neighbor cell index
                    neighbor_cell = neighbor_cell + 1

                    ! X- and Y-components of your cell index
                    your_cell_x = cell_x + dx
                    your_cell_y = cell_y + dy

                    ! Boundary check for neighboring cells
                    ! If out of bounds, set to 0
                    if (your_cell_x < 1 .or. your_cell_x > cell%idx_x_max .or. &
                        your_cell_y < 1 .or. your_cell_y > cell%idx_y_max) then

                        cell%neighbors(neighbor_cell, my_cell) = 0
                    
                    ! If valid, set to your cell index
                    else
                        cell%neighbors(neighbor_cell, my_cell) &
                        = your_cell_x + (your_cell_y - 1) * cell%idx_x_max
                        
                    endif

                enddo
            enddo
        enddo
        !$omp enddo

        ! ==================================================================== !
        !   6. Initialize Cell List of virtual markers
        ! ==================================================================== !
#if (WALL_MODEL <= 3)
        !$omp do
        do me = 1, SP%num_ext

            ! Calculate the cell index of a virtual marker
            cell_x  = ceiling(VM%x(me) / param%h_eff)
            cell_y  = ceiling(VM%y(me) / param%h_eff)
            my_cell = cell_x + (cell_y - 1) * cell%idx_x_max

            ! Store the cell index of the virtual marker
            cell%idx_VM(me) = my_cell

        enddo
        !$omp enddo
#endif

        !$omp end parallel

    end subroutine init_cell

end module init_cell_mod