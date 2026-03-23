program main
    !=========================!
    !  module                 !
    !=========================!
    !$use omp_lib
    use input
    use global_variables

    !=========================!
    !  local variables        !
    !=========================!
    implicit none
    character(len=999) :: Nx_ID, x_rand_ID, save_step
    integer :: i, j
    real(8) :: omp_get_wtime

    write(*,*) '+ ------------------------------------------------------------------------ +'
    write(*,*) '[message] Calculation has started.'
    !$ start_time = omp_get_wtime()

    !=========================!
    !  main program           !
    !=========================!
    call check_options                  ! check compilation options
    
    do i = 1, size(Nx_set)
        do j = 1, size(x_rand_set)

            !=========================!
            !  fix parameters         !
            !=========================!
            Nx = Nx_set(i)                  ! fix Nx
            x_rand = x_rand_set(j)          ! fix x_rand
            write(Nx_ID,*) Nx
            write(x_rand_ID,'(F3.1)') x_rand
            save_name = 'Nx'//trim(adjustl(Nx_ID))//'_E'//trim(adjustl(x_rand_ID))//'_' &
                        //trim(adjustl(model_name))

            !=========================!
            !  initial setting        !
            !=========================!
            call out_input                      ! copy input file
            call set_system                     ! initial setting
            call set_background_cell            ! set background cell
            call cal_background_cell            ! cal background cell
            call cal_density                    ! cal density
#if defined(VM_ON)
            call cal_VM_to_WL                   ! cal virtual marker and wall
#endif
            call out_system_info                ! output system info
            call out_data('0')                  ! output initial setting

            !=========================!
            !  main loop              !
            !=========================!
            step = 0  ! zero clear

            do
                step = step + 1
                !=========================!
                !  SPH calculation        !
                !=========================!
                call cal_diffusion              ! calculate diffusion equation

                !=========================!
                !  check iteration        !
                !=========================!
                dif_f(:) = abs(SP_f_next(:) - SP_f(:N_inn))
                residual_max = maxval(dif_f)

                if (residual_max < threshold) then
                    write(save_step,*) step
                    call out_data(trim(adjustl(save_step)))  ! save
                    write(*,*) '[message] Calculation has finished.'
                    write(*,*) '+ ------------------------------------------------------------------------ +'
                    write(*,*) ''
                    exit

                else
                    SP_f(:N_inn) = SP_f_next(:)
#if defined(VM_ON)
                    call cal_VM_to_WL
#endif

                    if (mod(step, write_step) == 0) then     ! save
                    write(save_step,*) step
                        call out_data(trim(adjustl(save_step)))
                    endif

                    !$ tmp_time = omp_get_wtime()  ! get temporary CPU time
                    call out_progress              ! progress bar
                endif
            enddo

            call deallocate_array

        enddo
    enddo

end program main

! END !