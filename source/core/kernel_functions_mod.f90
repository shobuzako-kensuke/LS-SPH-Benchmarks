! ============================================================================ !
!                                                                              !
!                              LS-SPH-Benchmarks                               !
!                                                                              !
!                     Copyright (c) 2026 Kensuke SHOBUZAKO                     !
!               This program is licensed under the MIT License.                !
!                                                                              !
!                              ~~ Description ~~                               !
!                  This file implements the kernel functions                   !
!                    and their derivatives used in the SPH.                    !
!                                                                              !
! ============================================================================ !

#include "../../config.h"

module kernel_functions_mod
    
    implicit none
    
    double precision, parameter, private :: pi = acos(-1.0d0)

contains
    ! ========================================================================= !
    !   Calculate the Kernel Function Value (for 2D)
    ! ========================================================================= !
    pure subroutine cal_W(r, h, W)
        double precision, intent(in)  :: r, h
        double precision, intent(out) :: W
        double precision              :: q
        
        q = r/h

#if (KERNEL_TYPE == 1)
        if ((0.0d0 <= q) .and. (q <= 1.0d0)) then
            W = (2.0d0-q)**3 - 4.0d0*(1.0d0-q)**3
        elseif ((1.0d0 < q) .and. (q <= 2.0d0)) then
            W = (2.0d0-q)**3
        else
            W = 0.0d0
        endif
        W = 5.0d0 / (14.0d0 * pi * h**2) * W

#elif (KERNEL_TYPE == 2)
        if ((0.0d0 <= q) .and. (q <= 1.0d0)) then
            W = (3.0d0-q)**5 - 6.0d0*(2.0d0-q)**5 + 15.0d0*(1.0d0-q)**5
        elseif ((1.0d0 < q) .and. (q <= 2.0d0)) then
            W = (3.0d0-q)**5 - 6.0d0*(2.0d0-q)**5
        elseif ((2.0d0 < q) .and. (q <= 3.0d0)) then
            W = (3.0d0-q)**5
        else
            W = 0.0d0
        endif
        W = 7.0d0 / (478.0d0 * pi * h**2) * W

#elif (KERNEL_TYPE == 3)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            W = (1.0d0 - 0.5d0*q)**4 * (1.0d0 + 2.0d0*q)
        else
            W = 0.0d0
        endif
        W = 7.0d0 / (4.0d0 * pi * h**2) * W

#elif (KERNEL_TYPE == 4)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            W = (1.0d0 - 0.5d0*q)**6 * (1.0d0 + 3.0d0*q + 35.0d0*q**2/12.0d0)
        else
            W = 0.0d0
        endif
        W = 9.0d0 / (4.0d0 * pi * h**2) * W

#elif (KERNEL_TYPE == 5)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            W = (1.0d0 - 0.5d0*q)**8 * &
                (1.0d0 + 4.0d0*q + 25.0d0*q**2/4.0d0 + 4.0d0*q**3)
        else
            W = 0.0d0
        endif
        W = 39.0d0 / (14.0d0 * pi * h**2) * W
#endif

    end subroutine cal_W


    ! ========================================================================= !
    !   Calculate the First Derivative of the Kernel Function (for 2D)
    ! ========================================================================= !
    pure subroutine cal_dW(r, h, dW)
        double precision, intent(in)  :: r, h
        double precision, intent(out) :: dW
        double precision              :: q
        
        q = r/h

#if (KERNEL_TYPE == 1)
        if ((0.0d0 <= q) .and. (q <= 1.0d0)) then
            dW = (2.0d0-q)**2 - 4.0d0*(1.0d0-q)**2
        elseif ((1.0d0 < q) .and. (q <= 2.0d0)) then
            dW = (2.0d0-q)**2
        else
            dW = 0.0d0
        endif
        dW = 5.0d0 / (14.0d0 * pi * h**2) * dW * (-3.0d0/h)

#elif (KERNEL_TYPE == 2)
        if ((0.0d0 <= q) .and. (q <= 1.0d0)) then
            dW = (3.0d0-q)**4 - 6.0d0*(2.0d0-q)**4 + 15.0d0*(1.0d0-q)**4
        elseif ((1.0d0 < q) .and. (q <= 2.0d0)) then
            dW = (3.0d0-q)**4 - 6.0d0*(2.0d0-q)**4
        elseif ((2.0d0 < q) .and. (q <= 3.0d0)) then
            dW = (3.0d0-q)**4
        else
            dW = 0.0d0
        endif
        dW = 7.0d0 / (478.0d0 * pi * h**2) * dW *(-5.0d0/h)

