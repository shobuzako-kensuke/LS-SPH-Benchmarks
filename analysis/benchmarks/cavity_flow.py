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
    print("      Analyzing Lid-driven Cavity Flow : Progress...", end="", flush=True)

    # ======================================================================== #
    #   1. Setup parameters
    # ======================================================================== #
    Lx    = param.len_x
    Ly    = param.len_y
    U_top = param.u_top
    rho   = param.rho_ref
    nu    = param.kinematic_vis
    Re    = int(param.Re)

    # Get settings from visualizer
    domain_set = visualizer.get_domain_settings(param)
    time_set   = visualizer.get_time_settings(param)
    L_ref      = domain_set["L_ref"]

    # ======================================================================== #
    #   2. Load the reference data of Ghia et al. (1982)
    # ======================================================================== #
    ref_file_name = f"Ghia_1982_Re_{Re}.csv"
    ref_path = Path("analysis/benchmarks") / ref_file_name

    if ref_path.exists():
        ref_data = np.loadtxt(ref_path, delimiter=",", skiprows=1)
        
        # Assuming CSV format: [y, u, x, v]
        # Redimensionalize all values
        ref_y = ref_data[:, 0] * Ly
        ref_u = ref_data[:, 1] * U_top
        ref_x = ref_data[:, 2] * Lx
        ref_v = ref_data[:, 3] * U_top

    else:
        print(f"\n      [Warning] Reference data '{ref_file_name}' not found. Comparison will be skipped.")

    # ======================================================================== #
    #   3. Find data files and initialize arrays
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

    # ======================================================================== #
    #   4. Loop over all files to calculate V_rms history
    # ======================================================================== #
    for i, file_path in enumerate(step_files):
        step = int(file_path.stem)
        time_array[i] = (step * param.dt)

        # Read the data
        sim_data = read_utils.step_data(file_path, param)
        
        # Calculate V_rms using only the internal fluid particles
        u_int = sim_data.u[:param.num_int]
        v_int = sim_data.v[:param.num_int]
        
        Vrms_history[i] = np.sqrt(np.mean(u_int**2 + v_int**2))

    # ======================================================================== #
    #   5. Calculate velocity profiles at the final step using LS-SPH
    # ======================================================================== #
    # Read the data
    final_file = step_files[-1]
    final_step = int(final_file.stem)
    sim_data   = read_utils.step_data(final_file, param)

    x_all = sim_data.x[:param.num_total] - param.WL_thick  # Apply wall offset
    y_all = sim_data.y[:param.num_total] - param.WL_thick
    u_all = sim_data.u[:param.num_total]
    v_all = sim_data.v[:param.num_total]
    rho_all = sim_data.rho[:param.num_total]

    # (A) Interpolate the velocity profiles using the LS-SPH Type B
    Nx = param.num_x
    Ny = param.num_y

    # Target points for U-velocity along Y-axis at x = Lx / 2
    target_x_u = np.full(Ny, Lx / 2.0)
    target_y_u = np.linspace(0.0, Ly, Ny)

    # Target points for V-velocity along X-axis at y = Lx / 2
    target_x_v = np.linspace(0.0, Lx, Nx)
    target_y_v = np.full(Nx, Ly / 2.0)

    if param.wall_model <= 3:
        u_prof = lssph_b.main(param, target_x_u, target_y_u, x_all, y_all, u_all, rho_all)[:, 0]
        v_prof = lssph_b.main(param, target_x_v, target_y_v, x_all, y_all, v_all, rho_all)[:, 0]

    # (B) Interpolate exactly at Ghia's coordinates for error norms
    if ref_path.exists():
        u_eval = lssph_b.main(param, np.full_like(ref_y, Lx / 2.0), ref_y, x_all, y_all, u_all, rho_all)[:, 0]
        v_eval = lssph_b.main(param, ref_x, np.full_like(ref_x, Ly / 2.0), x_all, y_all, v_all, rho_all)[:, 0]
        
        # Calculate normalized absolute errors 
        abs_err_u = np.abs(u_eval - ref_u) / U_top
        abs_err_v = np.abs(v_eval - ref_v) / U_top
        
        L1_u   = np.mean(abs_err_u)
        L2_u   = np.sqrt(np.mean(abs_err_u**2))
        Linf_u = np.max(abs_err_u)
        
        L1_v   = np.mean(abs_err_v)
        L2_v   = np.sqrt(np.mean(abs_err_v**2))
        Linf_v = np.max(abs_err_v)

    # ======================================================================== #
    #   6. Plot Figure 1: V_rms History
    # ======================================================================== #
    save_dir = base_dir / "figures" / "analysis"
    save_dir.mkdir(parents=True, exist_ok=True)

    fig1 = plt.figure(figsize=(6, 4.5), facecolor="white", constrained_layout=True)
    ax1  = fig1.add_subplot(111, facecolor="white")
    
    ax1.plot(time_array/time_set["scale"], Vrms_history/U_top, "k-", linewidth=1.5)
    ax1.set_xlabel(r"$t^{*}$")
    ax1.set_ylabel(r"$V_{\mathrm{rms}}^{*}$")
    ax1.set_title(r"Root Mean Square Velocity History", fontsize=10)
    ax1.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)
    
    fig1.savefig(save_dir / "history_Vrms.png", format="png", dpi=300)
    fig1.savefig(save_dir / "history_Vrms.pdf", format="pdf")
    plt.close(fig1)

    # ======================================================================== #
    #   7. Plot Figure 2: Velocity Profiles (Comparison)
    # ======================================================================== #
    fig2, axes2 = plt.subplots(1, 2, figsize=(10, 4.5), facecolor="white", constrained_layout=True)

    # Plot u vs y
    ax = axes2[0]
    ax.plot(u_prof/U_top, target_y_u/L_ref, "r-", linewidth=1.5, label="SPH")
    if ref_path.exists():
        ax.plot(ref_u/U_top, ref_y/L_ref, "ks", markersize=4, label="Ghia et al. (1982)")
    ax.set_xlabel(r"$u^{*}$")
    ax.set_ylabel(r"$y^{*}$")
    ax.set_title(rf"$u$-velocity along $x = L_x/2$", fontsize=10)
    ax.legend(frameon=True, fancybox=True, edgecolor="silver")
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    # Plot v vs x
    ax = axes2[1]
    ax.plot(target_x_v/L_ref, v_prof/U_top, "r-", linewidth=1.5, label="SPH")
    if ref_path.exists():
        ax.plot(ref_x/L_ref, ref_v/U_top, "ks", markersize=4, label="Ghia et al. (1982)")
    ax.set_xlabel(r"$x^{*}$")
    ax.set_ylabel(r"$v^{*}$")
    ax.set_title(rf"$v$-velocity along $y = L_y/2$", fontsize=10)
    ax.legend(frameon=True, fancybox=True, edgecolor="silver")
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.7)

    # Title for error norms if reference is available
    if ref_path.exists():
        fig2.suptitle(f"Step: {final_step:,},  Re: {Re}\n"
                      f"u-Error   $L_1$: {L1_u:.3e}  $L_2$: {L2_u:.3e}  $L_\\infty$: {Linf_u:.3e}\n"
                      f"v-Error   $L_1$: {L1_v:.3e}  $L_2$: {L2_v:.3e}  $L_\\infty$: {Linf_v:.3e}", 
                      fontsize=10)

    fig2.savefig(save_dir / "velocity_profiles.png", format="png", dpi=300)
    fig2.savefig(save_dir / "velocity_profiles.pdf", format="pdf")
    plt.close(fig2)

    # ======================================================================== #
    #   8. Save the comparative data to CSV
    # ======================================================================== #
    if ref_path.exists():
        csv_path = save_dir / "profile_comparison.csv"
        with open(csv_path, mode="w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["y", "u_SPH", "u_Ghia", "x", "v_SPH", "v_Ghia"])
            
            for i in range(len(ref_y)):

                # Normalize all values
                ref_y_normal  = ref_y [i] / L_ref
                ref_x_normal  = ref_x [i] / L_ref
                ref_u_normal  = ref_u [i] / U_top
                ref_v_normal  = ref_v [i] / U_top
                u_eval_normal = u_eval[i] / U_top
                v_eval_normal = v_eval[i] / U_top

                writer.writerow([
                    f"{ref_y_normal:.14e}", f"{u_eval_normal:.14e}", f"{ref_u_normal:.14e}",
                    f"{ref_x_normal:.14e}", f"{v_eval_normal:.14e}", f"{ref_v_normal:.14e}"
                ])
                
    print("\r      Analyzing Lid-driven Cavity Flow : Completed    ")