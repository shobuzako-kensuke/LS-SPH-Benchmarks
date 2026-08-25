# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#             This module reads the simulation parameters and data.            #
#                                                                              #
# ============================================================================ #

import csv
import numpy as np
from pathlib import Path
from types import SimpleNamespace

# ============================================================================ #
#   Read the parameter file (.csv)
#      - file_path: results/SAVE_NAME/config/parameters.csv
# ============================================================================ #
def parameters(file_path: Path) -> SimpleNamespace:
    
    # Initialize an empty dictionary
    param = {}
    
    # Read the data and add them to `param`
    with open(file_path, mode="r", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=",")  # `reader` stores only the pointer data
        next(reader)                           # Skip the first row
        
        # Read the file line by line
        for row in reader:
            key = row[0].strip()  # Keyword (removed space, \t, \n, ...)
            val = row[1].strip()  # Value

            # Store the keyword and value in `param`
            try:
                param[key] = int(val)             # Store if `val` is integer
            except ValueError:
                try:
                    val_safe   = val.replace("d", "e").replace("D", "E")  # d,D -> e, E
                    param[key] = float(val_safe)  # Store if `val` is float
                except ValueError:
                    param[key] = val              # Store if `val` is string

    # Return
    return SimpleNamespace(**param)  # We can write `param.key`

# ============================================================================ #
#   Read the simulation data (.dat)
#      - file_path: results/SAVE_NAME/data/[STEP].dat
# ============================================================================ #
def step_data(file_path: Path, param: SimpleNamespace) -> SimpleNamespace:

    # Read parameters
    N = param.num_total
    target_problem = param.target_problem

    # Initialize an empty dictionary
    sim_data = {}

    # Read the simulation data
    with open(file_path, mode="rb") as f:
        sim_data["ptype"] = np.fromfile(f, dtype="i4", count=N)
        sim_data["x"]     = np.fromfile(f, dtype="f8", count=N)
        sim_data["y"]     = np.fromfile(f, dtype="f8", count=N)
        sim_data["u"]     = np.fromfile(f, dtype="f8", count=N)
        sim_data["v"]     = np.fromfile(f, dtype="f8", count=N)
        sim_data["rho"]   = np.fromfile(f, dtype="f8", count=N)
        sim_data["pre"]   = np.fromfile(f, dtype="f8", count=N)

        if (target_problem == 4):
            sim_data["tem"] = np.fromfile(f, dtype="f8", count=N)

        sim_data["U"] = np.sqrt(sim_data["u"]**2 + sim_data["v"]**2)

    # Return
    return SimpleNamespace(**sim_data)

# ============================================================================ #
#   Read the virtual markers' data (.dat)
#      - file_path: results/SAVE_NAME/data/VM.dat
# ============================================================================ #
def vm_data(file_path: Path, param: SimpleNamespace) -> SimpleNamespace:

    # Read parameters
    N = param.num_ext
    target_problem = param.target_problem

    # Initialize an empty dictionary
    VM = {}

    # Read the VM data
    with open(file_path, mode="rb") as f:
        VM["ptype"] = np.fromfile(f, dtype="i4", count=N)
        VM["x"]     = np.fromfile(f, dtype="f8", count=N)
        VM["y"]     = np.fromfile(f, dtype="f8", count=N)
        VM["u"]     = np.fromfile(f, dtype="f8", count=N)
        VM["v"]     = np.fromfile(f, dtype="f8", count=N)
        VM["pre"]   = np.fromfile(f, dtype="f8", count=N)

        if (target_problem == 4):
            VM["tem"] = np.fromfile(f, dtype="f8", count=N)

    # Return
    return SimpleNamespace(**VM)