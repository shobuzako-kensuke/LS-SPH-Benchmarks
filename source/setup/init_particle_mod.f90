! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!         This file performs the following tasks:                              !
!         (1) Set particle positions and classify the particle types.          !
!         (2) Impose the initial conditions (for a fresh start).               !
!         (3) Restore the simulation data (for a restart)                      !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module init_particle_mod
    use global_types, only: Param_type, SP_type

    ! Module for problems with a closed box domain 
#if (1 <= TARGET_PROBLEM) && (TARGET_PROBLEM <= 4)
    use setup_closed_box_mod, only: setup_closed_box
#endif

    ! Module for the initial condition
#if   (TARGET_PROBLEM == 1)
    use impose_initial_conditions_mod, only: impose_diffusion_equation
#elif (TARGET_PROBLEM == 2)
    use impose_initial_conditions_mod, only: impose_TG_vortex
#elif (TARGET_PROBLEM == 3)
    use impose_initial_conditions_mod, only: impose_cavity
#elif (TARGET_PROBLEM == 4)
    use impose_initial_conditions_mod, only: impose_boussinesq_convection
#endif

    ! Module for restart
#if (1 <= TARGET_PROBLEM) && (TARGET_PROBLEM <= 4)
    use restart_mod, only: restart_closed_box
#endif

    implicit none

contains

    subroutine init_particle(param, SP)
        type(Param_type), intent(in)  :: param
        type(SP_type)   , intent(out) :: SP

        ! ==================================================================== !
        !   1. Set particle positions and classify the particle types
        ! ==================================================================== !
#if (1 <= TARGET_PROBLEM) && (TARGET_PROBLEM <= 4)
        call setup_closed_box(param, SP)
#endif

        ! ==================================================================== !
        !   2. Initialization branch: New Simulation or Restart
        ! ==================================================================== !
        if (trim(adjustl(param%read_name)) == "new") then

            
            ! ================================================================ !
            !   [2-A] New Simulation: Impose the initial conditions
            ! ================================================================ !
#if   (TARGET_PROBLEM == 1)
            call impose_diffusion_equation(param, SP)
#elif (TARGET_PROBLEM == 2)
            call impose_TG_vortex(param, SP)
#elif (TARGET_PROBLEM == 3)
            call impose_cavity(param, SP)
#elif (TARGET_PROBLEM == 4)
            call impose_boussinesq_convection(param, SP)
#endif

        else
            ! ================================================================ !
            !   [2-B] Restart: Read and restore the simulation data
            ! ================================================================ !
#if (1 <= TARGET_PROBLEM) && (TARGET_PROBLEM <= 4)
            call restart_closed_box(param, SP)
#endif

        endif

    end subroutine init_particle

end module init_particle_mod