#elif (KERNEL_TYPE == 3)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            dW = -2.0d0*(1.0d0 - 0.5d0*q)**3 * (1.0d0 + 2.0d0*q) &
                 +2.0d0*(1.0d0 - 0.5d0*q)**4
        else
            dW = 0.0d0
        endif
        dW = 7.0d0 / (4.0d0 * pi * h**2) * dW / h

#elif (KERNEL_TYPE == 4)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            dW = -3.0d0*(1.0d0 - 0.5d0*q)**5 * (1.0d0 + 3.0d0*q + 35.0d0*q**2/12.0d0) &
                 +1.0d0*(1.0d0 - 0.5d0*q)**6 * (3.0d0 + 35.0d0*q/6.0d0)
        else
            dW = 0.0d0
        endif
        dW = 9.0d0 / (4.0d0 * pi * h**2) * dW / h

#elif (KERNEL_TYPE == 5)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            dW = -4.0d0*(1.0d0 - 0.5d0*q)**7 &
                * (1.0d0 + 4.0d0*q + 25.0d0*q**2/4.0d0 + 4.0d0*q**3) &
                +1.0d0*(1.0d0 - 0.5d0*q)**8 &
                * (4.0d0 + 25.0d0*q/2.0d0 + 12.0d0*q**2)
        else
            dW = 0.0d0
        endif
        dW = 39.0d0 / (14.0d0 * pi * h**2) * dW / h
#endif

    end subroutine cal_dW


    ! ========================================================================= !
    !   Calculate the Second Derivative of the Kernel Function (for 2D)
    ! ========================================================================= !
    pure subroutine cal_ddW(r, h, ddW)
        double precision, intent(in)  :: r, h
        double precision, intent(out) :: ddW
        double precision              :: q
        
        q = r/h

#if (KERNEL_TYPE == 1)
        if ((0.0d0 <= q) .and. (q <= 1.0d0)) then
            ddW = (2.0d0-q) - 4.0d0*(1.0d0-q)
        elseif ((1.0d0 < q) .and. (q <= 2.0d0)) then
            ddW = (2.0d0-q)
        else
            ddW = 0.0d0
        endif
        ddW = 5.0d0 / (14.0d0 * pi * h**2) * ddW * (6.0d0/h**2)

#elif (KERNEL_TYPE == 2)
        if ((0.0d0 <= q) .and. (q <= 1.0d0)) then
            ddW = (3.0d0-q)**3 - 6.0d0*(2.0d0-q)**3 + 15.0d0*(1.0d0-q)**3
        elseif ((1.0d0 < q) .and. (q <= 2.0d0)) then
            ddW = (3.0d0-q)**3 - 6.0d0*(2.0d0-q)**3
        elseif ((2.0d0 < q) .and. (q <= 3.0d0)) then
            ddW = (3.0d0-q)**3
        else
            ddW = 0.0d0
        endif
        ddW = 7.0d0 / (478.0d0 * pi * h**2) * ddW *(20.0d0/h**2)

#elif (KERNEL_TYPE == 3)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            ddW = +3.0d0*(1.0d0 - 0.5d0*q)**2 * (1.0d0 + 2.0d0*q) &
                  -8.0d0*(1.0d0 - 0.5d0*q)**3
        else
            ddW = 0.0d0
        endif
        ddW = 7.0d0 / (4.0d0 * pi * h**2) * ddW / h**2

#elif (KERNEL_TYPE == 4)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            ddW = +15.0d0/2.0d0*(1.0d0 - 0.5d0*q)**4 &
                           * (1.0d0 + 3.0d0*q + 35.0d0*q**2/12.0d0) &
                  -6.0d0   *(1.0d0 - 0.5d0*q)**5 * (3.0d0 + 35.0d0*q/6.0d0) &
                  +1.0d0   *(1.0d0 - 0.5d0*q)**6 * (35.0d0/6.0d0)
            else
            ddW = 0.0d0
        endif
        ddW = 9.0d0 / (4.0d0 * pi * h**2) * ddW / h**2

#elif (KERNEL_TYPE == 5)
        if ((0.0d0 <= q) .and. (q <= 2.0d0)) then
            ddW = +14.0d0*(1.0d0 - 0.5d0*q)**6 &
                         * (1.0d0 + 4.0d0*q + 25.0d0*q**2/4.0d0 + 4.0d0*q**3) &
                  -8.0d0 *(1.0d0 - 0.5d0*q)**7 * (4.0d0 + 25.0d0*q/2.0d0 + 12.0d0*q**2) &
                  +1.0d0 *(1.0d0 - 0.5d0*q)**8 * (25.0d0/2.0d0 + 24.0d0*q)
        else
            ddW = 0.0d0
        endif
        ddW = 39.0d0 / (14.0d0 * pi * h**2) * ddW / h**2
#endif

    end subroutine cal_ddW

end module kernel_functions_mod