# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#              This module analyzes the Taylor-Green Vortex.                   #
#                                                                              #
# ============================================================================ #

import csv
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from types import SimpleNamespace
from analysis.common import read_utils, visualizer, lssph_b

def main(base_dir: Path, param: SimpleNamespace):
    print("      Analyzing Taylor-Green Vortex : Progress...", end="", flush=True)

    # ======================================================================== #
    #   1. Setup parameters
    # ======================================================================== #
    Lx  = param.len_x
    Ly  = param.len_y
    a   = param.tg_a
    b   = param.tg_b
    nu  = param.kinematic_vis
    rho = param.rho_ref
    A_0 = 1.0  # Initial velocity amplitude

    # Decay rate (sigma) and ratio
    sigma = nu * ((a * np.pi / Lx)**2 + (b * np.pi / Ly)**2)
    ratio = ((a / Lx) / (b / Ly))

    # Get settings from visualizer
    domain_set = visualizer.get_domain_settings(param)
    time_set   = visualizer.get_time_settings(param)
    L_ref      = domain_set["L_ref"]

    # ======================================================================== #
    #   2. Find data files and initialize arrays
    # ======================================================================== #
    data_dir = base_dir / "data"
    all_dat_files = list(data_dir.glob("*.dat"))
    step_files = sorted([f for f in all_dat_files if f.stem.isdigit()], key=lambda x: int(x.stem))
    
    if not step_files:
        print("\n      [Error] No simulation data found.")
        return

    num_files  = len(step_files)
    time_array = np.zeros(num_files)
    Ek_history = np.zeros(num_files)
    Pc_history = np.zeros(num_files)

    # Target point for center pressure
    xc = np.array([Lx / 2.0])
    yc = np.array([Ly / 2.0])

    # ======================================================================== #
    #   3. Loop over all files to calculate the energy and pressure histories
    # ======================================================================== #
    for i, file_path in enumerate(step_files):
        step = int(file_path.stem)
        time_array[i] = (step * param.dt)

        # Read the data
        sim_data = read_utils.step_data(file_path, param)
        
        # (A) Specific Kinetic Energy using only the internal particles
        u_int = sim_data.u[:param.num_int]
        v_int = sim_data.v[:param.num_int]
        Ek_history[i] = 0.5 * np.mean(u_int**2 + v_int**2)

        # (B) Center Pressure interpolated using LS-SPH Type B
        x_all   = sim_data.x  [:param.num_total] - param.WL_thick  # Apply wall offset
        y_all   = sim_data.y  [:param.num_total] - param.WL_thick
        pre_all = sim_data.pre[:param.num_total]
        rho_all = sim_data.rho[:param.num_total]
        
        Pc = lssph_b.main(param, xc, yc, x_all, y_all, pre_all, rho_all)
        Pc_history[i] = Pc[0, 0]

    # ======================================================================== #
    #   4. Calculate the velocity profiles at the final step using LS-SPH
    # ======================================================================== #
    # Number of the calculation points 
    Nx = param.num_x
    Ny = param.num_y

    # Target points for U-velocity along Y-axis at x = Lx / (2a)
    target_x_u = np.full(Ny, Lx / (2.0*a))
    target_y_u = np.linspace(0.0, Ly, Ny)

    # Target points for V-velocity along X-axis at y = Ly / (2b)
    target_x_v = np.linspace(0.0, Lx, Nx)
    target_y_v = np.full(Nx, Ly / (2.0*b))

    # Interpolate the velocity profiles using the LS-SPH Type B
    if param.wall_model <= 3:
        u_all = sim_data.u[:param.num_total]
        v_all = sim_data.v[:param.num_total]
        u_prof = lssph_b.main(param, target_x_u, target_y_u, x_all, y_all, u_all, rho_all)[:, 0]
        v_prof = lssph_b.main(param, target_x_v, target_y_v, x_all, y_all, v_all, rho_all)[:, 0]

    # ======================================================================== #
    #   5. Analytical Solutions
    # ======================================================================== #
    # Time history exact solutions
    A_t = A_0 * np.exp(- sigma * time_array)

    # Exact kinetic energy and pressure histories
    Ek_exact = (A_t**2 / 8.0) * (1.0 + ratio**2)
    Pc_exact = (rho * A_t**2 / 4.0) * (np.cos(a * np.pi) + (ratio**2) * np.cos(b * np.pi))

    # Exact velocity profiles at final time
    A_t_final = A_t[-1]
    
    u_exact =  A_t_final         * np.sin(a * np.pi * target_x_u / Lx) * np.cos(b * np.pi * target_y_u / Ly)
    v_exact = -A_t_final * ratio * np.cos(a * np.pi * target_x_v / Lx) * np.sin(b * np.pi * target_y_v / Ly)

    # ======================================================================== #
    #   6. Plot Figure 1: Energy & Pressure Histories
    # ======================================================================== #
    save_dir  = base_dir / "figures" / "analysis"
    save_dir.mkdir(parents=True, exist_ok=True)

    fig1, axes1 = plt.subplots(1, 2, figsize=(10, 4.5), facecolor="white", constrained_layout=True)

    t_normal = time_array / time_set["scale"]

    # Plot normalized kinetic energy
    ax = axes1[0]
    ax.plot(t_normal, Ek_history/A_0**2, "ro", markersize=4, label="SPH")
    ax.plot(t_normal, Ek_exact  /A_0**2, "k-", linewidth=1.5, label="Exact")
    ax.set_xlabel(r"$t^{*}$")
    ax.set_ylabel(r"$E_k^{*}$")
    ax.set_title("Kinetic Energy Decay")
    ax.legend(frameon=True, fancybox=True, edgecolor="silver")
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    # Plot normalized center pressure
    ax = axes1[1]
    ax.plot(t_normal, Pc_history/(rho*A_0**2), "ro", markersize=4, label="SPH")
    ax.plot(t_normal, Pc_exact  /(rho*A_0**2), "k-", linewidth=1.5, label="Exact")
    ax.set_xlabel(r"$t^{*}$")
    ax.set_ylabel(r"$p^{*}$")
    ax.set_title(f"Pressure History at Center")
    ax.legend(frameon=True, fancybox=True, edgecolor="silver")
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    fig1.savefig(save_dir / "history_EK_and_P.png", format="png", dpi=300)
    fig1.savefig(save_dir / "history_EK_and_P.pdf", format="pdf")
    plt.close(fig1)

    # ======================================================================== #
    #   7. Plot Figure 2: Velocity Profiles
    # ======================================================================== #
    fig2, axes2 = plt.subplots(1, 2, figsize=(10, 4.5), facecolor="white", constrained_layout=True)

    # Plot u vs y
    ax = axes2[0]
    ax.plot(u_prof /A_0, target_y_u/L_ref, "ro", markersize=4, label="SPH")
    ax.plot(u_exact/A_0, target_y_u/L_ref, "k-", linewidth=1.5, label="Exact")
    ax.set_xlabel(r"$u^{*}$")
    ax.set_ylabel(r"$y^{*}$")
    ax.set_title(rf"$u$-velocity along $x = L_x/{int(2*a)}$")
    ax.legend(frameon=True, fancybox=True, edgecolor="silver")
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    # Plot v vs x
    ax = axes2[1]
    ax.plot(target_x_v/L_ref, v_prof /A_0, "ro", markersize=4, label="SPH")
    ax.plot(target_x_v/L_ref, v_exact/A_0, "k-", linewidth=1.5, label="Exact")
    ax.set_xlabel(r"$x^{*}$")
    ax.set_ylabel(r"$v^{*}$")
    ax.set_title(rf"$v$-velocity along $y = L_y/{int(2*b)}$")
    ax.legend(frameon=True, fancybox=True, edgecolor="silver")
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    fig2.savefig(save_dir / "velocity_profiles.png", format="png", dpi=300)
    fig2.savefig(save_dir / "velocity_profiles.pdf", format="pdf")
    plt.close(fig2)

    # ======================================================================== #
    #   8. Save the normalized history data to CSV
    # ======================================================================== #
    csv_path = save_dir / "history_data.csv"
    with open(csv_path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Time", "Ek_SPH", "Ek_Exact", "Pc_SPH", "Pc_Exact"])

        for i in range(num_files):

            # Normalize all values
            time_normal  = time_array[i] / time_set["scale"]
            Ek_normal    = Ek_history[i] / A_0**2
            Ek_normal_ex = Ek_exact  [i] / A_0**2
            Pc_normal    = Pc_history[i] / (rho * A_0**2)
            Pc_normal_ex = Pc_exact  [i] / (rho * A_0**2)

            writer.writerow([f"{time_normal:.14e}", 
                             f"{Ek_normal  :.14e}", f"{Ek_normal_ex:.14e}",
                             f"{Pc_normal  :.14e}", f"{Pc_normal_ex:.14e}"])

    print("\r      Analyzing Taylor-Green Vortex : Completed     ")