<div align="center">

# LS-SPH-Benchmarks <!-- omit in toc -->

[![DOI](https://img.shields.io/badge/DOI-10.5281/zenodo.19181862-1f73b7.svg?style=flat-square)](https://doi.org/10.5281/zenodo.19181862)
[![Release](https://img.shields.io/github/v/release/shobuzako-kensuke/LS-SPH-Benchmarks?style=flat-square&color=10C810)](https://github.com/shobuzako-kensuke/LS-SPH-Benchmarks/releases)
[![OS](https://img.shields.io/badge/OS-Linux%20%7C%20Windows(WSL)-blue?style=flat-square)]()
[![Intel Fortran](https://img.shields.io/badge/Fortran-Intel%20ifx-734f96?style=flat-square&logo=fortran&logoColor=white)](https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler.html)
[![GNU Fortran](https://img.shields.io/badge/Fortran-GNU%20gfortran-734f96?style=flat-square&logo=fortran&logoColor=white)](https://gcc.gnu.org/fortran/)
[![Python](https://img.shields.io/badge/Python-3.12%2B-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![Stars](https://img.shields.io/github/stars/shobuzako-kensuke/LS-SPH-Benchmarks?style=flat-square&color=yellow)](https://github.com/shobuzako-kensuke/LS-SPH-Benchmarks/stargazers)
[![Downloads](https://img.shields.io/github/downloads/shobuzako-kensuke/LS-SPH-Benchmarks/total?style=flat-square)](https://github.com/shobuzako-kensuke/LS-SPH-Benchmarks/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](https://opensource.org/licenses/MIT)


<strong>最小二乗SPH (LS-SPH) 法</strong> [[1]](#shobuzako-2025) によるベンチマークプログラム集<br>
This repository provides various benchmark programs using the <strong>Least-Squares Smoothed Particle Hydrodynamics (LS-SPH)</strong> method [[1]](#shobuzako-2025).

<img src="materials/images/CF_TG_OD.png" alt="Logo" width="100%">


</div>


## Table of Contents <!-- omit in toc -->
- [🔥 Implemented Benchmark Programs / 実装されているベンチマークテスト](#-implemented-benchmark-programs--実装されているベンチマークテスト)
- [⚙️ System Requirements / 動作環境](#️-system-requirements--動作環境)
- [🖥️ Usage / 使い方](#️-usage--使い方)
  - [1. Download this repository / 本リポジトリの取得](#1-download-this-repository--本リポジトリの取得)
  - [2. Run the calculation / 計算の実行](#2-run-the-calculation--計算の実行)
  - [3. Analyze and Visualize the results / 結果の解析と可視化](#3-analyze-and-visualize-the-results--結果の解析と可視化)
- [📖 Documentation / マニュアル](#-documentation--マニュアル)
- [📁 Directory Structure / ディレクトリ構造](#-directory-structure--ディレクトリ構造)
- [🧑‍💻 Citation /  本プログラムを利用される場合](#-citation---本プログラムを利用される場合)
- [🪪 License / ライセンス](#-license--ライセンス)

<br>

## 🔥 Implemented Benchmark Programs / 実装されているベンチマークテスト

This repository implements the following 2D benchmark tests.  
以下の2次元ベンチマークテストが実装されています。


| Category<br>分類 | Benchmark Tests<br>テスト名 | Description<br>概要 |
| :--- | :--- | :--- |
| **Verification**<br>解析解との比較・検証 | Diffusion Equation Test<br>拡散方程式テスト | A problem to obtain the solution of the Poisson equation under appropriate wall boundary conditions as the steady state of the diffusion equation<br>適切な壁境界条件におけるポアソン方程式の解を拡散方程式の定常解として得る問題 |
|  | Taylor-Green Vortex<br>テイラー・グリーン渦 | Unsteady flow with decaying vortices under free-slip boundary conditions<br>自由滑り境界条件のもとで渦が減衰する非定常問題 |
| **Validation**<br>流体ベンチマークテストを用いた検証 | Lid-driven Cavity Flow<br>キャビティ流れ | Internal flow driven by the top wall moving at a constant velocity<br>一定速度で移動する上部壁によって駆動される内部流れ |
|  | Boussinesq Convection (Bottom-heated)<br>ブシネスク対流（底面加熱） | Thermal convection driven by temperature difference (buoyancy) induced by bottom heating<br>底面加熱による温度差（浮力）で駆動される熱対流 |


<!-- | Taylor–Green vortex | Lid-driven cavity flow | Boussinesq convection |
| :---: | :---: | :---: |
| <img src="materials/images/" alt="Taylor-Green vortex" width="300"> | <img src="" alt="Cavity flow" width="300"> | <img src="" alt="Boussinesq convection" width="300"> | -->

<br>

## ⚙️ System Requirements / 動作環境

The SPH calculations are performed with **Fortran** (both Intel and GNU Fortran are supported), while data analysis and visualization are handled by **Python**.  
SPH計算には **Fortran** (Intel Fortran / GNU gfortranに対応)、解析および可視化には **Python** を使用しています。

| Category | Requirement | Notes |
| :--- | :--- | :--- |
| **OS** | Unix-like OS | Tested on Windows Subsystem for Linux (WSL) |
| **Compiler** | Intel Fortran / GNU gfortran | Tested with `ifx` (default) and `gfortran` |
| **Libraries** | MKL or LAPACK/BLAS | Required for matrix operations in the LS-SPH |
| **Build system** | Make | Used to compile the Fortran source code |
| **Visualization** | Python | Tested with `Python 3.12.0` |

> [!TIP]
> - Guides on installing WSL and setting up Intel Fortran and Python environments are available on my Qiita blog (in Japanese):
>     - [WSL2のインストールとアンインストール](https://qiita.com/zakoken/items/61141df6aeae9e3f8e36)
>     - [WSL2によるgfortranとintel fortranの環境構築](https://qiita.com/zakoken/items/2a5e629020ce68f3efe1)
>     - [WSL2によるPython3の環境構築](https://qiita.com/zakoken/items/8ddfda7267e7d95b3c46)
> - If `gfortran` is used, please ensure LAPACK and BLAS are installed (e.g., `sudo apt install liblapack-dev libblas-dev`).
> ---
> - **WSLの導入** や **WSL上へのIntel Fortran/Python環境の構築** に関するQiita記事を執筆しておりますので、適宜ご参照ください。
>     - [WSL2のインストールとアンインストール](https://qiita.com/zakoken/items/61141df6aeae9e3f8e36)
>     - [WSL2によるgfortranとintel fortranの環境構築](https://qiita.com/zakoken/items/2a5e629020ce68f3efe1)
>     - [WSL2によるPython3の環境構築](https://qiita.com/zakoken/items/8ddfda7267e7d95b3c46)
> - `gfortran` を使用する場合は、LAPACK と BLAS がインストールされていることをご確認ください。インストールされていない場合は `sudo apt install liblapack-dev libblas-dev` を実行してください。

<br>

## 🖥️ Usage / 使い方

### 1. Download this repository / 本リポジトリの取得

Run the `git clone` command or download this repository as a ZIP file to your local machine.<br>
ターミナルで `git clone` コマンドを実行するか、ZIPファイルとして本プログラム全体をローカル環境（お使いのPCなど）にダウンロードし展開してください。

### 2. Run the calculation / 計算の実行

1. Set up the parameters, including the target problem and the SPH solver, in [config.h](./config.h).<br>解く問題、ソルバーの種類、パラメータ値を [config.h](./config.h) で設定してください。

2. Open [Makefile](./Makefile) and specify the compiler (`ifx` or `gfortran`)<br>[Makefile](./Makefile) を開き、コンパイラを指定してください (`ifx` あるいは `gfortran`)。

3. Run `make` in the root directory to compile the Fortran source code.<br>本リポジトリのルートディレクトリ上で `make` を実行し、Fortranファイルをコンパイルしてください。

4. Run `./start_calculation` in the root directory to start the calculation.<br>本リポジトリのルートディレクトリ上で `./start_calculation` を実行してください。SPH計算が起動します。

> [!NOTE]
> - The calculation results (binary files) are automatically stored in the `results/` directory.<br>計算結果（バイナリファイル）は自動的に `results/` ディレクトリに保存されます。
> 
> - Details on the implemented benchmark tests and recommended parameters are provided in [benchmarks_detail.md](./materials/documents/benchmarks_detail.md).<br>実装されているベンチマークテストおよびパラメータの推奨値は [benchmarks_detail.md](./materials/documents/benchmarks_detail.md) をご参照ください。
> 
> - Details of each parameter in [config.h](./config.h) are provided in [config_guide.md](./materials/documents/config_guide.md).<br>[config.h](config.h) 内のパラメータの説明は [config_guide.md](./materials/documents/config_guide.md) をご参照ください。

### 3. Analyze and Visualize the results / 結果の解析と可視化

#### 〇 Initial Setup / 初期設定 <!-- omit in toc -->

Prior the initial execution of the Python analysis script, it is required to set up the Python virtual environment and install the necessary dependencies.<br>Pythonスクリプトを初めて実行する場合は、以下の手順で専用の仮想環境を設定し、必要なライブラリをインストールしてください。

1. Create and activate a virtual environment.<br>仮想環境を作成し、有効化します。
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```
2. Install the dependencies.<br>依存パッケージ（必要なライブラリ）をインストールします。
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

#### 〇 Execution / 解析の実行 <!-- omit in toc -->

Ensure that virtual environment is activated before running the Python analysis script.<br>Python解析スクリプトを実行する前に、仮想環境が有効化されていることを確認してください。

1. Activate the virtual environment (if not already activate).<br>仮想環境を有効化します。既に有効化されている場合は不要です。
   ```bash
   source .venv/bin/activate
   ```
2. Open [analyze.py](./analyze.py), configure the `SAVE_NAME` and other settings, and then execute the following command:<br>[analyze.py](./analyze.py) を開き、`SAVE_NAME` やその他の変数等を設定し、以下を実行してください。
   ```bash
   python analyze.py
   ```

> [!NOTE]
> - The output figures and animations are automatically stored in the `figures/` directory.<br>出力された図や動画は自動的に `figures/` ディレクトリに保存されます。
> 
> - To deactivate the virtual environment, run `deactivate`.<br>仮想環境を終了するには、ターミナルで `deactivate` を実行してください。


<br>

## 📖 Documentation / マニュアル

Detailed guides and theoretical backgrounds are provided in the [materials/documents/](./materials/documents/) directory.<br>
[materials/documents/](./materials/documents/) ディレクトリ内に以下のマニュアルを用意しています。

<br>

- [**benchmarks_detail.md**](./materials/documents/benchmarks_detail.md): <br>Detailed explanations of the implemented benchmark tests and recommended parameters<br>実装されているベンチマークテストの概要およびパラメータの推奨値

- [**config_guide.md**](./materials/documents/config_guide.md): <br>A comprehensive guide on the meaning of each parameter in [config.h](/config.h)<br>設定ファイル ([config.h](/config.h)) 内の各種パラメータの意味

- [**theory_manual.pdf**](./materials/documents/theory_manual.pdf): <br>The theoretical manual detailing the discretization, implemented algorithm, and analytical solutions of benchmarks<br>離散化手法、実装されているアルゴリズム、ベンチマークテストの解析解に関する理論マニュアル


<br>

## 📁 Directory Structure / ディレクトリ構造

```
LS-SPH-Benchmarks/
├── analysis/              # Python analysis scripts
│   ├── benchmarks/        # Analysis script for each benchmark
│   └── common/            # Analysis tools
├── materials/             # Project materials
│   ├── documents/         # Program documentation
│   └── images/            # Images for README
├── source/                # Fortran source code
│   ├── boundary/          # Boundary treatment
│   ├── check/             # Checking
│   ├── core/              # Fundamental types & kernel functions
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
├── README.md              # This document
└── requirements.txt       # Python dependencies
```

> [!NOTE]
> The following directories are **automatically** generated when building and running the program: `build/` (for intermediate binary files), `results/` (for calculation data), and `figures/` (for generated figures and animations).<br>
> 
> プログラムのコンパイルおよび実行に伴い、中間バイナリファイルを格納する `build/`、計算データを出力する `results/`、画像や動画を保存する `figures/` ディレクトリが**自動的に**生成されます。

<br>

## 🧑‍💻 Citation /  本プログラムを利用される場合

Please **cite the following two references** if you use this repository.<br>本リポジトリを利用される際は、以下の**2つの文献**を引用してください。

<a id="shobuzako-2025">**[1]**</a> **Paper**<br>
Shobuzako, K., Yoshida, S., Kawada, Y., Nakashima, R., Fujioka, S., & Asai, M. (2025).<br>
A generalized smoothed particle hydrodynamics method based on the moving least squares method and its discretization error estimation.<br>
*Results in Applied Mathematics*, Vol. 26, 100594.<br>
[https://doi.org/10.1016/j.rinam.2025.100594](https://doi.org/10.1016/j.rinam.2025.100594)<br>
DOI: 10.1016/j.rinam.2025.100594

**[2] Software**<br>
Shobuzako, K. (2026). *LS-SPH-Benchmarks* (Version 1.0.0) [Computer software]. Zenodo.  
[https://doi.org/10.5281/zenodo.19181862](https://doi.org/10.5281/zenodo.19181862)

<details>
<summary>📄 Click to expand BibTeX / クリックして BibTeX 情報を開く</summary>

```bibtex
@article{shobuzako_2025_paper,
  author = {Kensuke Shobuzako and Shigeo Yoshida and Yoshifumi Kawada and Ryosuke Nakashima and Shujiro Fujioka and Mitsuteru Asai},
  title = {A generalized smoothed particle hydrodynamics method based on the moving least squares method and its discretization error estimation},
  journal = {Results in Applied Mathematics},
  volume = {26},
  pages = {100594},
  year = {2025},
  doi = {10.1016/j.rinam.2025.100594},
  url = {https://doi.org/10.1016/j.rinam.2025.100594}
}

@software{shobuzako_2026_software,
  author       = {Shobuzako, K.},
  title        = {LS-SPH-Benchmarks},
  year         = {2026},
  publisher    = {Zenodo},
  version      = {v1.0.0},
  doi          = {10.5281/zenodo.19181862},
  url          = {https://doi.org/10.5281/zenodo.19181862}
}
```
</details>

<br>

## 🪪 License / ライセンス

This repository is licensed under the [MIT License](./LICENSE).<br>
本リポジトリは [MITライセンス](./LICENSE) の下で公開されています。
