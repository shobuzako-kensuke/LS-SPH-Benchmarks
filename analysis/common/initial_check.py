# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#            This module generates figures to check the initial state.         #
#                                                                              #
# ============================================================================ #

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from types import SimpleNamespace
from matplotlib.ticker import MultipleLocator
from analysis.common import read_utils, visualizer

# ============================================================================ #
#   Plot the initial particle data
# ============================================================================ #
def plot_particles(base_dir: Path, param: SimpleNamespace, with_wall: bool):

    # Create the save directory
    save_dir = base_dir / "figures" / "initial_settings"
    save_dir.mkdir(parents=True, exist_ok=True)

    # Read the initial particle data
    file_path = base_dir / "data" / "0.dat"
    sim_data  = read_utils.step_data(file_path, param)

    # Get scatter marker size
    num_int  = param.num_int
    sca_size = visualizer.get_scatter_size(num_int, with_wall)

    # Get plot domain, and time settings
    plot_settings = visualizer.get_plot_settings(param)
    domain_set    = visualizer.get_domain_settings(param)
    time_set      = visualizer.get_time_settings(param)

    # Slice arrays up to the target index
    slice_idx = param.num_total if with_wall else num_int

    # Apply wall offset to the target particle coordinates
    x_plot = (sim_data.x[:slice_idx] - param.WL_thick) / domain_set["L_ref"]
    y_plot = (sim_data.y[:slice_idx] - param.WL_thick) / domain_set["L_ref"]

    # Scatter Plot
    for key, val in vars(sim_data).items():
        if key in ["x", "y", "rho"]:
            continue
        
        # Slice arrays up to the target index
        val_plot = val[:slice_idx]

        # Figure setup
        fig = plt.figure(figsize=(4.5,4), facecolor="white", constrained_layout=True)
        ax  = fig.add_subplot(111, facecolor="white")

        # Set equal aspect ratio for the spatial axes
        ax.set_aspect("equal")

        # Set the domain
        wall_margin_x = (param.WL_thick / domain_set["L_ref"]) if with_wall else 0.0
        wall_margin_y = (param.WL_thick / domain_set["L_ref"]) if with_wall else 0.0
        ax.set_xlim(domain_set["x_min"] - wall_margin_x, domain_set["x_max"] + wall_margin_x)
        ax.set_ylim(domain_set["y_min"] - wall_margin_y, domain_set["y_max"] + wall_margin_y)
        ax.xaxis.set_major_locator(MultipleLocator(domain_set["x_step"]))
        ax.yaxis.set_major_locator(MultipleLocator(domain_set["y_step"]))

        # Generate a figure for each physical quantity
        if (key == "ptype"):
            cfig = ax.scatter(x_plot, y_plot, c=val_plot,
                              cmap="tab10", ec="none", marker=".",
                              vmin=0, vmax=8, s=sca_size)
            cbar = fig.colorbar(cfig, ax=ax, ticks=range(9), orientation="vertical", shrink=0.7)
            cbar.set_label("Particle Type")
        
        else:
            if key not in plot_settings:
                plt.close(fig)
                continue

            # Get the settings for the specific physical quantity (e.g., u, v, pre)
            my_set = plot_settings[key]

            # Scaling
            val_scaled = (val_plot - my_set["offset"]) / my_set["scale"]

            cfig = ax.scatter(x_plot, y_plot, c=val_scaled,
                              cmap=my_set["cmap"], ec="none", marker=".",
                              vmin=my_set["min"], vmax=my_set["max"], s=sca_size)
            cbar = fig.colorbar(cfig, ax=ax, orientation="vertical", shrink=0.6,
                                ticks=MultipleLocator(my_set["step"]))
            cbar.set_label(my_set["label"])
            
        # Axis labels
        ax.set_xlabel(domain_set["x_label"])
        ax.set_ylabel(domain_set["y_label"])

        # Draw the physical boundary
        if with_wall:
            ax.vlines(x=[domain_set["x_min"], domain_set["x_max"]], ymin=domain_set["y_min"], ymax=domain_set["y_max"], color='k', linestyle='--', linewidth=1)
            ax.hlines(y=[domain_set["y_min"], domain_set["y_max"]], xmin=domain_set["x_min"], xmax=domain_set["x_max"], color='k', linestyle='--', linewidth=1)
        
        # Title
        ax.set_title(f"Step: {0}    {time_set['label']}: {0.0:.2e}")

        # Save the figure
        wall_str  = "with_wall" if with_wall else "without_wall"

        save_path = save_dir / f"{key}_{wall_str}.png"
        fig.savefig(save_path, format="png", dpi=300, transparent=False)

        save_path = save_dir / f"{key}_{wall_str}.pdf"
        fig.savefig(save_path, format="pdf")

        plt.close(fig)

