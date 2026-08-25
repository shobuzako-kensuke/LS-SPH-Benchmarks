# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#             This module provides various kernel functions for 2D.            #
#                                                                              #
# ============================================================================ #

import numpy as np

# ============================================================================ #
#  Cubic Spline Kernel
# ============================================================================ #
def cubic_spline_W(r: np.ndarray, h: float) -> np.ndarray:
    q = np.abs(r / h)
    W = np.zeros_like(q)
    
    mask1 = (q >= 0.0) & (q <= 1.0)
    mask2 = (q >  1.0) & (q <= 2.0)
    
    W[mask1] = (2.0 - q[mask1])**3 - 4.0 * (1.0 - q[mask1])**3
    W[mask2] = (2.0 - q[mask2])**3
    
    return 5.0 / (14.0 * np.pi * h**2) * W

# ============================================================================ #
#  Quintic Spline Kernel
# ============================================================================ #
def quintic_spline_W(r: np.ndarray, h: float) -> np.ndarray:
    q = np.abs(r / h)
    W = np.zeros_like(q)
    
    mask1 = (q >= 0.0) & (q <= 1.0)
    mask2 = (q >  1.0) & (q <= 2.0)
    mask3 = (q >  2.0) & (q <= 3.0)
    
    W[mask1] = (3.0 - q[mask1])**5 - 6.0 * (2.0 - q[mask1])**5 + 15.0 * (1.0 - q[mask1])**5
    W[mask2] = (3.0 - q[mask2])**5 - 6.0 * (2.0 - q[mask2])**5
    W[mask3] = (3.0 - q[mask3])**5
    
    return 7.0 / (478.0 * np.pi * h**2) * W

# ============================================================================ #
#  Wendland C2 Kernel
# ============================================================================ #
def wendland_C2_W(r: np.ndarray, h: float) -> np.ndarray:
    q = np.abs(r / h)
    W = np.zeros_like(q)
    
    mask = (q >= 0.0) & (q <= 2.0)
    W[mask] = (1.0 - 0.5 * q[mask])**4 * (1.0 + 2.0 * q[mask])
    
    return 7.0 / (4.0 * np.pi * h**2) * W

# ============================================================================ #
#  Wendland C4 Kernel
# ============================================================================ #
def wendland_C4_W(r: np.ndarray, h: float) -> np.ndarray:
    q = np.abs(r / h)
    W = np.zeros_like(q)
    
    mask = (q >= 0.0) & (q <= 2.0)
    W[mask] = (1.0 - 0.5 * q[mask])**6 * (1.0 + 3.0 * q[mask] + 35.0 * q[mask]**2 / 12.0)
    
    return 9.0 / (4.0 * np.pi * h**2) * W

# ============================================================================ #
#  Wendland C6 Kernel
# ============================================================================ #
def wendland_C6_W(r: np.ndarray, h: float) -> np.ndarray:
    q = np.abs(r / h)
    W = np.zeros_like(q)
    
    mask = (q >= 0.0) & (q <= 2.0)
    W[mask] = (1.0 - 0.5 * q[mask])**8 * (1.0 + 4.0 * q[mask] + 25.0 * q[mask]**2 / 4.0 + 4.0 * q[mask]**3)
    
    return 39.0 / (14.0 * np.pi * h**2) * W