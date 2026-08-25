# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#               This module analyzes the Diffusion Equation Test.              #
#                                                                              #
# ============================================================================ #

import csv
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors
from pathlib import Path
from types import SimpleNamespace
from matplotlib.ticker import MultipleLocator
from analysis.common import read_utils, visualizer

def main(base_dir: Path, param: SimpleNamespace):
    print("      Analyzing Diffusion Equation Test : Progress...", end="", flush=True)

    # ======================================================================== #
    #   1. Find the steady-state (last) data file
    # ======================================================================== #
    data_dir = base_dir / "data"
    
    # Collect all .dat files
    all_dat_files = list(data_dir.glob("*.dat"))

    # Filter out VM.dat or cell_idx.dat if they exist, keeping only numerical ones
    step_files = [f for f in all_dat_files if f.stem.isdigit()]
    
    if not step_files:
        print("\n      [Error] No simulation data found.")
        return

    # Find the steady-state (last) file
    last_file   = max(step_files, key=lambda x: int(x.stem))
    steady_step = int(last_file.stem)

    # Read the data
    sim_data = read_utils.step_data(last_file, param)
    num_int  = param.num_int

    # ======================================================================== #
    #   2. Calculate exact solution and errors
    # ======================================================================== #
    # Apply wall offset to extract internal particle coordinates
    x_int = sim_data.x[:num_int] - param.WL_thick
    y_int = sim_data.y[:num_int] - param.WL_thick

    # Numerical solution (SPH)
    u_sph = sim_data.u[:num_int]

    # Exact solution: u(x,y) = sin(pi*x) * cos(pi*y)
    u_exact = np.sin(np.pi * x_int) * np.cos(np.pi * y_int)

    # Absolute error
    abs_error = np.abs(u_sph - u_exact)

    # Calculate error norms
    L1_error   = np.mean(abs_error)
    L2_error   = np.sqrt(np.mean(abs_error**2))
    Linf_error = np.max(abs_error)

    # ======================================================================== #
    #   3. Figure Setup (1x3 Layout)
    # ======================================================================== #
    # Use visualizer settings
    plot_settings = visualizer.get_plot_settings(param)
    domain_set    = visualizer.get_domain_settings(param)
    sca_size      = visualizer.get_scatter_size(num_int, with_wall=False)
    
    my_set = plot_settings["u"]

    # Scaled coordinates
    x_plot = x_int / domain_set["L_ref"]
    y_plot = y_int / domain_set["L_ref"]

    # Create figure
    fig, axes = plt.subplots(1, 3, figsize=(13.5, 4.5), facecolor="white", constrained_layout=True)
    
    # Title showing the error norms
    fig.suptitle(rf"Step: {steady_step:,}    "
                 rf"$L_1$: {L1_error:.3e}    "
                 rf"$L_2$: {L2_error:.3e}    "
                 rf"$L_\infty$: {Linf_error:.3e}",
                 fontsize=14)

    # Arrays and titles for the first two plots
    plot_data   = [u_exact, u_sph]
    plot_titles = ["Exact Solution", "SPH Solution"]

    # ======================================================================== #
    #   4. Plot Exact and SPH Solutions
    # ======================================================================== #
    for i in range(2):
        ax = axes[i]
        ax.set_aspect("equal")
        ax.set_xlim(domain_set["x_min"], domain_set["x_max"])
        ax.set_ylim(domain_set["y_min"], domain_set["y_max"])
        ax.xaxis.set_major_locator(MultipleLocator(domain_set["x_step"]))
        ax.yaxis.set_major_locator(MultipleLocator(domain_set["y_step"]))

        val_scaled = (plot_data[i] - my_set["offset"]) / my_set["scale"]

        cfig = ax.scatter(x_plot, y_plot, c=val_scaled,
                          cmap=my_set["cmap"], ec="none", marker=".",
                          vmin=my_set["min"], vmax=my_set["max"], s=sca_size)
        
        cbar = fig.colorbar(cfig, ax=ax, orientation="vertical", shrink=0.6,
                            ticks=MultipleLocator(my_set["step"]))
        cbar.set_label(my_set["label"])
        
        ax.set_xlabel(domain_set["x_label"])
        if i == 0:
            ax.set_ylabel(domain_set["y_label"])
        ax.set_title(plot_titles[i], fontsize=10)

    # ======================================================================== #
    #   5. Plot Absolute Error (Logarithmic Scale)
    # ======================================================================== #
    ax = axes[2]
    ax.set_aspect("equal")
    ax.set_xlim(domain_set["x_min"], domain_set["x_max"])
    ax.set_ylim(domain_set["y_min"], domain_set["y_max"])
    ax.xaxis.set_major_locator(MultipleLocator(domain_set["x_step"]))
    ax.yaxis.set_major_locator(MultipleLocator(domain_set["y_step"]))

    # Dynamic logarithmic scale setup (avoiding log(0) issues)
    err_min = max(np.min(abs_error), 1e-12)  # Floor to 1e-12
    err_max = max(Linf_error, 1e-10)         # Ceiling minimum to 1e-10

    cfig_err = ax.scatter(x_plot, y_plot, c=abs_error,
                          cmap="binary", ec="none", marker=".", s=sca_size,
                          norm=colors.LogNorm(vmin=err_min, vmax=err_max))
    
    cbar_err = fig.colorbar(cfig_err, ax=ax, orientation="vertical", shrink=0.6)
    cbar_err.set_label("Absolute Error")
    
    ax.set_xlabel(domain_set["x_label"])
    ax.set_title("Absolute Error", fontsize=10)

    # ======================================================================== #
    #   6. Save the figure and output error norms to CSV
    # ======================================================================== #
    # Save figures
    save_dir  = base_dir / "figures" / "analysis"
    save_dir.mkdir(parents=True, exist_ok=True)

    save_path = save_dir / "diffusion_test.png"
    fig.savefig(save_path, format="png", dpi=300, transparent=False)

    save_path = save_dir / "diffusion_test.pdf"
    fig.savefig(save_path, format="pdf")
    
    plt.close(fig)

    # Save error norms to CSV
    csv_path = save_dir / "error_norms.csv"
    with open(csv_path, mode="w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Parameter", "Value"])
        writer.writerow(["dx", f"{param.dx:.14e}"])
        writer.writerow(["L1_error", f"{L1_error:.14e}"])
        writer.writerow(["L2_error", f"{L2_error:.14e}"])
        writer.writerow(["Linf_error", f"{Linf_error:.14e}"])

    print("\r      Analyzing Diffusion Equation Test : Completed    ")