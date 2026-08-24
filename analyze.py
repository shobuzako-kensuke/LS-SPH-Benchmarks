# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#          This main script orchestrates the Python analysis modules.          #
#                                                                              #
# ============================================================================ #

import time
from pathlib import Path
from analysis.common import read_utils, visualizer, initial_check, snapshot, animation_utils
from analysis.benchmarks import boussinesq_conv, cavity_flow, diffusion_equation, taylor_green

# ============================================================================ #
#   User Settings
# ============================================================================ #
# Input "SAVE_NAME"
SAVE_NAME = "tg_compare_50"

# Input `True` or `False`
CHECK_INITIAL_STATE = True
MAKE_ANIMATION      = True

# Input animation FPS
FPS = 10

# ============================================================================ #
#   Main Program
# ============================================================================ #
def main():
    start_time = time.perf_counter()  # Wall-clock time

    print( "+ ======================================================== +")
    print( "|   LS-SPH-Benchmarks analyze.py                           |")
    print( "+ ======================================================== +")
    print(f"   Analysis file : {SAVE_NAME}")
    print("")

    # ========================================================================= #
    #   1. Read parameters
    # ========================================================================= #
    base_dir   = Path("results") / SAVE_NAME
    param_file = base_dir / "config" / "parameters.csv"
    param      = read_utils.parameters(param_file)

    # Apply the global figure style
    visualizer.set_figure_style()

    # ========================================================================= #
    #   2. Check initial state
    # ========================================================================= #
    if CHECK_INITIAL_STATE:
        print( "      Generating initial state figures : Progress...", end="", flush=True)
        initial_check.plot_particles(base_dir, param, with_wall=False)
        initial_check.plot_particles(base_dir, param, with_wall=True)
        initial_check.plot_virtual_markers(base_dir, param)
        print( "\r      Generating initial state figures : Completed   ")

    # ========================================================================= #
    #   3. Analyze each benchmark test
    # ========================================================================= #
    if (param.target_problem == 1):
        diffusion_equation.main(base_dir, param)

    elif (param.target_problem == 2):
        taylor_green.main(base_dir, param)

    elif (param.target_problem == 3):
        cavity_flow.main(base_dir, param)

    elif (param.target_problem == 4):
        boussinesq_conv.main(base_dir, param)
    
    # ========================================================================= #
    #   4. Make the animations
    # ========================================================================= #
    if MAKE_ANIMATION:
        # Generate snapshots (PNG)
        snapshot.generate_snapshots(base_dir, param)

        # Convert the generated snapshots to MP4
        target_keys = ["u", "v", "pre", "U"]
        if param.target_problem == 4:
            target_keys.append("tem")
        animation_utils.generate_mp4(base_dir, target_keys, FPS)

    # ========================================================================= #
    #   5. Log
    # ========================================================================= #
    end_time = time.perf_counter()
    print(f"\n   All analysis completed: {end_time - start_time:.2f} [s]")
    print( "+ ======================================================== +")

if __name__ == "__main__":
    main()