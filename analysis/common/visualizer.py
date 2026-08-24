# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#            This module handles the design of the generated figures.          #
#                                                                              #
# ============================================================================ #

import math
import matplotlib.pyplot as plt
from types import SimpleNamespace

# ============================================================================ #
#   Set general figure style
# ============================================================================ #
def set_figure_style():
    plt.rcParams.update({
        "font.family": "serif",       # Font family
        "font.size": 8,               # Basic font size
        "mathtext.fontset": "stix",   # Math font style (LaTeX-like)
        "axes.labelsize": 14,         # Axis label font size
        "xtick.labelsize": 9,         # X-axis tick label font size
        "ytick.labelsize": 9,         # Y-axis tick label font size
        "legend.fontsize": 10,        # Legend font size
        "xtick.direction": "in",      # Direct X-axis ticks inward
        "ytick.direction": "in",      # Direct Y-axis ticks inward
        "xtick.top": True,            # Display ticks on the top axis
        "ytick.right": True,          # Display ticks on the right axis
        "axes.linewidth": 1.05,       # Axis line width
        "xtick.major.pad": 6,         # Shift X-axis tick labels down
        "ytick.major.pad": 6,         # Shift Y-axis tick labels left
        "savefig.bbox": "tight",      # Remove excess whitespace when saving
    })

# ============================================================================ #
#   Scatter marker size
# ============================================================================ #
def get_scatter_size(num_int: int, with_wall: bool) -> float:
    if num_int <= 50**2:
        return 60 if with_wall else 60
    
    elif num_int <= 100**2:
        return 15 if with_wall else 15
        
    elif num_int <= 200**2:
        return 5 if with_wall else 5
    
    else:
        return 2.5 if with_wall else 2.5

# ============================================================================ #
#   Domain Settings (X and Y axis ticks)
# ============================================================================ #
def get_domain_settings(param: SimpleNamespace) -> dict:
    
    # Target problem
    target = param.target_problem

    if target in [1,2,3,4]:

        # Characteristic length Ly
        L_ref = param.len_y if target != 1 else 1.0

        # Scaled domain limits
        x_min = 0.0
        x_max = param.len_x / L_ref
        y_min = 0.0
        y_max = param.len_y / L_ref

        # Set tick intervals to a quarter of the scaled domain size
        x_step = (x_max - x_min) / 4.0
        y_step = (y_max - y_min) / 4.0

        # Axis labels
        if target == 1:
            x_label, y_label = r"$x$", r"$y$"
        else:
            x_label, y_label = r"$x^{*}$", r"$y^{*}$"

    return {
        "L_ref"  : L_ref,
        "x_min"  : x_min,   "x_max"  : x_max, 
        "y_min"  : y_min,   "y_max"  : y_max,
        "x_step" : x_step,  "y_step" : y_step,
        "x_label": x_label, "y_label": y_label
    }

# ============================================================================ #
#   Time Settings (Scaling factor and label)
# ============================================================================ #
def get_time_settings(param: SimpleNamespace) -> dict:

    # Target problem
    target = param.target_problem

    # Diffusion Equation Test
    if target == 1:
        return {"scale": 1.0, "label": r"Time $t$"}
    
    # Taylor-Green vortex or Lid-driven cavity flow
    elif target in [2,3]:
        U_ref = 1.0 if target == 2 else param.u_top
        return {"scale": param.len_y / U_ref, "label": r"Time $t^{*}$"}
    
    # Boussinesq convection
    elif target == 4:
        if param.Pr < 1.0:
            U_ref = math.sqrt(param.alpha_ref * param.gravity * param.delta_tem * param.len_y)
        else:
            U_ref = param.thermal_dif / param.len_y
        return {"scale": param.len_y / U_ref, "label": r"Time $t^{*}$"}
    
    else:
        return {"scale": 1.0, "label": r"Time $t$"}
    
# ============================================================================ #
#   Plot settings (vmin, vmax, cmap, label, and scaling factor)
# ============================================================================ #
def get_plot_settings(param: SimpleNamespace) -> dict:
    target   = param.target_problem
    settings = {}

    # Diffusion Equation Test
    if target == 1:
        settings = {
            "u": {"min": -1.0, "max": 1.0, "cmap": "jet", "label": r"$f$", "scale": 1.0, "offset": 0.0, "step": 0.5},
        }
    
    # Taylor-Green vortex or Lid-driven cavity flow
    elif target in [2, 3]:
        U_ref = 1.0 if target == 2 else param.u_top
        P_ref = param.rho_ref * (U_ref**2)
        settings = {
            "u":   {"min": -1.0, "max": 1.0, "cmap": "jet", "label": r"$u^{*}$", "scale": U_ref, "offset": 0.0, "step": 0.5},
            "v":   {"min": -1.0, "max": 1.0, "cmap": "jet", "label": r"$v^{*}$", "scale": U_ref, "offset": 0.0, "step": 0.5},
            "pre": {"min": -0.5, "max": 0.5, "cmap": "jet", "label": r"$p^{*}$", "scale": P_ref, "offset": 0.0, "step": 0.25},
            "U":   {"min":  0.0, "max": 1.0, "cmap": "jet", "label": r"$|\mathbf{u}^{*}|$", "scale": U_ref, "offset": 0.0, "step": 0.25},
        }

    # Boussinesq convection
    elif target == 4:

        # For air convection (Prandtl number << 1)
        if param.Pr < 1.0:
            U_ref = math.sqrt(param.alpha_ref * param.gravity * param.delta_tem * param.len_y)
            P_ref = param.rho_ref * (U_ref**2)
        
        # For mantle convection (Prandtl number >> 1)
        else:
            U_ref = param.thermal_dif / param.len_y
            P_ref = param.rho_ref * param.kinematic_vis * U_ref / param.len_y

        T_ref = param.delta_tem
        T_ave = param.tem_ave

        settings = {
            "u":   {"min": -1.0, "max": 1.0, "cmap": "jet", "label": r"$u^{*}$", "scale": U_ref, "offset": 0.0, "step": 0.5},
            "v":   {"min": -1.0, "max": 1.0, "cmap": "jet", "label": r"$v^{*}$", "scale": U_ref, "offset": 0.0, "step": 0.5},
            "pre": {"min": -0.5, "max": 0.5, "cmap": "jet", "label": r"$p^{*}$", "scale": P_ref, "offset": 0.0, "step": 0.25},
            "tem": {"min": -0.5, "max": 0.5, "cmap": "jet", "label": r"$T^{*}$", "scale": T_ref, "offset": T_ave, "step": 0.25},
        }

    return settings