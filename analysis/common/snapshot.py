# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#      This module generates sequential snapshots of the physical fields.      #
#                                                                              #
# ============================================================================ #

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from types import SimpleNamespace
from matplotlib.ticker import MultipleLocator
from analysis.common import read_utils, visualizer

# ============================================================================ #
#   Generate sequential snapshot figures
# ============================================================================ #
def generate_snapshots(base_dir: Path, param: SimpleNamespace):

    # Simulation step settings
    start = param.start_step
    end   = param.total_step
    step  = param.write_step

    # Get plot, domain, and time settings
    plot_settings = visualizer.get_plot_settings(param)
    domain_set    = visualizer.get_domain_settings(param)
    time_set      = visualizer.get_time_settings(param)

    # Get scatter marker size
    num_int  = param.num_int
    sca_size = visualizer.get_scatter_size(num_int, with_wall=False)

    # Generate the list of saved steps, closely matching Fortran's output logic
    # Example 1 (start=1 , step=10, end=100) -> [0, 1, 10, 20, ..., 100]
    # Example 2 (start=15, step=10, end=100) -> [0, 15, 25, ..., 95]
    if start == 1:
        saved_step = [0] + [i for i in range(step , end + 1, step)]  # For fresh start
    else:
        saved_step = [0] + [i for i in range(start, end + 1, step)]  # For restart

    # Setup for progress percentage
    count = 0
    total_files = len(saved_step)

    print("      Generating snapshots : Progress...", end="", flush=True)

    # Loop over the saved steps
    for i in saved_step:
        file_path = base_dir / "data" / f"{i}.dat"
        if not file_path.exists():
            continue
            
        # Read the target step data
        sim_data = read_utils.step_data(file_path, param)

        # Calculate current time
        current_time = (i * param.dt) / time_set["scale"]
        
        # Apply wall offset and scaling to the coordinates
        x_plot = (sim_data.x[:num_int] - param.WL_thick) / domain_set["L_ref"]
        y_plot = (sim_data.y[:num_int] - param.WL_thick) / domain_set["L_ref"]

        # Generate a figure for each physical quantity
        for key, val in vars(sim_data).items():
            if key not in plot_settings:
                continue

            my_set = plot_settings[key]
            val_plot = val[:num_int]
            val_scaled = (val_plot - my_set["offset"]) / my_set["scale"]

            # Figure setup
            fig = plt.figure(figsize=(4.5,4), facecolor="white", constrained_layout=True)
            ax  = fig.add_subplot(111, facecolor="white")
            ax.set_aspect("equal")

            # Set the domain
            ax.set_xlim(domain_set["x_min"], domain_set["x_max"])
            ax.set_ylim(domain_set["y_min"], domain_set["y_max"])
            ax.xaxis.set_major_locator(MultipleLocator(domain_set["x_step"]))
            ax.yaxis.set_major_locator(MultipleLocator(domain_set["y_step"]))

            # Scatter Plot
            cfig = ax.scatter(x_plot, y_plot, c=val_scaled,
                              cmap=my_set["cmap"], ec="none", marker=".",
                              vmin=my_set["min"], vmax=my_set["max"], s=sca_size)
            cbar = fig.colorbar(cfig, ax=ax, orientation="vertical", shrink=0.6,
                                ticks=MultipleLocator(my_set["step"]))
            cbar.set_label(my_set["label"])
            
            # Axis labels
            ax.set_xlabel(domain_set["x_label"])
            ax.set_ylabel(domain_set["y_label"])

            # Title
            ax.set_title(f"Step: {i:,}    {time_set['label']}: {current_time:.2e}")

            # Save the figure
            save_dir  = base_dir / "figures" / f"snapshots_{key}"
            save_dir.mkdir(parents=True, exist_ok=True)
            
            save_path = save_dir / f"{i}.png"
            fig.savefig(save_path, format="png", dpi=300, transparent=False)
            plt.close(fig)
            
        # Display progress
        count += 1
        print(f"\r      Generating snapshots: {count/total_files*100:.1f} %       ", end="", flush=True)
    
    print( "\r      Generating snapshots : Completed   ")