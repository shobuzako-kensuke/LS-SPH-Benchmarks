# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#                This module provides the LS-SPH (type B) model.               #
#                                                                              #
# ============================================================================ #

import numpy as np
from types import SimpleNamespace
from scipy.spatial import KDTree  # K-Dimensional Tree method
from analysis.common import kernel_functions

# ============================================================================ #
#   Calculate the interpolation values using the LS-SPH type B
# ============================================================================ #
def main(param: SimpleNamespace, target_x: np.ndarray, target_y: np.ndarray, 
         x_j: np.ndarray, y_j: np.ndarray, val_j: np.ndarray, rho_j: np.ndarray) -> np.ndarray:
    
    # Setup parameters
    h_eff  = param.h_eff
    h      = param.h
    target      = param.target_problem
    kernel_type = param.kernel_type
    sph_model   = param.sph_model

    # Create a KD-Tree for fast neighbor search
    # x = [x1, x2, ...], y = [y1, y2, ...] -> np.column_stack((x, y)) = [[x1, y1], [x2, y2], ...]
    tree    = KDTree(np.column_stack((x_j, y_j)))
    targets = np.column_stack((target_x, target_y))
    
    # Find neighbors within the effective radius (h_eff)
    indices_list = tree.query_ball_point(targets, r=h_eff)
    
    # Interpolation values
    interpolated_vals = np.zeros((len(targets),3))

    # Define required matrix size based on the Taylor expansion order q
    if sph_model <= 3:
        q = 6 if target == 4 else 3
    elif sph_model == 4:
        q = 10 if target == 4 else 6
    elif sph_model == 5:
        q = 15 if target == 4 else 10
    elif sph_model == 6:
        q = 21 if target == 4 else 15
    else:
        raise ValueError("\n Unsupported interpolation order. Choose 1, 2, or 3.")
    
    # Calculate the interpolation values using the LS-SPH type B
    for i, (x_me, y_me) in enumerate(targets):
        neighbors = indices_list[i]
        
        # If no particles are found or matrix is singular, return NaN
        if len(neighbors) < q:
            interpolated_vals[i,:] = np.nan
            continue
            
        dx = x_j[neighbors] - x_me  # x_j - x_i
        dy = y_j[neighbors] - y_me  # y_j - y_i
        r  = np.sqrt(dx**2 + dy**2) 
        
        # Calculate kernel functions
        # Here, we use the Wendland C2 kernel, but you can switch to other kernels
        # See `analysis/common/kernel_functions.py`
        if kernel_type == 1:
            W = kernel_functions.cubic_spline_W(r, h)
        elif kernel_type == 2:
            W = kernel_functions.quintic_spline_W(r, h)
        elif kernel_type == 3:
            W = kernel_functions.wendland_C2_W(r, h)
        elif kernel_type == 4:
            W = kernel_functions.wendland_C4_W(r, h)
        elif kernel_type == 5:
            W = kernel_functions.wendland_C6_W(r, h)
        else:
            raise ValueError(f"Invalid KERNEL_TYPE: {kernel_type}")

        # Normalize distances by h to prevent matrix ill-conditioning
        dx_h = dx / h
        dy_h = dy / h
        
        # LS-SPH Type B Matrix components (1, dx, dy)
        if q == 3:
            A = np.column_stack((
                np.ones_like(dx_h), 
                dx_h, dy_h
                ))

        elif q == 6:
            A = np.column_stack((
                np.ones_like(dx_h), 
                dx_h, dy_h,
                0.5*dx_h**2, dx_h*dy_h, 0.5*dy_h**2
                ))
            
        elif q == 10:
            A = np.column_stack((
                np.ones_like(dx_h),
                dx_h, dy_h,
                0.5*dx_h**2, dx_h*dy_h, 0.5*dy_h**2,
                (1.0/6.0)*dx_h**3, 0.5*dx_h**2*dy_h, 0.5*dx_h*dy_h**2, (1.0/6.0)*dy_h**3))
    

        elif q == 15:
            A = np.column_stack((
                np.ones_like(dx_h), 
                dx_h, dy_h, 
                0.5*dx_h**2, 0.5*dy_h**2, dx_h*dy_h, 
                (1.0/6.0)*dx_h**3, (1.0/6.0)*dy_h**3, 0.5*dx_h**2*dy_h, 0.5*dy_h**2*dx_h,
                (1.0/24.0)*dx_h**4, (1.0/24.0)*dy_h**4, (1.0/6.0)*dx_h**3*dy_h, (1.0/6.0)*dy_h**3*dx_h, 0.25*dx_h**2*dy_h**2
            ))
            
        elif q == 21:
            A = np.column_stack((
                np.ones_like(dx_h), 
                dx_h, dy_h, 
                0.5*dx_h**2, 0.5*dy_h**2, dx_h*dy_h, 
                (1.0/6.0)*dx_h**3, (1.0/6.0)*dy_h**3, 0.5*dx_h**2*dy_h, 0.5*dy_h**2*dx_h,
                (1.0/24.0)*dx_h**4, (1.0/24.0)*dy_h**4, (1.0/6.0)*dx_h**3*dy_h, (1.0/6.0)*dy_h**3*dx_h, 0.25*dx_h**2*dy_h**2,
                (1.0/120.0)*dx_h**5, (1.0/120.0)*dy_h**5, (1.0/24.0)*dx_h**4*dy_h, (1.0/24.0)*dy_h**4*dx_h, (1.0/12.0)*dx_h**3*dy_h**2, (1.0/12.0)*dy_h**3*dx_h**2
            ))

        V_j   = param.SP_mass / rho_j[neighbors]
        W_mat = np.diag(W * V_j)
        
        # Normal equation M*d = b
        M = A.T @ W_mat @ A                  # M = A^T * W * A
        b = A.T @ W_mat @ val_j[neighbors]  # b = A^T * W * f_j
        
        try:
            # Solve M*d = b
            d = np.linalg.solve(M, b)
            interpolated_vals[i,0 ] = d[0]
            interpolated_vals[i,1:] = d[1:3] / h

        except np.linalg.LinAlgError:
            interpolated_vals[i,:] = np.nan
                
    return interpolated_vals