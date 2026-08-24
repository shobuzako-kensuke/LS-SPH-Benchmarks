# ============================================================================ #
#                                                                              #
#                              LS-SPH-Benchmarks                               #
#                                                                              #
#                     Copyright (c) 2026 Kensuke SHOBUZAKO                     #
#               This program is licensed under the MIT License.                #
#                                                                              #
#                              ~~ Description ~~                               #
#     This script initializes the repository by deleting generated files,      #
#        such as calculation results, figures, and intermediate files.         #
#                                                                              #
# ============================================================================ #

import shutil
import sys
from pathlib import Path

def main():
    # ======================================================================== #
    #   User input
    # ======================================================================== #
    print("+ ======================================================== +")
    print("|   LS-SPH-Benchmarks Initialization Tool                  |")
    print("+ ======================================================== +")
    print("   This script will delete the following generated items:")
    print("      - build/            (Intermediate binary files)")
    print("      - results/          (Calculation data)")
    print("      - figures/          (Generated figures and animations)")
    print("      - start_calculation (Executable file)")
    print("      - ipo_out.optrpt    (Optimization report)")
    print("      - **/__pycache__/   (Python cache files)")

    print("+ ======================================================== +")
    ans = input("   Initialize this directory? [y/n]: ").strip().lower()

    # ======================================================================== #
    #   [ No ] Exit this program
    # ======================================================================== #
    if ans not in ["y", "yes"]:
        print("   Initialization is canceled.")
        print("+ ======================================================== +")
        sys.exit()

    # ======================================================================== #
    #   [ Yes ] Run the initialization 
    # ======================================================================== #
    # Get the root directory (absolute directory)
    root_dir = Path(__file__).resolve().parent
    
    # Get the target paths
    targets = [
        root_dir / "build",
        root_dir / "results",
        root_dir / "figures",
        root_dir / "start_calculation",
        root_dir / "start_calculation.exe",
        root_dir / "ipo_out.optrpt"
    ]

    # Search "__pycache__" in `analysis` directory and add them to `targets`
    targets.extend(root_dir.glob("analysis/**/__pycache__"))

    # Delete
    count = 0
    for target in targets:
        if target.exists():
            rel_path = target.relative_to(root_dir)  # Relative path from `root_dir`

            # If directory:
            if target.is_dir():
                shutil.rmtree(target)  # Delete the directory recursively
                print(f"      - Delete directory: {rel_path}/")

            # If file:
            elif target.is_file():
                target.unlink()        # Delete the file
                print(f"      - Delete file     : {rel_path}")

            count += 1

    print("+ ======================================================== +")
    
    if count == 0:
        print("   No generated files found. The directory is already cleaned.")
    else:
        print("   Initialization completed successfully!")


if __name__ == "__main__":
    main()