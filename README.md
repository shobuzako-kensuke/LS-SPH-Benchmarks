<div align="center">

# LS-SPH-Benchmarks <!-- omit in toc -->

<img src="materials/images/CF_TG_OD.png" alt="Logo" width="100%">

<br>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19181862.svg)](https://doi.org/10.5281/zenodo.19181862)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Fortran](https://img.shields.io/badge/Fortran-Intel%20ifx-734f96?style=for-the-badge&logo=fortran&logoColor=white)]()
[![Python](https://img.shields.io/badge/Python-3.12%2B-blue?style=for-the-badge&logo=python&logoColor=white)]()

<p align="center">
  This repository provides various benchmark programs using the <strong>Smoothed Particle Hydrodynamics (SPH)</strong> method, a mesh-free method, and its high-accuracy variant, the <strong>Least-Squares SPH (LS-SPH)</strong> method.
</p>

[**日本語版はこちら**](README_ja.md)

</div>


## Table of Contents <!-- omit in toc -->
- [🔥 Implemented Benchmark Programs](#-implemented-benchmark-programs)
- [⚙️ System Requirements](#️-system-requirements)
- [🖥️ Usage](#️-usage)
  - [1. Download this repository](#1-download-this-repository)
  - [2. Run the calculation](#2-run-the-calculation)
  - [3. Visualize and analyze the results](#3-visualize-and-analyze-the-results)
- [📁 Directory Structure](#-directory-structure)
- [🧑‍💻 Citation](#-citation)
- [🪪 License](#-license)

<br>

## 🔥 Implemented Benchmark Programs

- **Verification: Comparison with analytical solutions**
  - 2D diffusion equation test to verify wall boundary treatments
  - Taylor–Green vortex flow
- **Validation: Fluid benchmark tests**
  - Lid-driven cavity flow
  - Boussinesq convection


| Taylor–Green vortex | Lid-driven cavity flow | Boussinesq convection |
| :---: | :---: | :---: |
| <img src="" alt="Taylor-Green vortex" width="300"> | <img src="" alt="Cavity flow" width="300"> | <img src="" alt="Boussinesq convection" width="300"> |

<br>

## ⚙️ System Requirements

The core calculations are performed using **Intel Fortran**, while data analysis and visualization are handled using **Python**.

| Category | Requirement | Notes |
| :--- | :--- | :--- |
| **OS** | Unix-like OS | Tested on Windows Subsystem for Linux (WSL). |
| **Compiler** | Intel Fortran | Tested with `ifx` (default). |
| **Build system** | Make | Used to compile the Fortran source code. |
| **Visualization** | Python | Tested with Python 3.12.0 (which requires `matplotlib`, `numpy`, etc.). |
| **Animation**| `ffmpeg` | Required by the Python scripts to generate animations. |

> [!TIP]
> - Guides on installing WSL and setting up Intel Fortran/Python environments are available on my Qiita blog (in Japanese):
>     - [WSL2のインストールとアンインストール](https://qiita.com/zakoken/items/61141df6aeae9e3f8e36)
>     - [WSL2によるgfortranとintel fortranの環境構築](https://qiita.com/zakoken/items/2a5e629020ce68f3efe1)
>     - [WSL2によるPython3の環境構築](https://qiita.com/zakoken/items/8ddfda7267e7d95b3c46)
> 
> - If `ffmpeg` is not installed, run `sudo apt install ffmpeg` in your terminal.

<br>

## 🖥️ Usage

### 1. Download this repository
- Run the `git clone` command or download this repository as a ZIP file to your local machine.

### 2. Run the calculation
1. Set up the parameters, including the target problem and the SPH solver, in `config.h`.
2. Run `make` to build the Fortran source code.
3. After completing the build, run `./start_calculation` to start the calculation.

> [!NOTE]
> The calculation results (binary files) are automatically stored in the `results/` directory.

### 3. Visualize and analyze the results
- Select the target data in `analysis_main.py` and run the script.

> [!NOTE]
> The output figures and animations are automatically stored in the `figures/` directory.

<br>

## 📁 Directory Structure

```
LS-SPH-Benchmarks/
├── analysis/              # Python analysis scripts 
├── materials/             # Project materials
│   ├── documents/         # Program documentation
│   └── images/            # Images for README
├── source/                # Fortran source code
│   ├── boundary/          # Boundary treatment
│   ├── check/             # Error checking
│   ├── core/              # Core definitions
│   ├── equation/          # Governing equations
│   ├── integrator/        # Time marching schemes
│   ├── io/                # Input/Output operations
│   ├── kernel/            # Kernel functions
│   ├── neighbor/          # Neighbor particle search
│   ├── setup/             # Problem setup and initialization
│   ├── shifting/          # Particle shifting
│   ├── solver/            # SPH solvers
│   └── main.f90           # Main program
├── .gitignore             # Git ignore file
├── analysis_main.py       # Main analysis script
├── CHANGELOG.md           # Version history
├── CITATION.cff           # Citation information
├── config.h               # Configuration header file
├── CONTRIBUTORS.md        # Repository contributors
├── initialize.py          # Initialization script
├── input.f90              # Input setting file
├── LICENSE                # License
├── Makefile               # Build instructions
├── README.md              # This document (English)
└── README_ja.md           # This document (Japanese)
```

> [!NOTE]
> The following directories are **automatically** generated when building and running the program: `build/` (for intermediate binary files), `results/` (for calculation data), and `figures/` (for generated figures and animations).

> [!TIP]
> Details on each program file are provided in `materials/documents/`.

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
