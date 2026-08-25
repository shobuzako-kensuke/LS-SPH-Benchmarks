! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!        This file exports the simulation configurations and parameters.       !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module write_param_mod
    use global_types       , only: Param_type, SP_type, VM_type, Cell_type
    use file_operations_mod, only: mkdir, cp_file

#if (1 <= WALL_MODEL) && (WALL_MODEL <= 3)
    use ghost_mod          , only: ghost
#endif

    implicit none

contains

    subroutine write_param(param, SP, VM, cell)
        type(Param_type), intent(in)    :: param
        type(SP_type)   , intent(inout) :: SP
        type(VM_type)   , intent(inout) :: VM
        type(Cell_type) , intent(in)    :: cell
        
        character(len=1024) :: base_dir, config_dir, data_dir
        integer             :: un
        
        ! ==================================================================== !
        !   1. Set up directory paths
        ! ==================================================================== !
        base_dir   = "results/" // trim(adjustl(param%save_name))
        config_dir = trim(base_dir) // "/config"
        data_dir   = trim(base_dir) // "/data"

        ! ==================================================================== !
        !   2. Make directories
        ! ==================================================================== !
        call mkdir(base_dir)    ! results/SAVE_NAME
        call mkdir(config_dir)  ! results/SAVE_NAME/config
        call mkdir(data_dir)    ! results/SAVE_NAME/data

        ! ==================================================================== !
        !   3. Copy `config.h`
        ! ==================================================================== !
        call cp_file("config.h", trim(config_dir)//"/")
    
        ! ==================================================================== !
        !   4. Export simulation parameters to ASCII file
        ! ==================================================================== !
        open(newunit=un, file=trim(config_dir) // "/parameters.csv", &
             status="replace", form="formatted")

        write(un, "(a)") "Parameter, Value"

        ! User-defined configurations
        write(un, "(a, ',', i0    )") "target_problem", param%target_problem
        write(un, "(a, ',', e21.14)") "u_top"         , param%u_top
        write(un, "(a, ',', e21.14)") "tem_top"       , param%tem_top
        write(un, "(a, ',', e21.14)") "tem_bottom"    , param%tem_bottom
        write(un, "(a, ',', e21.14)") "tem_left"      , param%tem_left
        write(un, "(a, ',', e21.14)") "tem_right"     , param%tem_right
        write(un, "(a, ',', e21.14)") "len_x"         , param%len_x
        write(un, "(a, ',', e21.14)") "len_y"         , param%len_y
        write(un, "(a, ',', i0    )") "num_x"         , param%num_x
        write(un, "(a, ',', i0    )") "num_y"         , param%num_y
        write(un, "(a, ',', i0    )") "start_step"    , param%start_step
        write(un, "(a, ',', i0    )") "end_step"      , param%end_step
        write(un, "(a, ',', i0    )") "write_step"    , param%write_step
        write(un, "(a, ',', e21.14)") "threshold"     , param%threshold
        write(un, "(a, ',', e21.14)") "coe_CFL"       , param%coe_CFL
        write(un, "(a, ',', e21.14)") "coe_dif"       , param%coe_dif
        write(un, "(a, ',', e21.14)") "zeta_RSST"     , param%zeta_RSST
        write(un, "(a, ',', e21.14)") "xi_VIM"        , param%xi_VIM
        write(un, "(a, ',', e21.14)") "rho_ref"       , param%rho_ref
        write(un, "(a, ',', e21.14)") "vis_ref"       , param%vis_ref
        write(un, "(a, ',', e21.14)") "K_ref"         , param%K_ref
        write(un, "(a, ',', e21.14)") "k_th_ref"      , param%k_th_ref
        write(un, "(a, ',', e21.14)") "cp_ref"        , param%cp_ref
        write(un, "(a, ',', e21.14)") "alpha_ref"     , param%alpha_ref
        write(un, "(a, ',', e21.14)") "gravity"       , param%gravity
        write(un, "(a, ',', e21.14)") "pos_pert"      , param%pos_pert
        write(un, "(a, ',', i0    )") "tg_a"          , param%tg_a
        write(un, "(a, ',', i0    )") "tg_b"          , param%tg_b
        write(un, "(a, ',', e21.14)") "coe_h"         , param%coe_h
        write(un, "(a, ',', e21.14)") "PST_c"         , param%PST_c
        write(un, "(a, ',', e21.14)") "coe_delta_sph" , param%coe_delta_sph
        write(un, "(a, ',', i0    )") "kernel_type"   , param%kernel_type
        write(un, "(a, ',', i0    )") "sph_model"     , param%sph_model
        write(un, "(a, ',', i0    )") "wall_model"    , param%wall_model

        ! Automatically calculated parameters
        write(un, "(a, ',', i0    )") "total_step"    , param%total_step
        write(un, "(a, ',', e21.14)") "dx"            , param%dx
        write(un, "(a, ',', e21.14)") "SP_mass"       , param%SP_mass
        write(un, "(a, ',', e21.14)") "h"             , param%h
        write(un, "(a, ',', e21.14)") "h_eff"         , param%h_eff
        write(un, "(a, ',', e21.14)") "W_ave"         , param%W_ave
        write(un, "(a, ',', i0    )") "num_WL"        , param%num_WL
        write(un, "(a, ',', e21.14)") "WL_thick"      , param%WL_thick
        write(un, "(a, ',', e21.14)") "delta_tem"     , param%delta_tem
        write(un, "(a, ',', e21.14)") "tem_ave"       , param%tem_ave
        write(un, "(a, ',', e21.14)") "sound_speed"   , param%sound_speed
        write(un, "(a, ',', e21.14)") "kinematic_vis" , param%kinematic_vis
        write(un, "(a, ',', e21.14)") "thermal_dif"   , param%thermal_dif
        write(un, "(a, ',', e21.14)") "Re"            , param%Re
        write(un, "(a, ',', e21.14)") "Ra"            , param%Ra
        write(un, "(a, ',', e21.14)") "Pr"            , param%Pr
        write(un, "(a, ',', e21.14)") "dt_CFL"        , param%dt_CFL
        write(un, "(a, ',', e21.14)") "dt_vis"        , param%dt_vis
        write(un, "(a, ',', e21.14)") "dt_th"         , param%dt_th
        write(un, "(a, ',', e21.14)") "dt_CFL_relax"  , param%dt_CFL_relax
        write(un, "(a, ',', e21.14)") "dt_vis_relax"  , param%dt_vis_relax
        write(un, "(a, ',', e21.14)") "dt"            , param%dt

        ! Number of particles in `SP`
        write(un, "(a, ',', i0    )") "num_total"     , SP%num_total
        write(un, "(a, ',', i0    )") "num_int"       , SP%num_int
        write(un, "(a, ',', i0    )") "num_ext"       , SP%num_ext

        close(un)

        ! ==================================================================== !
        !   5. Export Cell List
        ! ==================================================================== !
        open(newunit=un, file=trim(data_dir) // "/cell_idx.dat", &
             status="replace", form="unformatted", access="stream")
        write(un) cell%idx_SP(1 : SP%num_total)
        close(un)

        ! ==================================================================== !
        !   6. Export virtual markers' data
        ! ==================================================================== !
#if (1 <= WALL_MODEL) && (WALL_MODEL <= 3)
        
        ! Calculate VM's data
        call ghost(param, SP, VM, cell)

        ! Write VM's data
        open(newunit=un, file=trim(data_dir) // "/VM.dat", &
             status="replace", form="unformatted", access="stream")
        write(un) VM%ptype(1 : SP%num_ext)
        write(un) VM%x    (1 : SP%num_ext)
        write(un) VM%y    (1 : SP%num_ext)
        write(un) VM%u    (1 : SP%num_ext)
        write(un) VM%v    (1 : SP%num_ext)
        write(un) VM%pre  (1 : SP%num_ext)
#if (TARGET_PROBLEM == 4)
        write(un) VM%tem  (1 : SP%num_ext)
#endif

        close(un)

#endif

    end subroutine write_param

end module write_param_mod