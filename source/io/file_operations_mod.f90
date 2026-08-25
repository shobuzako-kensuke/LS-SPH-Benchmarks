! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!   This file handles directory creation, file copying, and binary/ASCII I/O.  !
!                                                                              !
! ============================================================================ !

module file_operations_mod
    
    implicit none

contains
    ! ======================================================================== !
    !   Make directory
    ! ======================================================================== !
    subroutine mkdir(directory_name)
        character(len=*), intent(in) :: directory_name
        character(len=1024)          :: command

        command = "mkdir -p " // trim(adjustl(directory_name))
        call execute_command_line(trim(command))

    end subroutine mkdir

    ! ======================================================================== !
    !   Copy file
    ! ======================================================================== !
    subroutine cp_file(from, to)
        character(len=*), intent(in) :: from, to
        character(len=1024)          :: command

        command = "cp -f " // trim(adjustl(from)) // " " // trim(adjustl(to))
        call execute_command_line(trim(command))

    end subroutine cp_file

    ! ======================================================================== !
    !   Write data to binary file
    ! ======================================================================== !
    subroutine write_binary(file_name, array)
        character(len=*), intent(in) :: file_name
        double precision, intent(in) :: array(:)
        integer                      :: un

        open(newunit=un, file=trim(adjustl(file_name)), status="replace", &
             form="unformatted", access="stream")
        write(un) array
        close(un)

    end subroutine write_binary

    ! ======================================================================== !
    !   Write data to ASCII file
    ! ======================================================================== !
    subroutine write_ascii(file_name, array)
        character(len=*), intent(in) :: file_name
        double precision, intent(in) :: array(:)
        integer                      :: un

        open(newunit=un, file=trim(adjustl(file_name)), status="replace", &
             form="formatted")
        write(un, '(e21.14)') array
        close(un)

    end subroutine write_ascii

    ! ======================================================================== !
    !   Read data from binary file
    ! ======================================================================== !
    subroutine read_binary(file_name, array)
        character(len=*), intent(in)  :: file_name
        double precision, intent(out) :: array(:)
        integer                       :: un

        open(newunit=un, file=trim(adjustl(file_name)), status="old", &
             form="unformatted", access="stream")
        read(un) array
        close(un)

    end subroutine read_binary

end module file_operations_mod