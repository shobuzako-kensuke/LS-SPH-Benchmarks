! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!   This file defines the derived types (structures) used in the simulation.   !
!                                                                              !
! ============================================================================ !

module global_types
    implicit none

    ! ======================================================================== !
    !   Simulation Parameters
    !      - The members of this type consist of two categories:
    !         * User-defined configurations (from `config.h`) 
    !         * Automatically calculated
    ! ======================================================================== !
    type :: Param_type
        ! Target Problem [ User-defined ]
        integer            :: target_problem

        ! Boundary Conditions [ User-defined ]
        double precision   :: u_top
        double precision   :: tem_top, tem_bottom, tem_left, tem_right

        ! File & Input/Output Settings [ User-defined ]
        character(len=256) :: save_name
        character(len=256) :: read_name

        ! Parallel Computing Settings [ User-defined ]
        integer            :: omp_threads

        ! Domain & Spatial Resolution [ User-defined ]
        double precision   :: len_x, len_y
        integer            :: num_x, num_y

        ! Time Integration & Numerical Parameters [ User-defined ]
        integer            :: start_step, end_step, write_step
        double precision   :: threshold
        double precision   :: coe_CFL, coe_dif
        double precision   :: zeta_RSST, xi_VIM

        ! Fluid Physical Properties [ User-defined ]
        double precision   :: rho_ref, vis_ref, K_ref
        double precision   :: k_th_ref, cp_ref, alpha_ref

        ! Simulation Parameters [ User-defined ]
        double precision   :: gravity
        double precision   :: pos_pert
        integer            :: tg_a, tg_b
        
        ! SPH Parameters [ User-defined ]
        double precision   :: coe_h
        double precision   :: PST_c, PST_r, PST_n
        double precision   :: coe_delta_sph

        ! Macro Options [ User-defined ]
        integer            :: kernel_type, sph_model, wall_model

        ! [ Automatically calculated ]
        ! Details are provided in `source/setup/init_param_mod.f90`
        integer            :: total_step, num_WL
        double precision   :: dx, SP_mass, h, h_eff, W_ave, WL_thick
        double precision   :: delta_tem, tem_ave
        double precision   :: sound_speed, kinematic_vis, thermal_dif
        double precision   :: Re, Ra, Pr
        double precision   :: dt, dt_CFL, dt_vis, dt_th
        double precision   :: dt_CFL_relax, dt_vis_relax
    end type Param_type

    ! ======================================================================== !
    !   Smoothed Particles Data
    ! ======================================================================== !
    type :: SP_type
        integer                       :: num_total, num_int, num_ext
        integer         , allocatable :: ptype(:)

        ! Current state value (evaluated at each RK sub-step)
        double precision, allocatable :: x(:), y(:)
        double precision, allocatable :: u(:), v(:)
        double precision, allocatable :: rho(:), pre(:), tem(:)

        ! For RK time integration: Initial state at step n
        double precision, allocatable :: x_old(:), y_old(:)
        double precision, allocatable :: u_old(:), v_old(:)
        double precision, allocatable :: rho_old(:), tem_old(:)

        ! For RK4 time integration: Accumulator for the next time step n+1
        double precision, allocatable :: x_new(:), y_new(:)
        double precision, allocatable :: u_new(:), v_new(:)
        double precision, allocatable :: rho_new(:), tem_new(:)

        ! For spatial discretization: Right-Hand Sides (RHS) of the governing equations
        double precision, allocatable :: RHS_u(:), RHS_v(:)
        double precision, allocatable :: RHS_rho(:), RHS_tem(:)

        ! For Diffusion Equation Test
        double precision, allocatable :: f_previous(:)
    end type SP_type

    ! ======================================================================== !
    !   Virtual Markers (VM) Data
    ! ======================================================================== !
    type :: VM_type
        integer         , allocatable :: ptype(:), pair_WL_idx(:)
        double precision, allocatable :: x(:), y(:)
        double precision, allocatable :: u(:), v(:)
        double precision, allocatable :: pre(:), tem(:)
        double precision, allocatable :: n_x(:), n_y(:)
    end type VM_type

    ! ======================================================================== !
    !   Cell List
    ! ======================================================================== !
    type :: Cell_type
        integer              :: idx_x_max, idx_y_max, idx_max, capacity
        integer, allocatable :: idx_SP(:), num_SP(:), num_WL(:), neighbors(:,:)
        integer, allocatable :: list(:,:), list_WL(:,:)
        integer, allocatable :: idx_VM(:)
    end type Cell_type

end module global_types