# ============================================================================ #
#   Plot the Virtual Markers (VM) data
# ============================================================================ #
def plot_virtual_markers(base_dir: Path, param: SimpleNamespace):

    # Target file
    vm_file = base_dir / "data" / "VM.dat"

    # Check if `VM.dat` exists
    if not vm_file.exists():
        return
    
    # Create the save directory
    save_dir = base_dir / "figures" / "initial_settings"
    save_dir.mkdir(parents=True, exist_ok=True)

    # Read the VM data
    vm = read_utils.vm_data(vm_file, param)

    # Get scatter marker size
    num_int  = param.num_int
    sca_size = visualizer.get_scatter_size(num_int, with_wall=True)

    # Get domain settings
    domain_set = visualizer.get_domain_settings(param)

    # Apply wall offset to the target particle coordinates
    x_plot = (vm.x - param.WL_thick) / domain_set["L_ref"]
    y_plot = (vm.y - param.WL_thick) / domain_set["L_ref"]

    # Grouping
    plot_group = {
        "top_bottom": [1, 2],
        "left_right": [3, 4],
        "corners"   : [5, 6, 7, 8]
    }

    # Draw and save figures for each group
    for group_name, ptypes in plot_group.items():
        mask = np.isin(vm.ptype, ptypes)
        if not np.any(mask):
            continue

        x_group = x_plot[mask]
        y_group = y_plot[mask]
        c_group = vm.ptype[mask]

        # Figure setup
        fig = plt.figure(figsize=(4.5,4), facecolor="white", constrained_layout=True)
        ax  = fig.add_subplot(111, facecolor="white")

        # Set equal aspect ratio for the spatial axes
        ax.set_aspect("equal")

        # Set the domain
        ax.set_xlim(domain_set["x_min"], domain_set["x_max"])
        ax.set_ylim(domain_set["y_min"], domain_set["y_max"])
        ax.xaxis.set_major_locator(MultipleLocator(domain_set["x_step"]))
        ax.yaxis.set_major_locator(MultipleLocator(domain_set["y_step"]))

        # Plot ptype
        cfig = ax.scatter(x_group, y_group, c=c_group,
                          cmap="tab10", ec="none", marker=".",
                          vmin=1, vmax=8, s=sca_size)
        cbar = fig.colorbar(cfig, ax=ax, ticks=range(1,9), orientation="vertical", shrink=0.7)
        cbar.set_label("VM Particle Type")

        # Axis labels
        ax.set_xlabel(domain_set["x_label"])
        ax.set_ylabel(domain_set["y_label"])

        # Title
        ax.set_title(f"Virtual Markers (VM) - {group_name.capitalize()}")

        # Save the figure
        save_path = save_dir / f"VM_ptype_{group_name}.png"
        fig.savefig(save_path, format="png", dpi=300, transparent=False)

        save_path = save_dir / f"VM_ptype_{group_name}.pdf"
        fig.savefig(save_path, format="pdf")

        plt.close(fig)