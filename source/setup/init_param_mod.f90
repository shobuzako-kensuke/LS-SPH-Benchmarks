! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!         This file assigns the static parameters defined in `config.h`        !
!       and initializes the fundamental parameters used in the simulation.     !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module init_param_mod
    use global_types        , only: Param_type
    use kernel_functions_mod, only: cal_W

    implicit none

contains

    subroutine init_param(param)
        type(Param_type), intent(out) :: param

        ! ==================================================================== !
        !   User-defined Configurations (from `config.h`)
        ! ==================================================================== !
        ! Target Problem
        param%target_problem = TARGET_PROBLEM

        ! Boundary Conditions
        param%u_top          = U_TOP
        param%tem_top        = TEM_TOP
        param%tem_bottom     = TEM_BOTTOM
        param%tem_left       = TEM_LEFT
        param%tem_right      = TEM_RIGHT

        ! Input/Output Settings
        param%save_name      = SAVE_NAME
        param%read_name      = READ_NAME

        ! Parallel Computing Settings
        param%omp_threads    = OMP_THREADS

        ! Domain & Spatial Resolution
        param%len_x          = LEN_X
        param%len_y          = LEN_Y
        param%num_x          = NUM_X
        param%num_y          = NUM_Y

        ! Time Integration & Numerical Parameters
        param%start_step     = START_STEP
        param%end_step       = END_STEP
        param%write_step     = WRITE_STEP
        param%threshold      = THRESHOLD
        param%coe_CFL        = COE_CFL
        param%coe_dif        = COE_DIF
        param%zeta_RSST      = ZETA_RSST
        param%xi_VIM         = XI_VIM

        ! Fluid Physical Properties
        param%rho_ref        = RHO_REF
        param%vis_ref        = VIS_REF
        param%K_ref          = K_REF
        param%k_th_ref       = K_TH_REF
        param%cp_ref         = CP_REF
        param%alpha_ref      = ALPHA_REF

        ! Simulation Parameters
        param%gravity        = GRAVITY
        param%pos_pert       = POS_PERT
        param%tg_a           = TG_A
        param%tg_b           = TG_B
                
        ! SPH Parameters
        param%coe_h          = COE_H
        param%PST_c          = PST_C
        param%coe_delta_sph  = COE_DELTA_SPH

        ! Macro Options
        param%kernel_type    = KERNEL_TYPE
        param%sph_model      = SPH_MODEL
        param%wall_model     = WALL_MODEL


        ! ==================================================================== !
        !   Derived System Parameters [ Automatically calculated ]
        ! ==================================================================== !
        ! Total steps including the initial condition
        if (trim(adjustl(param%read_name)) == "new") then
            param%total_step = param%end_step
        else
            param%total_step = param%end_step - param%start_step
        endif

        ! Particle spacing for a uniform particle distribution [m]
        param%dx = param%len_x / dble(param%num_x)

        ! Mass of a particle [kg]
        param%SP_mass = param%rho_ref * (param%dx)**2
        
        ! Smoothing length [m]
        param%h = param%coe_h * param%dx

        ! Effective influence radius [m]
#if (KERNEL_TYPE == 2)
        param%h_eff = 3.0d0 * param%h  ! for the quintic spline
#else
        param%h_eff = 2.0d0 * param%h  ! for other kernels
#endif

        ! Average kernel value (W_ave) for a uniform particle distribution
        call cal_W(param%dx, param%h, param%W_ave)

        ! Number of ghost wall particle layers
        param%num_WL = ceiling(param%h_eff / param%dx)

        ! Wall thickness [m]
        param%WL_thick = dble(param%num_WL) * param%dx 

        ! Temperature difference & Average temperature [K]
#if (TARGET_PROBLEM == 4)
        ! Bottom-heated convection
        param%delta_tem = param%tem_bottom - param%tem_top
        param%tem_ave   = 0.5d0 * (param%tem_bottom + param%tem_top)
#else
        ! For other target problems
        param%delta_tem = 0.0d0
        param%tem_ave   = 0.0d0
#endif


        ! ==================================================================== !
        !   Physical Properties [ Automatically calculated ]
        ! ==================================================================== !
        ! Speed of sound [m s^-1]
        param%sound_speed = sqrt(param%K_ref / param%rho_ref)

        ! Kinematic viscosity [m^2 s^-1]
#if (TARGET_PROBLEM == 1)
        param%kinematic_vis = 1.0d0  ! Force to 1.0, for Diffusion Equation Test
#else
        param%kinematic_vis = param%vis_ref / param%rho_ref
#endif
        ! Thermal diffusivity [m^2 s^-1]
        param%thermal_dif = param%k_th_ref / (param%rho_ref * param%cp_ref)


        ! ==================================================================== !
        !   Non-dimensional Parameters [ Automatically calculated ]
        ! ==================================================================== !
        ! Reynolds number
#if   (TARGET_PROBLEM == 2)
        param%Re = 1.0d0       * param%len_x / param%kinematic_vis  ! For Taylor-Green vortex
#else
        param%Re = param%u_top * param%len_x / param%kinematic_vis  ! For lid-driven cavity flow
#endif

        ! Rayleigh number for Boussinesq convection
        param%Ra =   param%alpha_ref * param%delta_tem &
                   * param%gravity * param%len_y**3    &
                   / (param%kinematic_vis * param%thermal_dif)

        ! Prandtl number for Boussinesq convection
        param%Pr = param%kinematic_vis / param%thermal_dif


        ! ==================================================================== !
        !   Time Step [ Automatically calculated ]
        ! ==================================================================== !
        ! Time step for the CFL condition [s]
        param%dt_CFL = param%coe_CFL * (param%dx / param%sound_speed)

        ! Time step for the momentum diffusion condition [s]
        param%dt_vis = param%coe_dif * (param%dx**2 / param%kinematic_vis)

        ! Time step for the thermal diffusion condition [s]
        param%dt_th  = param%coe_dif * (param%dx**2 / param%thermal_dif)

        ! Relaxed time step [s]
        param%dt_CFL_relax = param%dt_CFL * param%zeta_RSST * param%xi_VIM
        param%dt_vis_relax = param%dt_vis * param%xi_VIM**2

        ! Effective time step [s]
#if   (TARGET_PROBLEM == 1)
        ! For Diffusion Equation Test
        param%dt = param%dt_vis

#elif (TARGET_PROBLEM == 4)
        ! For Boussinesq convection
        param%dt = min(param%dt_CFL_relax, param%dt_vis_relax, param%dt_th)

#else
        ! For other target problems
        param%dt = min(param%dt_CFL_relax, param%dt_vis_relax)
        
#endif

    end subroutine init_param

end module init_param_mod