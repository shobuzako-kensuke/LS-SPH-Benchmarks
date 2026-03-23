module input
    implicit none
    !=========================!
    !  file name              !
    !=========================!
    character(len=999), parameter :: model_name = 'LS2_const_WL3_set1'
    !=========================!
    !  General settings       !
    !=========================!
    integer, parameter :: N_threads  = 8        ! number of threads in OpenMP
    integer, parameter :: write_step = 1000000  ! writing interval
    real(8), parameter :: threshold  = 1.0d-14  ! iteration threshold
    real(8), parameter :: Nh         = 1.2d0    ! h = Nh * Delta x
    real(8), parameter :: rho_ref    = 1.0d0    ! reference density [kg m-3]

    ! integer, parameter :: Nx_set    (6) = (/10, 21, 46, 100, 215, 464/) ! number of particles along x axis
    integer, parameter :: Nx_set    (4) = (/10, 21, 46, 100/) ! number of particles along x axis
    real(8), parameter :: x_rand_set(2) = (/0.0d0, 0.3d0/)              ! position perturbation
    
end module input

! END !