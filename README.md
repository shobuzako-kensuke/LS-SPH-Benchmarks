<div align="center">

# LS-SPH-Benchmarks <!-- omit in toc -->

<p align="center">
  This repository provides various benchmark programs using the <strong>Least-Squares Smoothed Particle Hydrodynamics (LS-SPH)</strong> method, a high-accuracy mesh-free method.
</p>

<img src="materials/images/CF_TG_OD.png" alt="Logo" width="100%">

<br>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19181862.svg)](https://doi.org/10.5281/zenodo.19181862)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Intel Fortran](https://img.shields.io/badge/Fortran-Intel%20ifx-734f96?style=for-the-badge&logo=fortran&logoColor=white)]()
[![GNU Fortran](https://img.shields.io/badge/Fortran-GNU%20gfortran-734f96?style=for-the-badge&logo=fortran&logoColor=white)]()
[![Python](https://img.shields.io/badge/Python-3.12%2B-blue?style=for-the-badge&logo=python&logoColor=white)]()

[**日本語版はこちら**](README_ja.md)

</div>


## Table of Contents <!-- omit in toc -->
- [🔥 Implemented Benchmark Programs (All 2D)](#-implemented-benchmark-programs-all-2d)
- [⚙️ System Requirements](#️-system-requirements)
- [🖥️ Usage](#️-usage)
  - [1. Download this repository](#1-download-this-repository)
  - [2. Run the calculation](#2-run-the-calculation)
  - [3. Visualize and analyze the results](#3-visualize-and-analyze-the-results)
- [📖 Documentation](#-documentation)
- [📁 Directory Structure](#-directory-structure)
- [🧑‍💻 Citation](#-citation)
- [🪪 License](#-license)

<br>

## 🔥 Implemented Benchmark Programs (All 2D)

- **Verification**: Comparison with analytical solutions
  - Diffusion Equation Test
  - Taylor–Green Vortex Flow
- **Validation**: Fluid benchmark tests
  - Lid-driven Cavity Flow
  - Boussinesq Convection (Bottom-heated)


<!-- | Taylor–Green vortex | Lid-driven cavity flow | Boussinesq convection |
| :---: | :---: | :---: |
| <img src="materials/images/" alt="Taylor-Green vortex" width="300"> | <img src="" alt="Cavity flow" width="300"> | <img src="" alt="Boussinesq convection" width="300"> | -->

<br>

## ⚙️ System Requirements

The SPH calculations are performed with **Fortran** (supported both Intel and GNU Fortran), while data analysis and visualization are handled by **Python**.

| Category | Requirement | Notes |
| :--- | :--- | :--- |
| **OS** | Unix-like OS | Tested on Windows Subsystem for Linux (WSL) |
| **Compiler** | Intel Fortran / GNU gortran | Tested with `ifx` (default) and `gfortran` |
| **Libraries** | MKL or LAPACK/BLAS | Required for matrix operations in the LS-SPH solver |
| **Build system** | Make | Used to compile the Fortran source code |
| **Visualization** | Python | Tested with `Python 3.12.0` |

> [!TIP]
> - Guides on installing WSL and setting up Intel Fortran and Python environments are available on my Qiita blog (in Japanese):
>     - [WSL2のインストールとアンインストール](https://qiita.com/zakoken/items/61141df6aeae9e3f8e36)
>     - [WSL2によるgfortranとintel fortranの環境構築](https://qiita.com/zakoken/items/2a5e629020ce68f3efe1)
>     - [WSL2によるPython3の環境構築](https://qiita.com/zakoken/items/8ddfda7267e7d95b3c46)
>
> - If `gfortran` is used, please ensure LAPACK and BLAS are installed (e.g., `sudo apt install liblapack-dev libblas-dev`).

<br>

## 🖥️ Usage

### 1. Download this repository
- Run the `git clone` command or download this repository as a ZIP file to your local machine.

### 2. Run the calculation
1. Set up the parameters, including the target problem and the SPH solver, in [config.h](/config.h).
2. Run `make` to build the Fortran source code.
3. Run `./start_calculation` to start the calculation.

> [!NOTE]
> - The calculation results (binary files) are automatically stored in the `results/` directory.
> - Details on the implemented benchmark tests and recommended parameters are provided in [materials/documents/benchmarks_detail.md](/materials/documents/benchmarks_detail.md).
> - Details of each parameter in [config.h](config.h) are provided in [materials/documents/config_guide.md](/materials/documents/config_guide.md).

### 3. Visualize and analyze the results
- Before running the analysis script, set up the Python virtual environment and install the required libraries.
  1. Create and activate a virtual environment
      ```bash
      python3 -m venv .venv
      source .venv/bin/activate
      ```
  2. Install the dependencies
      ```bash
      pip install --upgrade pip
      pip install -r requirements.txt
      ```
- Open [analyze.py](/analyze.py), configure the `SAVE_NAME` and other settings, and then run the script:
    ```bash
    python analyze.py
    ```

> [!NOTE]
> - The output figures and animations are automatically stored in the `figures/` directory.
> - To deactivate the virtual environment, run `deactivate`.

<br>

## 📖 Documentation

Detailed guides and theoretical backgrounds are provided in the [materials/documents/](/materials/documents/) directory.

- **[benchmarks_detail.md](/materials/documents/benchmarks_detail.md)**: Detailed explanations of the implemented benchmark tests and recommended parameters.
- **[config_guide.md](/materials/documents/config_guide.md)**: A comprehensive guide on the physical meaning and usage of each parameter in [config.h](/config.h).
- **[theory_manual.pdf](/materials/documents/theory_manual.pdf)**: The theoretical manual detailing the discretization, implemented algorithm, and analytical solutions of benchmarks.

<br>

## 📁 Directory Structure

```
LS-SPH-Benchmarks/
├── analysis/              # Python analysis scripts
│   ├── benchmarks/        # Analysis script for each benchmarks
│   └── common/            # Analysis tools
├── materials/             # Project materials
│   ├── documents/         # Program documentation
│   └── images/            # Images for README
├── source/                # Fortran source code
│   ├── boundary/          # Boundary treatment
│   ├── check/             # Checking
│   ├── core/              # Fundamental types and kernel functions
│   ├── equation/          # Governing equations & Time integrator
│   ├── io/                # Input/Output operations
│   ├── neighbor/          # Neighbor particle search
│   ├── setup/             # Problem setup and initialization
│   ├── shifting/          # Particle shifting
│   └── main.f90           # Main program
├── .gitignore             # Git ignore file
├── analyze.py             # Main analysis script
├── CHANGELOG.md           # Version history
├── CITATION.cff           # Citation information
├── config.h               # Configuration header file
├── initialize.py          # Initialization script
├── LICENSE                # License
├── Makefile               # Build instructions
├── README.md              # This document (English)
├── README_ja.md           # This document (Japanese)
└── requirements.txt       # Python dependencies
```

> [!NOTE]
> The following directories are **automatically** generated when building and running the program: `build/` (for intermediate binary files), `results/` (for calculation data), and `figures/` (for generated figures and animations).

<br>

## 🧑‍💻 Citation

Please **cite the following two references** if you use this repository.

**[1] Paper**<br>
Shobuzako, K., Yoshida, S., Kawada, Y., Nakashima, R., Fujioka, S., & Asai, M. (2025).  
A generalized smoothed particle hydrodynamics method based on the moving least squares method and its discretization error estimation.  
*Results in Applied Mathematics*, 26, 100594. [https://doi.org/10.1016/j.rinam.2025.100594](https://doi.org/10.1016/j.rinam.2025.100594)  
DOI: 10.1016/j.rinam.2025.100594

**[2] Software**<br>
Shobuzako, K. (2025). *LS-SPH-Benchmarks* (Version 1.0.0) [Computer software]. Zenodo.  
[https://doi.org/10.5281/zenodo.19181862](https://doi.org/10.5281/zenodo.19181862)

<details>
<summary>📄 Click to expand BibTeX</summary>

```bibtex
@article{shobuzako_2025_paper,
  author = {Kensuke Shobuzako and Shigeo Yoshida and Yoshifumi Kawada and Ryosuke Nakashima and Shujiro Fujioka and Mitsuteru Asai},
  title = {A generalized smoothed particle hydrodynamics method based on the moving least squares method and its discretization error estimation},
  journal = {Results in Applied Mathematics},
  volume = {26},
  pages = {100594},
  year = {2025},
  issn = {2590-0374},
  doi = {10.1016/j.rinam.2025.100594},
  url = {https://doi.org/10.1016/j.rinam.2025.100594}
}

@software{shobuzako_2025_software,
  author       = {Shobuzako, K.},
  title        = {LS-SPH-Benchmarks},
  year         = {2025},
  publisher    = {Zenodo},
  version      = {v1.0.0},
  doi          = {10.5281/zenodo.19181862},
  url          = {https://doi.org/10.5281/zenodo.19181862}
}
```
</details>

<br>

## 🪪 License

This repository is licensed under the [MIT License](LICENSE).
