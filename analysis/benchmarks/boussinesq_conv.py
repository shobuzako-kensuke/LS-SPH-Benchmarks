# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#               This module analyzes the Lid-driven Cavity Flow.               #
#                                                                              #
# ============================================================================ #

import csv
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from types import SimpleNamespace
from analysis.common import read_utils, visualizer, lssph_b

def main(base_dir: Path, param: SimpleNamespace):
    print("      Analyzing Boussinesq Convection : Progress...", end="", flush=True)

    # ======================================================================== #
    #   1. Setup parameters
    # ======================================================================== #
    Lx = param.len_x
    Ly = param.len_y
    
    # Effective sound speed
    # Considering Reduced Speed of Sound Technique (RSST) and Variable Inertia Method (VIM)
    c_eff = param.sound_speed / (param.zeta_RSST * param.xi_VIM)

    # Get settings from visualizer
    domain_set = visualizer.get_domain_settings(param)
    time_set   = visualizer.get_time_settings(param)
    plot_set   = visualizer.get_plot_settings(param)
    
    L_ref   = domain_set["L_ref"]
    U_scale = plot_set["u"]["scale"]
    t_scale = time_set["scale"]

    # ======================================================================== #
    #   2. Find data files and initialize arrays
    # ======================================================================== #
    data_dir = base_dir / "data"
    all_dat_files = list(data_dir.glob("*.dat"))
    step_files = sorted([f for f in all_dat_files if f.stem.isdigit()], key=lambda x: int(x.stem))
    
    if not step_files:
        print("\n      [Error] No simulation data found.")
        return

    num_files    = len(step_files)
    time_array   = np.zeros(num_files)
    Vrms_history = np.zeros(num_files)
    Mach_history = np.zeros(num_files)

    # ======================================================================== #
    #   3. Loop over all files to calculate V_rms and Mach number history
    # ======================================================================== #
    for i, file_path in enumerate(step_files):
        step = int(file_path.stem)
        time_array[i] = (step * param.dt)

        # Read the data
        sim_data = read_utils.step_data(file_path, param)
        
        # Calculate V_rms and V_max using only the internal fluid particles
        u_int = sim_data.u[:param.num_int]
        v_int = sim_data.v[:param.num_int]
        
        speed_sq = u_int**2 + v_int**2
        Vrms_history[i] = np.sqrt(np.mean(speed_sq))
        Vmax            = np.sqrt(np.max(speed_sq))
        
        # Calculate Mach number
        Mach_history[i] = Vmax / c_eff

    # ======================================================================== #
    #   4. Calculate Nusselt number at the final step using LS-SPH
    # ======================================================================== #
    final_file = step_files[-1]
    final_step = int(final_file.stem)
    sim_data   = read_utils.step_data(final_file, param)

    x_all   = sim_data.x  [:param.num_total] - param.WL_thick  # Apply wall offset
    y_all   = sim_data.y  [:param.num_total] - param.WL_thick
    tem_all = sim_data.tem[:param.num_total]
    rho_all = sim_data.rho[:param.num_total]

    Nx = param.num_x
    
    # Target points on the physical boundaries
    target_x     = np.linspace(0.0, Lx, Nx)
    target_y_bot = np.zeros(Nx)
    target_y_top = np.full(Nx, Ly)

    # LS-SPH Interpolation ([:, 2] extracts the y-derivative: dT/dy)
    dTdy_bot = lssph_b.main(param, target_x, target_y_bot, x_all, y_all, tem_all, rho_all)[:, 2]
    dTdy_top = lssph_b.main(param, target_x, target_y_top, x_all, y_all, tem_all, rho_all)[:, 2]

    # Calculate local Nusselt numbers
    grad_ref = - param.delta_tem / param.len_y
    Nu_bot = dTdy_bot / grad_ref
    Nu_top = dTdy_top / grad_ref

    Nu_bot_ave = np.mean(Nu_bot)
    Nu_top_ave = np.mean(Nu_top)
    
    # Calculate Energy Balance Error (%)
    Nu_err = np.abs(Nu_bot_ave - Nu_top_ave) / np.abs(Nu_bot_ave) * 100.0

    # ======================================================================== #
    #   5. Plot Figure 1: V_rms and Mach History
    # ======================================================================== #
    save_dir = base_dir / "figures" / "analysis"
    save_dir.mkdir(parents=True, exist_ok=True)

    fig1, axes1 = plt.subplots(1, 2, figsize=(10, 4.5), facecolor="white", constrained_layout=True)
    
    t_normal    = time_array   / t_scale
    Vrms_normal = Vrms_history / U_scale

    # Plot V_rms
    ax = axes1[0]
    ax.plot(t_normal, Vrms_normal, "k-", linewidth=1.5)
    ax.set_xlabel(r"$t^{*}$")
    ax.set_ylabel(r"$V_{\mathrm{rms}}^{*}$")
    ax.set_title(rf"Final $V_{{\mathrm{{rms}}}}^{{*}}$ = {Vrms_normal[-1]:.3e}", fontsize=10)
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    # Plot Mach Number
    ax = axes1[1]
    ax.plot(t_normal, Mach_history, "k-", linewidth=1.5)
    ax.axhline(y=0.1, color="r", linestyle="--", linewidth=1.5, label=r"$\mathit{Ma}$ = 0.1")
    ax.set_xlabel(r"$t^{*}$")
    ax.set_ylabel(r"$\mathit{Ma}$")
    ax.set_title(rf"Maximum Mach Number = {np.max(Mach_history):.3e}", fontsize=10)
    ax.legend(frameon=True, fancybox=True, edgecolor="silver")
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    fig1.savefig(save_dir / "history_Vrms_Mach.png", format="png", dpi=300)
    fig1.savefig(save_dir / "history_Vrms_Mach.pdf", format="pdf")
    plt.close(fig1)

    # ======================================================================== #
    #   6. Plot Figure 2: Nusselt Number Profiles
    # ======================================================================== #
    fig2, axes2 = plt.subplots(1, 2, figsize=(10, 4.5), facecolor="white", constrained_layout=True)
    x_normal    = target_x / L_ref

    # Plot Nu Bottom
    ax = axes2[0]
    ax.plot(x_normal, Nu_bot, "r-", linewidth=1.5)
    ax.set_xlabel(r"$x^{*}$")
    ax.set_ylabel(r"$\mathit{Nu}$")
    ax.set_title("Bottom Wall", fontsize=11)
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    # Plot Nu Top
    ax = axes2[1]
    ax.plot(x_normal, Nu_top, "r-", linewidth=1.5)
    ax.set_xlabel(r"$x^{*}$")
    ax.set_ylabel(r"$\mathit{Nu}$")
    ax.set_title("Top Wall", fontsize=10)
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    fig2.suptitle(f"Nusselt Number at Step: {final_step:,}  (Ra: {param.Ra:.1e}, Pr: {param.Pr:.1e})\n"
                  f"Bottom Ave: {Nu_bot_ave:.3f}   Top Ave: {Nu_top_ave:.3f}   Error: {Nu_err:.2f} %", 
                  fontsize=10)

    fig2.savefig(save_dir / "nusselt_profiles.png", format="png", dpi=300)
    fig2.savefig(save_dir / "nusselt_profiles.pdf", format="pdf")
    plt.close(fig2)

    # ======================================================================== #
    #   7. Save the steady-state results to CSV
    # ======================================================================== #
    csv_path = save_dir / "steady_state_results.csv"
    with open(csv_path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Parameter", "Value"])
        writer.writerow(["Final_Vrms_star",  f"{Vrms_normal[-1]:.14e}"])
        writer.writerow(["Max_Mach_Number",  f"{np.max(Mach_history):.14e}"])
        writer.writerow(["Nu_bottom_ave",    f"{Nu_bot_ave:.14e}"])
        writer.writerow(["Nu_top_ave",       f"{Nu_top_ave:.14e}"])
        writer.writerow(["Nu_Error_percent", f"{Nu_err:.4f}"])

    print("\r      Analyzing Boussinesq Convection : Completed       ")