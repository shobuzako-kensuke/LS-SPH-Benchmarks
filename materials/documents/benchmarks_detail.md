# Benchmark Details & Recommended Settings <!-- omit in toc -->

This document provides a practical guide for running each benchmark test. It includes the details of each benchmark test, recommended parameters for [config.h](../../config.h), and the expected results to help you verify your simulation.

本ドキュメントでは、各ベンチマークテストの詳細および [config.h](../../config.h) の推奨パラメータ値をまとめています。

> [!NOTE]
> - For a detailed explanation of each parameter, see [config_guide.md](./config_guide.md).  
> 各パラメータの詳細な説明は [config_guide.md](./config_guide.md) をご参照ください。
>
> - For mathematical details (governing equations, analytical solutions, and discretization schemes), see [theory_manual.pdf](./theory_manual.pdf).  
> 支配方程式、解析解の導出、離散化スキームなどの数理的な詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

## Table of Contents / 目次 <!-- omit in toc -->
- [1. Diffusion Equation Test / 拡散方程式テスト](#1-diffusion-equation-test--拡散方程式テスト)
  - [1.1 Overview / 概要](#11-overview--概要)
  - [1.2 Governing Equation / 支配方程式](#12-governing-equation--支配方程式)
  - [1.3 Boundary and Initial Conditions / 境界条件・初期条件](#13-boundary-and-initial-conditions--境界条件初期条件)
    - [Boundary condition / 境界条件](#boundary-condition--境界条件)
    - [Initial condition / 初期条件](#initial-condition--初期条件)
  - [1.4 Verification: Comparison with Analytical Solution / 検証: 解析解との比較](#14-verification-comparison-with-analytical-solution--検証-解析解との比較)
  - [1.5 Time Step \& Steady-state Criterion / 時間刻み幅と定常状態の判定](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定)
  - [1.6 Parameter Settings / パラメータ設定](#16-parameter-settings--パラメータ設定)
    - [Required Settings / 必須設定（固定値）](#required-settings--必須設定固定値)
    - [Recommended Settings / 推奨設定（変更可能）](#recommended-settings--推奨設定変更可能)
  - [1.7 Output data format / 結果の出力形式](#17-output-data-format--結果の出力形式)
- [2. Taylor-Green Vortex / テイラー・グリーン渦](#2-taylor-green-vortex--テイラーグリーン渦)
  - [2.1 Overview / 概要](#21-overview--概要)
  - [2.2 Governing Equation / 支配方程式](#22-governing-equation--支配方程式)
  - [2.3 Boundary and Initial Conditions / 境界条件・初期条件](#23-boundary-and-initial-conditions--境界条件初期条件)
    - [Boundary condition / 境界条件](#boundary-condition--境界条件-1)
    - [Initial condition / 初期条件](#initial-condition--初期条件-1)
  - [2.4 Verification: Comparison with Analytical Solution / 検証: 解析解との比較](#24-verification-comparison-with-analytical-solution--検証-解析解との比較)
  - [2.5 Time Step / 時間刻み幅](#25-time-step--時間刻み幅)
  - [2.6 Parameter Settings / パラメータ設定](#26-parameter-settings--パラメータ設定)
    - [Required Settings / 必須設定（固定値）](#required-settings--必須設定固定値-1)
    - [Recommended Settings / 推奨設定（変更可能）](#recommended-settings--推奨設定変更可能-1)
  - [2.7 Output data format / 結果の出力形式](#27-output-data-format--結果の出力形式)
- [3. Lid-driven Cavity Flow / キャビティ流れ](#3-lid-driven-cavity-flow--キャビティ流れ)
  - [3.1 Overview / 概要](#31-overview--概要)
  - [3.2 Governing Equation / 支配方程式](#32-governing-equation--支配方程式)
  - [3.3 Boundary and Initial Conditions / 境界条件・初期条件](#33-boundary-and-initial-conditions--境界条件初期条件)
    - [Boundary condition / 境界条件](#boundary-condition--境界条件-2)
    - [Initial condition / 初期条件](#initial-condition--初期条件-2)
  - [3.4 Verification: Comparison with Reference Data / 検証: 参照解との比較](#34-verification-comparison-with-reference-data--検証-参照解との比較)
  - [3.5 Time Step / 時間刻み幅](#35-time-step--時間刻み幅)
  - [3.6 Parameter Settings / パラメータ設定](#36-parameter-settings--パラメータ設定)
    - [Required Settings / 必須設定（固定値）](#required-settings--必須設定固定値-2)
    - [Recommended Settings / 推奨設定（変更可能）](#recommended-settings--推奨設定変更可能-2)
  - [3.7 Output data format / 結果の出力形式](#37-output-data-format--結果の出力形式)
- [4. Boussinesq Convection (bottom-heated) / ブシネスク熱対流 (底面加熱)](#4-boussinesq-convection-bottom-heated--ブシネスク熱対流-底面加熱)
  - [4.1 Overview / 概要](#41-overview--概要)
  - [4.2 Governing Equation / 支配方程式](#42-governing-equation--支配方程式)
  - [4.3 Boundary and Initial Conditions / 境界条件・初期条件](#43-boundary-and-initial-conditions--境界条件初期条件)
    - [Boundary condition / 境界条件](#boundary-condition--境界条件-3)
    - [Initial condition / 初期条件](#initial-condition--初期条件-3)
  - [4.4 Verification: Comparison with Reference Data / 検証: 参照解との比較](#44-verification-comparison-with-reference-data--検証-参照解との比較)
  - [4.5 Time Step / 時間刻み幅](#45-time-step--時間刻み幅)
    - [Setting of Relaxation Parameters / 緩和パラメータの設定](#setting-of-relaxation-parameters--緩和パラメータの設定)
  - [4.6 Parameter Settings / パラメータ設定](#46-parameter-settings--パラメータ設定)
    - [Required Settings / 必須設定（固定値）](#required-settings--必須設定固定値-3)
    - [Recommended Settings / 推奨設定（変更可能）](#recommended-settings--推奨設定変更可能-3)
    - [Parameters depending on the Rayleigh Number / $Ra$ に依存するパラメータ](#parameters-depending-on-the-rayleigh-number--ra-に依存するパラメータ)
  - [4.7 Output data format / 結果の出力形式](#47-output-data-format--結果の出力形式)
- [参考文献](#参考文献)

<br>

## 1. Diffusion Equation Test / 拡散方程式テスト

### 1.1 Overview / 概要
This test solves the Poisson equation under an appropriate boundary condition as a steady state of the diffusion equation. This is implemented for verifying the discretization accuracy of the Laplacian, the effect of particle disorder (positional perturbation), and the effect of the wall boundary treatment in the SPH method.

適切な境界条件におけるポアソン方程式の解を、拡散方程式の定常解として得るテストです。ラプラシアンの離散化精度、粒子配置の不規則性（位置摂動）の効果、SPH法における壁境界モデルの影響などを検証するために実装しました。

---

### 1.2 Governing Equation / 支配方程式

The governing equation is the following 2D diffusion equation with a source term:  
支配方程式は、以下のソース項付きの2次元拡散方程式です。

$$
\frac{\partial f}{\partial t} = \nabla^{2} f + 2 \pi^{2} \sin(\pi x) \cos(\pi y),
$$

where $f(x,y,t)$ is a scalar function and $t$ is the time. The computational domain $\Omega$ is a unit square ($\Omega = [0, 1] \times [0, 1]$). For simplicity, the diffusion coefficient is set to unity.<br>
ここで、 $f(x,y,t)$ はスカラー関数、 $t$ は時間を表します。計算領域 $\Omega$ として長さが1の正方形領域を考えます ($\Omega = [0, 1] \times [0, 1]$)。簡単のため、拡散係数は$1$としています。

---

### 1.3 Boundary and Initial Conditions / 境界条件・初期条件

#### Boundary condition / 境界条件

The following Dirichlet or Neumann conditions are imposed.   
境界条件として以下のディリクレ条件またはノイマン条件を考えます。

- For the Dirichlet condition<br>ディリクレ条件を課す場合:
    
$$
\begin{aligned}
f(0, y, t) &= f(1, y, t) = 0 , \\
f(x, 0, t) &=  \sin \left(\pi x\right), \\
f(x, 1, t) &= -\sin \left(\pi x\right).
\end{aligned}
$$

- For the Neumann condition<br>ノイマン条件を課す場合:
    
$$
\begin{aligned}
\frac{\partial f}{\partial x} \bigg|_ {x=0} &=  \pi \cos \left(\pi y \right), \\
\frac{\partial f}{\partial x} \bigg|_ {x=1} &= - \pi \cos\left(\pi y \right), \\
\frac{\partial f}{\partial y} \bigg|_ {y=0,1} &= 0.
\end{aligned}
$$

A Dirichlet condition of $f=0$ is always imposed at the corners of the computational domain to avoid the non-uniqueness of the solution that arises when only Neumann boundary conditions are applied.<br>
計算領域の四隅（コーナー）においては、ノイマン条件のみを課した場合における解の不定性を防ぐため、常に $f=0$ というディリクレ条件を課すことにします。

---

#### Initial condition / 初期条件

The initial condition is set to $f(x,y,0) = 0$.  
初期条件として $f(x,y,0) = 0$ を考えます。

<br>

For this test, the particle position is fixed in space. The fixed position $\vec{x}_ {i}$ of a particle $i$ is defined as:  
本テストにおいて粒子位置は空間的に固定されます。粒子 $i$ の固定位置 $\vec{x}_ {i}$ は次式により定義されます。

$$
\vec{x}_ {i} = \vec{x}_ {i,0} + (\epsilon \Delta x) \vec{e} ,
$$

where $\vec{x}_ {i,0}$ is its position for the regular configuration, $\epsilon =$ `POS_PERT` is the magnitude of the positional perturbation, $\Delta x$ is the particle spacing for the regular configuration, and $\vec{e}$ is a 2D random vector whose components range from $-1$ to $1$.<br>
ここで、 $\vec{x}_ {i,0}$ は規則配置時における粒子 $i$ の位置、 $\epsilon =$ `POS_PERT` は位置摂動の大きさ、 $\Delta x$ は一様配置時における粒子間隔、 $\vec{e}$ は各要素の値が $-1$ から $1$ の間をランダムに取る2次元ベクトルをそれぞれ表します。


---

### 1.4 Verification: Comparison with Analytical Solution / 検証: 解析解との比較

Under the above boundary conditions, the analytical solution at the steady state ($\partial f / \partial t = 0$) can be obtained as follows:  
上述の境界条件のもとで、定常状態 ($\partial f / \partial t = 0$) における解析解 $f^{\mathrm{ana}}_ {\mathrm{s}} (x,y)$ は以下のように求められます。

$$
f^{\mathrm{ana}}_ {\mathrm{s} }(x,y) = \sin \left(\pi x \right) \cos \left(\pi y \right).
$$

To compare the numerical result with the analytical solution, the following error norms are used:  
数値解と解析解を比較するために、以下の誤差指標を用います。

$$
\begin{aligned}
&L_ {1} = \frac{1}{N} \sum^{N}_ {i=1} \Big| f^{\mathrm{cal}}_ {\mathrm{s}} (x_ {i}, y_ {i}) - f^{\mathrm{ana}}_ {\mathrm{s}} (x_ {i}, y_ {i}) \Big|, \\
&L_ {2} = \sqrt{ \frac{1}{N} \sum^{N}_ {i=1} \Big( f^{\mathrm{cal}}_ {\mathrm{s}} (x_ {i}, y_ {i}) - f^{\mathrm{ana}}_ {\mathrm{s}} (x_ {i}, y_ {i}) \Big)^{2} }, \\
&L_ {\infty} = \max_ {1 \leq i \leq N} \Big| f^{\mathrm{cal}}_ {\mathrm{s}} (x_ {i}, y_ {i}) - f^{\mathrm{ana}}_ {\mathrm{s}} (x_ {i}, y_ {i}) \Big|, \\
\end{aligned}
$$

where $N$ is the total number of particles, and $f^{\mathrm{cal}}_ {\mathrm{s}} (x, y)$ is the numerical result at the steady state.  
ここで、 $N$ は全粒子数、 $f^{\mathrm{cal}}_ {\mathrm{s}} (x, y)$ は定常状態における数値解をそれぞれ表します。

---

### 1.5 Time Step & Steady-state Criterion / 時間刻み幅と定常状態の判定

The time step $\Delta t$ is determined by:  
時間刻み幅 $\Delta t$ は次式により決定されます。

$$
\Delta t = C_ {\mathrm{DIF}} \times \frac{(\Delta x)^{2}}{D}.
$$

where $C_ {\mathrm{DIF}}=$ `COE_DIF` is a coefficient ($0 < C_ {\mathrm{DIF}} < 1$), $\Delta x$ is the particle spacing for the regular configuration, and $D = 1$ is the diffusion coefficient.  
ここで、 $C_ {\mathrm{DIF}}=$ `COE_DIF` は適当な係数 ($0 < C_ {\mathrm{DIF}} < 1$)、 $\Delta x$ は規則配置時における粒子間隔、 $D = 1$ は拡散係数です。

<br>

The steady state is considered to be reached when the following condition is satisfied:  
本コードでは以下の条件を満たしたとき、「定常状態に達した」と判定しています。

$$
\max_ {1 \leq i \leq N} \Big| f^{\mathrm{cal}} (x_ {i}, y_ {i}, t_ {n}) - f^{\mathrm{cal}} (x_ {i}, y_ {i}, t_ {n-1})\Big| < \epsilon_ {\mathrm{s}},
$$

where $t_ {n}$ is the time at step $n$ and $\epsilon_ {\mathrm{s}} =$ `THRESHOLD` is the convergence threshold.  
ここで、 $t_ {n}$ は $n$ ステップ時の時刻、 $\epsilon_ {\mathrm{s}} =$ `THRESHOLD` は収束閾値を表します。

Once the steady state is reached, the simulation terminates regardless of the specified `END_STEP`.  
定常状態に達したと判定されると、`END_STEP` の設定に関わらず計算が終了します。

<br>

Since the diffusion time for the entire system is $\tau_ {\mathrm{DIF}} = L^{2} / D = 1$ (where $L$ is the characteristic length and $L = 1, D = 1$ in this test), the number of steps $N_ {\mathrm{step}}$ required to reach the steady state is estimated as follows:  
系全体に対する拡散時間は $\tau_ {\mathrm{DIF}} = L^{2} / D = 1$ ($L$ は代表長さで、本問題では $L = 1, D = 1$) であるため、定常状態に達するまでに必要なステップ数 $N_ {\mathrm{step}}$ は以下のように見積もられます。

$$
N_ {\mathrm{step}} \sim \frac{\tau_ {\mathrm{DIF}}}{\Delta t} = \frac{1}{C_ {\mathrm{DIF}} (\Delta x)^{2}} = \frac{n^{2}}{C_ {\mathrm{DIF}}},
$$

where $n =$ `NUM_X` $=$ `NUM_Y` is the number of particles along one side of the square domain, satisfying the relationship $\Delta x = L / n$.  
ここで、 $n =$ `NUM_X` $=$ `NUM_Y` は正方形の1辺あたりの粒子数で、 $\Delta x = L / n$ の関係を満たします。

---

### 1.6 Parameter Settings / パラメータ設定

Set up the parameters in [config.h](../../config.h) according to the following settings.  
以下のパラメータ設定を参考にして、[config.h](../../config.h) を適切に設定してください。

#### Required Settings / 必須設定（固定値）

The following parameters must be set to the specified values.  
以下のパラメータは必ずこの値に設定してください。

| Parameter<br>パラメータ | Value<br>値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `TARGET_PROBLEM` | **1** | Select the Diffusion Equation Test<br>拡散方程式テストを選択します |
| `U_BOUNDARY_*` | **1** or **2** | Values of **1** and **2** correspond to the Neumann and Dirichlet boundary conditions, respectively<br>**1** はノイマン条件、**2**はディリクレ条件に対応しています |
| `LEN_X`, `LEN_Y` | **1.0d0** | Set the system length to unity<br>系の長さは1と設定してください |
| `RK` | **2** or **4** | Order of the Runge-Kutta method<br>ルンゲクッタ法における次数を選択してください |
| `KERNEL_TYPE` | from **1** to **5** | Select the kernel function in the SPH calculation<br>SPH計算におけるカーネル関数を指定してください |
| `SPH_MODEL` | from **1** to **6** | Select the discretization model of the SPH method<br>SPH法における離散化モデルを選択してください |
| `WALL_MODEL` | from **1** to **3** | Select the wall boundary model in the SPH method<br>SPH法における壁境界モデルを選択してください |

> [!NOTE]
> For mathematical details of the discretization and wall boundary models, see [theory_manual.pdf](./theory_manual.pdf).<br>
> 離散化モデル、壁境界モデルの数理的な詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

#### Recommended Settings / 推奨設定（変更可能）

The following parameters must also be set, but their values can be freely chosen by the user. The "Recommended Values" indicate the settings used for code verification.  <br>
以下のパラメータも必ず設定する必要がありますが、具体的な値は自由に設定できます。表中の「推奨値」は、本コードの動作確認に使用した値を表します。

| Parameter<br>パラメータ | Recommended Value<br>推奨値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `SAVE_NAME` | - | Output file name (`results/SAVE_NAME/`)<br>結果の保存ファイル名を指定してください |
| `READ_NAME` | `"new"` or specified `SAVE_NAME` | Set to `"new"` for a fresh start, or use a specified `SAVE_NAME` for a restart (see [config_guide.md](./config_guide.md))<br>新規計算時は `"new"`、再計算時はその `SAVE_NAME` を入力してください ([config_guide.md](./config_guide.md)を参照)|
| `OMP_THREADS` | **8** | Number of threads for OpenMP<br>OpenMPで使用するスレッド数を指定してください |
| `NUM_X`, `NUM_Y` | **10**, **20**, **45**, **100**, **200**, **450**, or **1000** | Spatial resolution (`NUM_X` must be equal to `NUM_Y`)<br>空間解像度を設定してください（`NUM_X` は `NUM_Y` と等しい必要があります） |
| `START_STEP` | **1** or **a specified step** | Set to 1 for a fresh start, or use a specified step for a restart<br>新規計算時は1、再計算時は特定のステップを設定してください |
| `END_STEP` | $\sim$ `NUM_X` $^2$ / `COE_DIF` | Set to approximately the diffusion time for the entire domain (see [Section 1.5](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定))<br>系全体に対する拡散時間程度に設定してください（詳しくは[1.5節](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定)を参照） |
| `WRITE_STEP` | - | Output interval in steps<br>出力間隔（ステップ）を指定してください |
| `THRESHOLD` | **1.0d-10** | Convergence threshold for determining the steady state (see [Section 1.5](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定))<br>定常状態の判定に用いる収束閾値を設定してください（詳しくは[1.5節](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定)を参照） |
| `COE_DIF` | **0.2d0** | Coefficient of the time step (see [Section 1.5](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定))<br>時間刻み幅に関する係数を設定してください（詳しくは[1.5節](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定)を参照） |
| `RHO_REF` | **1.0d0** | Mass density $\rho_ 0$ [kg m$^{-3}$]<br>SPH計算で用いる質量密度を設定してください |
| `POS_PERT` | **0.0d0** or **0.2d0** | Positional perturbation (0.0: Regular, see [Section 1.3](#13-boundary-and-initial-conditions--境界条件初期条件))<br>位置摂動の大きさを設定してください（0.0: 規則配置、詳しくは[1.3節](#13-boundary-and-initial-conditions--境界条件初期条件)を参照） |
| `COE_H` | **1.2d0** | Coefficient of the smoothing length $h$ in the SPH method ($h =$ `COE_H` $\times \Delta x$)<br>SPH計算におけるスムージング長 $h$ の係数 ($h =$ `COE_H` $\times \Delta x$) を設定してください |


> [!NOTE]
> - Any other parameters in [config.h](../../config.h) will be ignored.<br>
> [config.h](../../config.h) 内のその他のパラメータの値は無視されます。
> 
> - For a detailed explanation of each parameter, see [config_guide.md](./config_guide.md).<br>
> 各パラメータの詳細な意味については [config_guide.md](./config_guide.md) をご参照ください


---

### 1.7 Output data format / 結果の出力形式

The Fortran code exports the simulation results as unformatted binary files. You can read these files using your preferred post-processing software (e.g., Python, MATLAB) or the provided Python analysis scripts.  
Fortranコードにおいて、シミュレーション結果はバイナリファイル（Unformatted binary stream）として出力されます。出力されたファイルは、PythonやMATLAB等の任意の解析ツール、または付属のPython解析スクリプトを用いて読み込むことができます。

**Output Directories and Files / 出力先とファイル構成**<br>
- `results/SAVE_NAME/config/`: <br>Contains the simulation settings (`config.h`, `parameters.csv`) and the terminal output log (`run.log`).<br>計算設定（`config.h`, `parameters.csv`）および実行ログ（`run.log`）が保存されます。

- `results/SAVE_NAME/data/`: <br>Contains the sequential snapshot data (`[step].dat`).<br>スナップショットデータ（`[step].dat`）が保存されます。

<br>

**Binary Data Format of `[step].dat` / スナップショットデータのフォーマット**<br>
Each snapshot file stores the following 1D arrays sequentially for all particles (from index `1` to `NUM_TOTAL`):  
各スナップショットファイルには、全粒子（インデックス `1` から `NUM_TOTAL`）に対する以下の1次元配列が順番にベタ書きで格納されています。

1. `ptype` (32-bit Integer / 32ビット整数)
2. `x` (64-bit Double / 64ビット浮動小数点数)
3. `y` (64-bit Double / 64ビット浮動小数点数)
4. `u` (64-bit Double / 64ビット浮動小数点数)
5. `v` (64-bit Double / 64ビット浮動小数点数)
6. `rho` (64-bit Double / 64ビット浮動小数点数)
7. `pre` (64-bit Double / 64ビット浮動小数点数)

> [!NOTE]
> For the detail of the data format, see [write_data_mod.f90](../../source/io/write_data_mod.f90).<br>
> データ形式の詳細は [write_data_mod.f90](../../source/io/write_data_mod.f90) をご参照ください。


> [!NOTE]
> In this Diffusion Equation Test, the scalar function $f$ is stored and processed using the variable for the x-component of velocity `u`. When reading and analyzing the data, please refer to the `u` array. The variables `v`, `rho`, and `pre` are fixed dummy values in this test.<br>
> 本テスト（拡散方程式テスト）では、スカラー関数 $f$ は便宜上、速度のx成分の変数 `u` に格納されて計算・出力されます。そのため、データ解析する際は `u` の配列を参照してください。なお，`v`, `rho`, `pre` は本テストではダミー値となります。

By reading the data at the final step, you can compare the numerical result at the steady state with the analytical solution.  
最終ステップのデータを読み込むことで、定常状態における数値解と解析解との比較検証を行うことができます。


---

<br>

## 2. Taylor-Green Vortex / テイラー・グリーン渦

### 2.1 Overview / 概要

This test simulates the unsteady decay of 2D vortices driven by viscous dissipation. Since an analytical solution exists for this problem under the incompressible Navier-Stokes equations [[1]](#taylor-1937), this benchmark is widely used to verify the accuracy and stability in fluid simulation methods.

本テストでは、空間内に配置された2次元渦が粘性散逸によって減衰していく様子をシミュレーションします。本問題は非圧縮性ナビエ・ストークス方程式の解析解が存在する例として知られており[[1]](#taylor-1937)、流体シミュレーション手法の精度や安定性などを検証するために広く利用されています。

---

### 2.2 Governing Equation / 支配方程式

The governing equations are the incompressible Navier-Stokes equations as follows:<br>
支配方程式は、以下の非圧縮性ナビエ・ストークス方程式です。

$$
\begin{aligned}
\nabla \cdot \boldsymbol{u} &= 0, \\
\frac{\mathrm{D} \boldsymbol{u}}{\mathrm{D} t} &= -\frac{1}{\rho_ {0}} \nabla p + \nu \nabla^{2} \boldsymbol{u},
\end{aligned}
$$

where $\boldsymbol{u} = (u, v)$ is the velocity vector, $\mathrm{D} / \mathrm{D} t$ is the material derivative, $t$ is the time, $p$ is the pressure, $\rho_ {0}$ is the reference density, and $\nu$ is the kinematic viscosity. The computational domain is a rectangular region $\Omega = [0, L_ {x}] \times [0, L_ {y}]$. <br>
ここで、 $\boldsymbol{u} = (u, v)$ は速度ベクトル、 $\mathrm{D} / \mathrm{D} t$ は物質微分、 $t$は時間、 $p$ は圧力、 $\rho_ {0}$ は基準密度、 $\nu$ は動粘性率を表します。計算領域として矩形領域 $\Omega = [0, L_ {x}] \times [0, L_ {y}]$ を考えます。

<br>

The flow is characterized only by the Reynolds number $Re$:<br>
流れの特性はレイノルズ数 $Re$ のみによって特徴付けられます。

$$
Re = \frac{LU}{\nu},
$$

where $L$ is the characteristic length, and $U$ is the characteristic velocity. In this code, $L = L_{x}$ and $U = 1$.<br>
ここで、 $L$ は代表長さ、 $U$ は代表速度を表します。本コードでは $L = L_ {x}, U = 1$ としています。


> [!IMPORTANT]
> This code solves the governing equations using the weakly compressible approximation (e.g., [[2]](#morris-1997)). Under this approximation, the governing equations are expressed as follows:<br>
> 本コードでは弱圧縮性近似 (e.g., [[2]](#morris-1997)) を用いて支配方程式を解きます。このとき、支配方程式は以下のように近似されます。
>
> $$
> \begin{aligned}
> \frac{\mathrm{D} \rho}{\mathrm{D} t} &= - \rho \nabla \cdot \bm{u}, \\
> \frac{\mathrm{D} \boldsymbol{u}}{\mathrm{D} t} &= -\frac{1}{\rho} \nabla p + \nu \nabla^{2} \boldsymbol{u}, \\
> p &= c^{2} (\rho - \rho_ {0}),
> \end{aligned}
> $$
>
> where $\rho$ is the density, and $c$ is the reduced speed of sound, which should satisfy the following condition to keep the density variations below 1%:<br>
> ここで、 $\rho$ は密度、 $c$ は減速された音速を表します。音速は密度変動を1%未満に抑えるために、通常以下の条件を満たすように設定されます。
> 
> $$
> c \geq 10 U_ {\max},
> $$
>
> where $U _{\max}$ is the maximum flow speed of the system. See the details of the weakly compressible approximation in [theory_manual.pdf](./theory_manual.pdf).<br>
> ここで、 $U_ {\max}$ は系の最大の速さを表します。弱圧縮性近似の詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

---

### 2.3 Boundary and Initial Conditions / 境界条件・初期条件

#### Boundary condition / 境界条件

A free-slip condition is imposed on all wall boundaries.<br>
すべての壁面に自由滑り条件（Free-slip）を課します。

$$
\begin{aligned}
\boldsymbol{u} \cdot \boldsymbol{n} &= 0 \quad \text{on} \quad \partial \Omega, \\
\frac{\partial u}{\partial y} + \frac{\partial v}{\partial x} &= 0 \quad \text{on} \quad \partial \Omega,
\end{aligned}
$$

where $\boldsymbol{n}$ is the normal unit vector, and $\partial \Omega$ is the boundary of the domain $\Omega$.<br>
ここで、 $\boldsymbol{n}$ は単位法線ベクトル、 $\partial \Omega$ は領域 $\Omega$ の境界を表します。


#### Initial condition / 初期条件

Under the above boundary condition, the analytical solution of the incompressible Navier-Stokes equations can be obtained as follows:<br>
上記の境界条件においては、非圧縮性ナビエ・ストークス方程式の解析解が以下のように得られます。


$$
\begin{aligned}
u(x,y,t) &= A(t) \sin \left(\frac{a \pi x}{L_ {x}}\right) \cos \left(\frac{b \pi y}{L_ {y}}\right), \\
v(x,y,t) &= -A(t) \left( \frac{a L_ {y}}{b L_ {x}} \right) \cos \left(\frac{a \pi x}{L_ {x}}\right) \sin \left(\frac{b \pi y}{L_ {y}}\right), \\
p(x,y,t) &= \frac{\rho_ {0} \left(A(t)\right)^{2}}{4} \left[ \cos \left(\frac{2a \pi x}{L_ {x}}\right) + \left( \frac{a L_ {y}}{b L_ {x}} \right)^{2} \cos \left(\frac{2b \pi y}{L_ {y}}\right) \right], \\
A(t) &= A(0) \exp \left( - \nu \left( \left(\frac{a \pi}{L_ {x}}\right)^{2} + \left(\frac{b \pi}{L_ {y}}\right)^{2} \right) t \right),
\end{aligned}
$$

where $A(t)$ is the velocity amplitude, and the positive integers $a =$ `TG_A` and $b =$ `TG_B` are the number of vortices in the $x$ and $y$ directions, respectively. In this code, the initial velocity amplitude $A(0)$ is set to unity ($A(0) = U = 1$).<br>
ここで、 $A(t)$ は速度に関する振幅、正の整数 $a =$ `TG_A` および $b =$ `TG_B` はそれぞれ $x$ 方向および $y$ 方向の渦の数を表します。本コードでは、初期速度の振幅を $A(0) = U = 1$ として設定しています。

> [!NOTE]
> The derivation of the analytical solution is provided in [theory_manual.pdf](./theory_manual.pdf).<br>
> 解析解の導出は  [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

The initial velocity and pressure fields are given by the above analytical solution at $t=0$.<br>
初期速度場および圧力場として、上記の $t=0$ における解析解を与えます。

<br>

In this code, a regular particle configuration is used for the initial configuration. The initial particle spacings $\Delta x$ and $\Delta y$ along the $x$ and $y$ directions, respectively, are given by the following equations:<br>
本コードでは、初期粒子配置として規則的な配置を考えます。すなわち、初期粒子配置時における $x$ 方向および $y$ 方向の粒子間隔 $\Delta x$ および $\Delta y$ は以下のように与えられます。

$$
\Delta x = \frac{{L_ {x}}}{n_ {x}}, \quad \Delta y = \frac{{L_ {y}}}{n_ {y}},
$$

where $n_ {x}=$  `NUM_X` and $n_ {y}=$ `NUM_Y` are the numbers of particles along the $x$ and $y$ directions, respectively. This code requires that $\Delta x = \Delta y$.<br>
ここで、 $n_ {x}$ および $n_ {y}$ は初期状態における $x$ 方向および $y$ 方向の粒子数を表します。本コードでは $\Delta x = \Delta y$ とします。

---

### 2.4 Verification: Comparison with Analytical Solution / 検証: 解析解との比較

The numerical results of the velocity and pressure fields at each time step can be directly compared with the analytical solutions. This code evaluates the following quantities:<br>
各時刻における速度場および圧力場の結果は、先述の解析解と直接比較することが可能です。本解析コードでは以下の物理量を評価します。

- Time evolution of the pressure at the center of the domain $(L_ {x}/2, L_ {y}/2)$ <br>領域の中心位置 $(L_ {x}/2, L_ {y}/2)$ における圧力の時間変化

- Velocity profiles at the final step<br>最終ステップにおける速度プロファイル

<br>

In addition, this code verifies how accurately the kinetic energy can be calculated in the SPH method. The analytical solution for the kinetic energy $E_ {k}(t)$ per unit mass is given by:<br>
加えて、本コードではSPH法における運動エネルギーの計算精度も検証します。本問題における単位質量あたりの運動エネルギー $E _{k} (t)$ は以下のように与えられます。

$$
E_ {k}(t) = \frac{1}{L_ {x} L_ {y}} \int^{L_ {x}}_ {0} \int^{L_ {y}}_ {0} \frac{1}{2} \left(u^{2} + v^{2}\right) \mathrm{d}x \mathrm{d}y = \frac{\left(A(t) \right)^{2}}{8} \left( 1 + \left( \frac{a L_ {y}}{b L_ {x}} \right)^{2} \right).
$$

> [!NOTE]
> The derivation of this analytical solution is provided in [theory_manual.pdf](./theory_manual.pdf).<br>
> 導出は  [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

---

### 2.5 Time Step / 時間刻み幅

The time step $\Delta t$ is determined by the minimum of the CFL condition (restricted by the reduced speed of sound) and the momentum diffusion condition.<br>
時間刻み幅 $\Delta t$ は、CFL条件（人為的に減速された音速による制限）と運動量拡散条件のうち、より厳しい（小さい）値によって決定されます。

$$
\Delta t = \min \left( C_ {\mathrm{CFL}} \frac{\Delta x}{c}, \quad C_ {\mathrm{DIF}} \frac{(\Delta x)^{2}}{\nu}\right),
$$

where $C_ {\mathrm{CFL}} =$ `COE_CFL` and $C_ {\mathrm{DIF}} =$ `COE_DIF` are appropriate coefficients ($0 < C_ {\mathrm{CFL}}, C_ {\mathrm{DIF}} < 1$), $\Delta x$ is the particle spacing for the initial regular configuration, and $c$ is the reduced speed of sound introduced by the weakly compressible approximation.<br>
ここで、 $C_ {\mathrm{CFL}} =$ `COE_CFL` および $C_ {\mathrm{DIF}} =$ `COE_DIF` は適当な係数 ($0 < C_ {\mathrm{CFL}}, C_ {\mathrm{DIF}} < 1$)、 $\Delta x$ は初期規則配置時における粒子間隔、 $c$ は弱圧縮性近似によって人為的に減速された音速を表します。

<br>

The condition that the time step is limited by the CFL condition is expressed as:<br>
上式において、時間刻み幅がCFL条件によって律速されるという条件は以下のように表されます。

$$
Re > 0.1 \times \frac{C_ {\mathrm{CFL}}}{C_ \mathrm{DIF}} n_ {x},
$$

where the speed of sound is assumed to be $c = 10 U$. Considering $C_ {\mathrm{CFL}} / C_ {\mathrm{DIF}} = O(1)$ and a practical spatial resolution of $n_ {x} < 10^{3}$, the time step is generally limited by the CFL condition for $Re > 100$.<br>
ここで、 $c = 10 U$ を仮定しました。 $C_ {\mathrm{CFL}} / C_ {\mathrm{DIF}} = O(1)$ とし、現実的な解像度として $n_ {x} < 10^{3}$ を考慮すると、 $Re > 100$ の場合、時間刻み幅は一般にCFL条件によって律速されることが分かります。

<br>

Therefore, the required numbers of simulation steps $N_ {\mathrm{step, DIF}}$ and $N_ {\mathrm{step, AD}}$ to reach the momentum diffusion time $\tau_ {\mathrm{DIF}} = L^{2} / \nu$ and the advection time $\tau_ {\mathrm{AD}} = L / U$ for the entire system, respectively, are estimated as follows:<br>
したがって、系全体に対する拡散時間 $\tau_ {\mathrm{DIF}} = L^{2} / \nu$ あるいは系全体に対する移流時間 $\tau_ {\mathrm{AD}} = L / U$ に達するまでに必要な計算ステップ数 $N_ {\mathrm{step, DIF}}, N _{\mathrm{step, AD}}$ は以下のように見積もられます。

$$
\begin{aligned}
N_ {\mathrm{step, DIF}} &\sim \frac{\tau_ {\mathrm{DIF}}}{{\Delta t}} = \frac{10}{C_ {\mathrm{CFL}}} \times Re \times n_ {x}, \\
N_ {\mathrm{step, AD}} &\sim \frac{\tau_ {\mathrm{AD}}}{{\Delta t}} = \frac{10}{C_ {\mathrm{CFL}}} \times n_ {x}.
\end{aligned}
$$

---

### 2.6 Parameter Settings / パラメータ設定

Set up the parameters in [config.h](../../config.h) according to the following settings.  
以下のパラメータ設定を参考にして、[config.h](../../config.h) を適切に設定してください。

#### Required Settings / 必須設定（固定値）

The following parameters must be set to the specified values.  
以下のパラメータは必ずこの値に設定してください。

| Parameter<br>パラメータ | Value<br>値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `TARGET_PROBLEM` | **2** | Select the Taylor-Green Vortex<br>Taylor-Green渦を選択します |
| `U_BOUNDARY_*` | **1** | All walls must be set to Free-slip condition<br>すべての壁面を自由滑り条件に設定してください |
| `RK` | **2** or **4** | Order of the Runge-Kutta method<br>ルンゲクッタ法における次数を選択してください |
| `ZETA_RSST` | **1.0d0** | Set to unity, as the speed of sound is configured using `K_REF` described below.<br>音速の設定は `K_REF` により行うため、ここは1としてください |
| `KERNEL_TYPE` | from **1** to **5** | Select the kernel function in the SPH calculation<br>SPH計算におけるカーネル関数を指定してください |
| `SPH_MODEL` | from **1** to **6** | Select the discretization model of the SPH method<br>SPH法における離散化モデルを選択してください |
| `WALL_MODEL` | from **1** to **3** | Select the wall boundary model in the SPH method<br>SPH法における壁境界モデルを選択してください |

> [!NOTE]
> For mathematical details of the discretization and wall boundary models, see [theory_manual.pdf](./theory_manual.pdf).<br>
> 離散化モデル、壁境界モデルの数理的な詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

#### Recommended Settings / 推奨設定（変更可能）

The following parameters must also be set, but their values can be freely chosen by the user. The "Recommended Values" indicate the settings used for code verification.<br>
以下のパラメータも必ず設定する必要がありますが、具体的な値は自由に設定できます。表中の「推奨値」は、本コードの動作確認に使用した値を表します。

| Parameter<br>パラメータ | Recommended Value<br>推奨値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `SAVE_NAME` | - | Output file name (`results/SAVE_NAME/`)<br>結果の保存ファイル名を指定してください |
| `READ_NAME` | `"new"` or specified `SAVE_NAME` | Set to `"new"` for a fresh start, or use a specified `SAVE_NAME` for a restart (see [config_guide.md](./config_guide.md))<br>新規計算時は `"new"`、再計算時はその `SAVE_NAME` を入力してください（[config_guide.md](./config_guide.md) を参照） |
| `OMP_THREADS` | **8** | Number of threads for OpenMP<br>OpenMPで使用するスレッド数を指定してください |
| `LEN_X`, `LEN_Y` | **1.0d0** | System length $L$ [m] (Recommended: `LEN_X` = `LEN_Y`)<br>系の長さを設定してください（推奨設定: `LEN_X` = `LEN_Y`） |
| `NUM_X`, `NUM_Y` | **50**, **100**, **200**, or **400** | Spatial resolution (must be set to ensure isotropic spacing: $\Delta x = \Delta y$)<br>空間解像度を設定してください（$\Delta x = \Delta y$ となるように設定する必要があります） |
| `START_STEP` | **1** or **a specified step** | Set to 1 for a fresh start, or use a specified step for a restart (see [config_guide.md](./config_guide.md))<br>新規計算時は1、再計算時は特定のステップを設定してください（[config_guide.md](./config_guide.md) を参照） |
| `END_STEP` | - | Final simulation step<br>シミュレーションの最終ステップを指定してください |
| `WRITE_STEP` | - | Output interval in steps<br>出力間隔（ステップ）を指定してください |
| `COE_CFL`, `COE_DIF`| **0.5d0**, **0.2d0** | Coefficients for the time step<br>時間刻み幅に関する係数を設定してください |
| `RHO_REF` | **1.0d0** | Reference mass density $\rho_ {0}$ [m]<br>初期状態における質量密度を設定してください |
| `VIS_REF` | **1.0d-2**, **1.0d-3**, or **1.0d-4** | Reference viscosity $\eta$ [Pa s] ($\nu = \eta/\rho_ {0}$). These values correspond to $Re = 100, 1000$, and $10000$<br>粘性率（一定）を設定してください（推奨値はそれぞれ $Re = 100, 1000, 10000$ に対応します） |
| `K_REF` | **1.0d2** | Reference bulk modulus $K$ [Pa], which determines the reduced speed of sound $c = \sqrt{K/ \rho_ {0}}$<br>体積弾性率（一定）を設定してください（音速 $c = \sqrt{K/ \rho_ {0}}$ を決定します） |
| `TG_A`, `TG_B` | **1** or **2** | Number of vortices in the $X$ and $Y$ directions<br>$X$ および $Y$ 方向の渦の数を設定してください |
| `COE_H` | **1.2d0** | Coefficient of the smoothing length $h$ ($h =$ `COE_H` $\times \Delta x$)<br>スムージング長 $h$ の係数を設定してください |
| `PST_C` | **1.5d0** | Coefficient for the Particle Shifting Technique (PST)<br>粒子再配列（PST）のシフト係数を設定してください |
| `COE_DELTA_SPH` | **0.0d0** | Coefficient for the $\delta$-SPH method<br>$\delta$-SPH法の係数を設定してください |

> [!NOTE]
> - Any other parameters in [config.h](../../config.h) will be ignored.<br>
> [config.h](../../config.h) 内のその他のパラメータの値は無視されます。
> 
> - For a detailed explanation of each parameter, see [config_guide.md](./config_guide.md).<br>
> 各パラメータの詳細な意味については [config_guide.md](./config_guide.md) をご参照ください。


---

### 2.7 Output data format / 結果の出力形式

The Fortran code exports the simulation results as unformatted binary files. You can read these files using your preferred post-processing software (e.g., Python, MATLAB) or the provided Python analysis scripts.  
Fortranコードにおいて、シミュレーション結果はバイナリファイル（Unformatted binary stream）として出力されます。出力されたファイルは、PythonやMATLAB等の任意の解析ツール、または付属のPython解析スクリプトを用いて読み込むことができます。

**Output Directories and Files / 出力先とファイル構成**<br>
- `results/SAVE_NAME/config/`: <br>Contains the simulation settings (`config.h`, `parameters.csv`) and the terminal output log (`run.log`).<br>計算設定（`config.h`, `parameters.csv`）および実行ログ（`run.log`）が保存されます。

- `results/SAVE_NAME/data/`: <br>Contains the sequential snapshot data (`[step].dat`).<br>スナップショットデータ（`[step].dat`）が保存されます。

<br>

**Binary Data Format of `[step].dat` / スナップショットデータのフォーマット**<br>
Each snapshot file stores the following 1D arrays sequentially for all particles (from index `1` to `NUM_TOTAL`):  
各スナップショットファイルには、全粒子（インデックス `1` から `NUM_TOTAL`）に対する以下の1次元配列が順番にベタ書きで格納されています。

1. `ptype` (32-bit Integer / 32ビット整数)
2. `x` (64-bit Double / 64ビット浮動小数点数)
3. `y` (64-bit Double / 64ビット浮動小数点数)
4. `u` (64-bit Double / 64ビット浮動小数点数)
5. `v` (64-bit Double / 64ビット浮動小数点数)
6. `rho` (64-bit Double / 64ビット浮動小数点数)
7. `pre` (64-bit Double / 64ビット浮動小数点数)

> [!NOTE]
> For the detail of the data format, see [write_data_mod.f90](../../source/io/write_data_mod.f90).<br>
> データ形式の詳細は [write_data_mod.f90](../../source/io/write_data_mod.f90) をご参照ください。

By reading these variables sequentially across the output steps, you can evaluate the time evolution of the total kinetic energy (using `u` and `v`) and the pressure field (`pre`) to compare them with the analytical solutions.  
出力された各ステップのデータを読み込むことで、全運動エネルギー（`u` と `v` から算出）や圧力場（`pre`）の時間発展を評価し、理論的な解析解と比較検証を行うことができます。

---

<br>

## 3. Lid-driven Cavity Flow / キャビティ流れ

### 3.1 Overview / 概要

This test simulates the flow of a viscous fluid in a closed rectangular domain driven by the top wall moving at a constant velocity $U_ {\mathrm{top}}$. It is a standard benchmark widely used to verify the stability and accuracy in fluid simulation methods.<br>

本テストでは、一定速度 $U_ {\mathrm{top}}$ で移動する上部壁によって駆動される矩形領域内の粘性流体の流れをシミュレーションします。本テストは、流体シミュレーション手法の精度や安定性を検証するための標準的なベンチマークとして広く利用されています。

---

### 3.2 Governing Equation / 支配方程式

The governing equations are the incompressible Navier-Stokes equations as follows:<br>
支配方程式は、以下の非圧縮性ナビエ・ストークス方程式です。

$$
\begin{aligned}
\nabla \cdot \boldsymbol{u} &= 0, \\
\frac{\mathrm{D} \boldsymbol{u}}{\mathrm{D} t} &= -\frac{1}{\rho_ {0}} \nabla p + \nu \nabla^{2} \boldsymbol{u},
\end{aligned}
$$

where $\mathrm{D} / \mathrm{D} t$ is the material derivative, $\boldsymbol{u} = (u, v)$ is the velocity vector, $t$ is the time, $p$ is the pressure, $\rho_ {0}$ is the reference density, and $\nu$ is the kinematic viscosity. The computational domain is a rectangular region $\Omega = [0, L_ {x}] \times [0, L_ {y}]$. <br>
ここで、 $\mathrm{D} / \mathrm{D} t$ は物質微分、 $\boldsymbol{u} = (u, v)$ は速度ベクトル、 $t$ は時間、 $p$ は圧力、 $\rho_ {0}$ は基準密度、 $\nu$ は動粘性率を表します。計算領域として矩形領域 $\Omega = [0, L_ {x}] \times [0, L_ {y}]$ を考えます。

<br>

The flow is characterized only by the Reynolds number $Re$:<br>
流れの特性はレイノルズ数 $Re$ のみによって特徴付けられます。

$$
Re = \frac{LU}{\nu},
$$

where $L$ is the characteristic length, and $U$ is the characteristic velocity. In this code, $L = L_{x}$ and $U = U_ {\mathrm{top}}$.<br>
ここで、 $L$ は代表長さ、 $U$ は代表速度を表します。本コードでは $L = L_ {x}, U = U_{\mathrm{top}}$ としています。


> [!IMPORTANT]
> This code solves the governing equations using the weakly compressible approximation (e.g., [[2]](#morris-1997)). Under this approximation, the governing equations are expressed as follows:<br>
> 本コードでは弱圧縮性近似 (e.g., [[2]](#morris-1997)) を用いて支配方程式を解きます。このとき、支配方程式は以下のように近似されます。
>
> $$
> \begin{aligned}
> \frac{\mathrm{D} \rho}{\mathrm{D} t} &= - \rho \nabla \cdot \bm{u}, \\
> \frac{\mathrm{D} \boldsymbol{u}}{\mathrm{D} t} &= -\frac{1}{\rho} \nabla p + \nu \nabla^{2} \boldsymbol{u}, \\
> p &= c^{2} (\rho - \rho_ {0}),
> \end{aligned}
> $$
>
> where $\rho$ is the density, and $c$ is the reduced speed of sound, which should satisfy the following condition to keep the density variations below 1%:<br>
> ここで、 $\rho$ は密度、 $c$ は減速された音速を表します。音速は密度変動を1%未満に抑えるために、通常以下の条件を満たすように設定されます。
> 
> $$
> c \geq 10 U_ {\max},
> $$
>
> where $U _{\max}$ is the maximum flow speed of the system. See the details of the weakly compressible approximation in [theory_manual.pdf](./theory_manual.pdf).<br>
> ここで、 $U_ {\max}$ は系の最大の速さを表します。弱圧縮性近似の詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

---

### 3.3 Boundary and Initial Conditions / 境界条件・初期条件

#### Boundary condition / 境界条件

A moving wall condition is imposed on the top wall boundary, and the no-slip conditions are imposed on the bottom, left, and right wall boundaries.<br>
上壁面に移動壁条件を課し、下・左・右壁面に滑りなし条件（No-slip）を課します。

$$
\begin{aligned}
u &= U_{\mathrm{top}}, \quad v = 0 \quad \text{on the top boundary}, \\
u &= 0, \quad v = 0 \quad \text{on the bottom, left, and right boundaries},
\end{aligned}
$$

where $U_ {\mathrm{top}} =$ `U_TOP` is the constant horizontal velocity of the top wall.<br>
ここで、 $U_ {\mathrm{top}} =$ `U_TOP` は上部壁の一定の水平速度を表します。

#### Initial condition / 初期条件

The fluid is initially at rest. The initial velocity and pressure fields are given by:<br>
初期条件として静止状態を考えます。初期速度場および圧力場として、以下を与えます。

$$
\begin{aligned}
u(x,y,0) &= 0, \\
v(x,y,0) &= 0, \\
p(x,y,0) &= 0.
\end{aligned}
$$

In this code, a regular particle configuration is used for the initial configuration. The initial particle spacings $\Delta x$ and $\Delta y$ along the $x$ and $y$ directions, respectively, are given by the following equations:<br>
本コードでは、初期粒子配置として規則的な配置を考えます。すなわち、初期粒子配置時における $x$ 方向および $y$ 方向の粒子間隔 $\Delta x$ および $\Delta y$ は以下のように与えられます。

$$
\Delta x = \frac{{L_ {x}}}{n_ {x}}, \quad \Delta y = \frac{{L_ {y}}}{n_ {y}},
$$

where $n_ {x}=$  `NUM_X` and $n_ {y}=$ `NUM_Y` are the numbers of particles along the $x$ and $y$ directions, respectively. This code requires that $\Delta x = \Delta y$.<br>
ここで、 $n_ {x}$ および $n_ {y}$ は初期状態における $x$ 方向および $y$ 方向の粒子数を表します。本コードでは $\Delta x = \Delta y$ とします。

---

### 3.4 Verification: Comparison with Reference Data / 検証: 参照解との比較

The numerical results of the steady-state velocity profiles can be directly compared with the well-known reference solution given by Ghia et al. (1982) [[3]](#ghia-1982). This code evaluates the following quantities:<br>
本コードでは、定常状態における速度プロファイルの数値解を、標準的な参照解として知られる Ghia et al. (1982)  [[3]](#ghia-1982) と直接比較します。本コードでは以下の物理量を比較します。

- $u$-velocity profile along the vertical centerline $x = L_ {x}/2$ <br>$x = L_ {x}/2$ 上における速度の $u$ 成分プロファイル
- $v$-velocity profile along the horizontal centerline $y = L_ {y}/2$ <br>$y = L_ {y}/2$ 上における速度の $v$ 成分プロファイル

<br>

In addition, this code verifies how the system reaches a steady state by evaluating the time history of the Root Mean Square (RMS) velocity $U_ {\mathrm{rms}}$.<br>
加えて、本コードでは系の二乗平均平方根（RMS）速度 $U_ {\mathrm{rms}}$ の時間変化を評価することで、系が定常状態へ遷移する過程を検証します。

$$
U_ {\mathrm{rms}} = \sqrt{ \frac{1}{L_ x L_ y} \int_{\Omega} |\boldsymbol{u} |^2 \mathrm{d}\Omega } \approx \sqrt{\frac{1}{N} \sum^{N}_ {i=1} \left(u^{2}_ {i} + v^{2}_ {i}\right)}
$$

---

### 3.5 Time Step / 時間刻み幅

The time step $\Delta t$ is determined by the minimum of the CFL condition (restricted by the reduced speed of sound) and the momentum diffusion condition.<br>
時間刻み幅 $\Delta t$ は、CFL条件（人為的に減速された音速による制限）と運動量拡散条件のうち、より厳しい（小さい）値によって決定されます。

$$
\Delta t = \min \left( C_ {\mathrm{CFL}} \frac{\Delta x}{c}, \quad C_ {\mathrm{DIF}} \frac{(\Delta x)^{2}}{\nu}\right),
$$

where $C_ {\mathrm{CFL}} =$ `COE_CFL` and $C_ {\mathrm{DIF}} =$ `COE_DIF` are appropriate coefficients ($0 < C_ {\mathrm{CFL}}, C_ {\mathrm{DIF}} < 1$), $\Delta x$ is the particle spacing for the initial regular configuration, and $c$ is the reduced speed of sound introduced by the weakly compressible approximation.<br>
ここで、 $C_ {\mathrm{CFL}} =$ `COE_CFL` および $C_ {\mathrm{DIF}} =$ `COE_DIF` は適当な係数 ($0 < C_ {\mathrm{CFL}}, C_ {\mathrm{DIF}} < 1$)、 $\Delta x$ は初期規則配置時における粒子間隔、 $c$ は弱圧縮性近似によって人為的に減速された音速を表します。

<br>

The condition that the time step is limited by the CFL condition is expressed as:<br>
上式において、時間刻み幅がCFL条件によって律速されるという条件は以下のように表されます。

$$
Re > 0.1 \times \frac{C_ {\mathrm{CFL}}}{C_ \mathrm{DIF}} n_ {x},
$$

where the speed of sound is assumed to be $c = 10 U_ {\mathrm{top}}$. Considering $C_ {\mathrm{CFL}} / C_ {\mathrm{DIF}} = O(1)$ and a practical spatial resolution of $n_ {x} < 10^{3}$, the time step is generally limited by the CFL condition for $Re > 100$.<br>
ここで、 $c = 10 U_ {\mathrm{top}}$ と仮定しました。 $C_ {\mathrm{CFL}} / C_ {\mathrm{DIF}} = O(1)$ とし、現実的な解像度として $n_ {x} < 10^{3}$ を考慮すると、 $Re > 100$ の場合、時間刻み幅は一般にCFL条件によって律速されることが分かります。

<br>

Therefore, the required numbers of simulation steps $N_ {\mathrm{step, DIF}}$ and $N_ {\mathrm{step, AD}}$ to reach the momentum diffusion time $\tau_ {\mathrm{DIF}} = L^{2} / \nu$ and the advection time $\tau_ {\mathrm{AD}} = L / U_{\mathrm{top}}$ for the entire system, respectively, are estimated as follows:<br>
したがって、系全体に対する拡散時間 $\tau_ {\mathrm{DIF}} = L^{2} / \nu$ あるいは系全体に対する移流時間 $\tau_ {\mathrm{AD}} = L / U_{\mathrm{top}}$ に達するまでに必要な計算ステップ数 $N_ {\mathrm{step, DIF}}, N _{\mathrm{step, AD}}$ は以下のように見積もられます。

$$
\begin{aligned}
N_ {\mathrm{step, DIF}} &\sim \frac{\tau_ {\mathrm{DIF}}}{{\Delta t}} = \frac{10}{C_ {\mathrm{CFL}}} \times Re \times n_ {x}, \\
N_ {\mathrm{step, AD}} &\sim \frac{\tau_ {\mathrm{AD}}}{{\Delta t}} = \frac{10}{C_ {\mathrm{CFL}}} \times n_ {x}.
\end{aligned}
$$

---

### 3.6 Parameter Settings / パラメータ設定

Set up the parameters in [config.h](../../config.h) according to the following settings.  
以下のパラメータ設定を参考にして、[config.h](../../config.h) を適切に設定してください。

#### Required Settings / 必須設定（固定値）

The following parameters must be set to the specified values.  
以下のパラメータは必ずこの値に設定してください。

| Parameter<br>パラメータ | Value<br>値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `TARGET_PROBLEM` | **3** | Select the Lid-driven Cavity Flow<br>キャビティ流れを選択します |
| `U_BOUNDARY_TOP` | **3** | The top wall must be set to the moving wall condition<br>上部壁面を移動壁条件に設定してください |
| `U_BOUNDARY_BOTTOM`<br>`U_BOUNDARY_LEFT`<br>`U_BOUNDARY_RIGHT` | **2** | The bottom, left, and right walls must be set to the No-slip condition<br>下・左・右壁面を滑りなし条件に設定してください |
| `RK` | **2** or **4** | Order of the Runge-Kutta method<br>ルンゲクッタ法における次数を選択してください |
| `ZETA_RSST` | **1.0d0** | Set to unity, as the speed of sound is configured using `K_REF` described below.<br>音速の設定は `K_REF` により行うため、ここは1としてください |
| `KERNEL_TYPE` | from **1** to **5** | Select the kernel function in the SPH calculation<br>SPH計算におけるカーネル関数を指定してください |
| `SPH_MODEL` | from **1** to **6** | Select the discretization model of the SPH method<br>SPH法における離散化モデルを選択してください |
| `WALL_MODEL` | from **1** to **3** | Select the wall boundary model in the SPH method<br>SPH法における壁境界モデルを選択してください |

> [!NOTE]
> For mathematical details of the discretization and wall boundary models, see [theory_manual.pdf](./theory_manual.pdf).<br>
> 離散化モデル、壁境界モデルの数理的な詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

#### Recommended Settings / 推奨設定（変更可能）

The following parameters must also be set, but their values can be freely chosen by the user. The "Recommended Values" indicate the settings used for code verification.  
以下のパラメータも必ず設定する必要がありますが、具体的な値は自由に設定できます。表中の「推奨値」は、本コードの動作確認に使用した値を表します。

| Parameter<br>パラメータ | Recommended Value<br>推奨値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `U_TOP` | **1.0d0** | Constant velocity at the top wall $U_ {\mathrm{top}}$ [m s$^{-1}$]<br>上壁面における一定速度を指定してください |
| `SAVE_NAME` | - | Output file name (`results/SAVE_NAME/`)<br>結果の保存ファイル名を指定してください |
| `READ_NAME` | `"new"` or specified `SAVE_NAME` | Set to `"new"` for a fresh start, or use a specified `SAVE_NAME` for a restart (see [config_guide.md](./config_guide.md))<br>新規計算時は `"new"`、再計算時はその `SAVE_NAME` を入力してください（[config_guide.md](./config_guide.md) を参照） |
| `OMP_THREADS` | **8** | Number of threads for OpenMP<br>OpenMPで使用するスレッド数を指定してください |
| `LEN_X`, `LEN_Y` | **1.0d0** | System length (**Must be set to `LEN_X` = `LEN_Y`** to compare with the reference solution by Ghia et al. (1982))  [[3]](#ghia-1982)<br>系の長さを設定してください（Ghia et al. (1982) [[3]](#ghia-1982) の参照解と比較するために、**必ず `LEN_X` = `LEN_Y`** （正方形）と設定してください） |
| `NUM_X`, `NUM_Y` | **50**, **100**, **200**, or **400** | Spatial resolution (must be set to ensure isotropic spacing: $\Delta x = \Delta y$)<br>空間解像度を設定してください（$\Delta x = \Delta y$ となるように設定する必要があります） |
| `START_STEP` | **1** or **a specified step** | Set to 1 for a fresh start, or use a specified step for a restart (see [config_guide.md](./config_guide.md))<br>新規計算時は1、再計算時は特定のステップを設定してください（[config_guide.md](./config_guide.md) を参照） |
| `END_STEP` | - | Final simulation step (Set a sufficiently large value to reach a steady state. See [Section 3.5](#35-time-step--時間刻み幅))<br>シミュレーションの最終ステップを指定してください（定常状態に達するよう十分に大きな値を設定してください。[Section 3.5](#35-time-step--時間刻み幅)を参照） |
| `WRITE_STEP` | - | Output interval in steps<br>出力間隔（ステップ）を指定してください |
| `COE_CFL`, `COE_DIF`| **0.5d0**, **0.2d0** | Coefficients for the time step<br>時間刻み幅に関する係数を設定してください |
| `RHO_REF` | **1.0d0** | Reference mass density $\rho_ {0}$ [kg m$^{-3}$]<br>初期状態における質量密度を設定してください |
| `VIS_REF` | **1.0d-2**, **1.0d-3**, or **1.0d-4** | Reference viscosity $\eta$ [Pa s] ($\nu = \eta/\rho_ {0}$). These values correspond to $Re = 100, 1000$, and $10000$<br>粘性率（一定）を設定してください（推奨値はそれぞれ $Re = 100, 1000, 10000$ に対応します） |
| `K_REF` | **1.0d2** | Reference bulk modulus $K$ [Pa], which determines the reduced speed of sound $c = \sqrt{K/ \rho_ {0}}$<br>体積弾性率（一定）を設定してください（音速 $c = \sqrt{K/ \rho_ {0}}$ を決定します） |
| `COE_H` | **1.2d0** | Coefficient of the smoothing length $h$ ($h =$ `COE_H` $\times \Delta x$)<br>スムージング長 $h$ の係数を設定してください |
| `PST_C` | **1.5d0** | Coefficient for the Particle Shifting Technique (PST)<br>粒子再配列（PST）のシフト係数を設定してください |
| `COE_DELTA_SPH` | **0.1d0** | Coefficient for the $\delta$-SPH method<br>$\delta$-SPH法の係数を設定してください |

> [!NOTE]
> - Any other parameters in [config.h](../../config.h) will be ignored.<br>
> [config.h](../../config.h) 内のその他のパラメータの値は無視されます。
> 
> - For a detailed explanation of each parameter, see [config_guide.md](./config_guide.md).<br>
> 各パラメータの詳細な意味については [config_guide.md](./config_guide.md) をご参照ください
>
> -  In this code, the reference solution of Ghia et al. (1982) [[3]](#ghia-1982) is available only for $Re = 100, 1000$, and $10000$. While simulations at other Reynolds numbers will run normally, the comparative analysis with the reference solution will be skipped. If you want to compare results at other Reynolds numbers, please create a custom CSV file in [/analysis/benchmarks/](../../analysis/benchmarks/) formatted similarly to the available ones, using the tables from the original paper [[3]](#ghia-1982).<br>
> 本コードでは、$Re = 100, 1000, 10000$ に対応する Ghia et al. (1982) [[3]](#ghia-1982) の参照解を用意しています。これら以外のレイノルズ数でもシミュレーション自体は正常に実行されますが、解析において参照解との比較はスキップされます。他のレイノルズ数で比較を行いたい場合は、元論文 [[3]](#ghia-1982) の表を参照し、[/analysis/benchmarks/](../../analysis/benchmarks/) 内の既存のデータファイルと同様のフォーマットでCSVファイルを作成してください。

---

### 3.7 Output data format / 結果の出力形式

The Fortran code exports the simulation results as unformatted binary files. You can read these files using your preferred post-processing software (e.g., Python, MATLAB) or the provided Python analysis scripts.  
Fortranコードにおいて、シミュレーション結果はバイナリファイル（Unformatted binary stream）として出力されます。出力されたファイルは、PythonやMATLAB等の任意の解析ツール、または付属のPython解析スクリプトを用いて読み込むことができます。

**Output Directories and Files / 出力先とファイル構成**<br>
- `results/SAVE_NAME/config/`: <br>Contains the simulation settings (`config.h`, `parameters.csv`) and the terminal output log (`run.log`).<br>計算設定（`config.h`, `parameters.csv`）および実行ログ（`run.log`）が保存されます。

- `results/SAVE_NAME/data/`: <br>Contains the sequential snapshot data (`[step].dat`).<br>スナップショットデータ（`[step].dat`）が保存されます。

<br>

**Binary Data Format of `[step].dat` / スナップショットデータのフォーマット**<br>
Each snapshot file stores the following 1D arrays sequentially for all particles (from index `1` to `NUM_TOTAL`):  
各スナップショットファイルには、全粒子（インデックス `1` から `NUM_TOTAL`）に対する以下の1次元配列が順番にベタ書きで格納されています。

1. `ptype` (32-bit Integer / 32ビット整数)
2. `x` (64-bit Double / 64ビット浮動小数点数)
3. `y` (64-bit Double / 64ビット浮動小数点数)
4. `u` (64-bit Double / 64ビット浮動小数点数)
5. `v` (64-bit Double / 64ビット浮動小数点数)
6. `rho` (64-bit Double / 64ビット浮動小数点数)
7. `pre` (64-bit Double / 64ビット浮動小数点数)

> [!NOTE]
> For the detail of the data format, see [write_data_mod.f90](../../source/io/write_data_mod.f90).<br>
> データ形式の詳細は [write_data_mod.f90](../../source/io/write_data_mod.f90) をご参照ください。

By analyzing these fields across the outputs, you can calculate the history of the RMS velocity to confirm that the system has reached a steady state. At the final step, you can extract the velocity profiles (`u`, `v`) along the centerlines and compare them with the reference data.  
これらのデータを解析することで、RMS速度の時間履歴から系が定常状態に達したことを確認できます。また、最終ステップのデータから速度プロファイル（`u`, `v`）を抽出することで、参照解と比較することができます。

---

## 4. Boussinesq Convection (bottom-heated) / ブシネスク熱対流 (底面加熱)

### 4.1 Overview / 概要

This test simulates the Boussinesq convection of a viscous fluid in a closed rectangular domain heated from below and cooled from above (Rayleigh-Bénard convection). By coupling the weakly compressible approximation (e.g., [[2]](#morris-1997)), which is theoretically equivalent to the Reduced Speed of Sound Technique (RSST) [[4]](#hotta-2012), and the Variable Inertia Method (VIM) [[5]](#takeyama-2017), this code is capable of efficiently handling a wide range of fluids, from fluids with low Prandtl numbers such as air, to fluids with extremely high Prandtl numbers such as the Earth's mantle, using an explicit time integration scheme.<br>

本テストでは、下面加熱・上面冷却により駆動される矩形領域内のブシネスク対流（レイリー・ベナール対流）をシミュレーションします。本コードは、弱圧縮性近似 (e.g., [[2]](#morris-1997))（これは音速抑制法 (RSST) [[4]](#hotta-2012) と理論的に等価）と慣性変化法（VIM）[[5]](#takeyama-2017) を統合することで、空気のような低プラントル数の流体から、地球マントルのような極端な高プラントル数の流体に至るまで、陽解法を用いて効率的に取り扱うことができます。

---

### 4.2 Governing Equation / 支配方程式

The governing equations are the Boussinesq-approximated Navier-Stokes equations and the energy equation. To accelerate the explicit calculation for low-Mach and high-Prandtl number flows, the RSST parameter $\zeta$ and the VIM parameter $\xi$ are introduced into the continuity and momentum equations. The modified equations are expressed as follows:<br>
支配方程式は、ブシネスク近似が適用されたナビエ・ストークス方程式およびエネルギー方程式です。ただし、本コードでは低マッハ数（かつ高プラントル数）な熱対流系を陽解法を用いて高速に解くために、連続の式および運動方程式にRSSTパラメータ $\zeta$ とVIMパラメータ $\xi$ を導入します。

$$
\begin{aligned}
\zeta^2 \frac{\mathrm{D} \rho}{\mathrm{D} t} &= - \rho \nabla \cdot \boldsymbol{u}, \\
\xi^2 \frac{\mathrm{D} \boldsymbol{u}}{\mathrm{D} t} &= -\frac{1}{\rho} \nabla p + \nu \nabla^{2} \boldsymbol{u} + \alpha_{\mathrm{th}} T' g \hat{\boldsymbol{e}}_ y, \\
\frac{\mathrm{D} T}{\mathrm{D} t} &= \kappa \nabla^{2} T, \\
p &= c^2 (\rho - \rho_ {0}),
\end{aligned}
$$

where $\rho$ is the density ($\rho_ {0}$ is the reference density), $\boldsymbol{u} = (u, v)$ is the velocity vector, $p$ is the pressure, $\nu$ is the kinematic viscosity, $\alpha_ {\mathrm{th}}$ is the thermal expansion coefficient, $T$ is the temperature, $T'$ is the temperature difference from the reference temperature $T_ 0$ (defined as the average temperature $T_ 0 \coloneqq (T_ H + T_ C) / 2$), $g$ is the gravitational acceleration, $\hat{\boldsymbol{e}}_ y$ is the unit vector in the $y$-direction, and $\kappa$ is the thermal diffusivity, respectively. The actual physical sound speed is given by $c = \sqrt{K/\rho_ 0}$ ($K$ is the bulk modulus), while the effective sound speed in the numerical simulation is reduced to $c_ {\mathrm{eff}} = c / (\zeta \xi)$.<br>
ここで、 $\rho$ は密度（$\rho_ {0}$ は基準密度）、 $\boldsymbol{u} = (u, v)$ は速度ベクトル、 $p$ は圧力、 $\nu$ は動粘性率、 $\alpha_ {\mathrm{th}}$ は熱膨張率、 $T$ は温度、 $T'$ は基準温度 $T_ 0$ （平均温度 $T_ 0 \coloneqq (T_ H + T_ C) / 2$ として定義）との温度差、 $g$ は重力加速度、 $\hat{\boldsymbol{e}}_ y$ は $y$ 方向の単位ベクトル、 $\kappa$ は熱拡散率をそれぞれ表します。実際の物理的な音速は $c = \sqrt{K/\rho_ 0}$ （ $K$ は体積弾性率）で与えられますが、数値計算上の実効的な音速は $c_ {\mathrm{eff}} = c / (\zeta \xi)$ へと低減されます。

> [!NOTE]
> Details of the RSST and VIM are provided in [theory_manual.pdf](./theory_manual.pdf).  
> RSST および VIM の詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

The computational domain is a rectangular region $\Omega = [0, L_ {x}] \times [0, L_ {y}]$. <br>
計算領域として矩形領域 $\Omega = [0, L_ {x}] \times [0, L_ {y}]$ を考えます。<br>

The flow is characterized by the Rayleigh number $Ra$ and the Prandtl number $Pr$:  
流れの特性は、レイリー数 $Ra$ とプラントル数 $Pr$ によって特徴付けられます。

$$
Ra = \frac{\alpha_ {\mathrm{th}} \Delta T g L_y^3}{\nu \kappa}, \quad Pr = \frac{\nu}{\kappa},
$$

where $\Delta T = T_ H - T_ C$ is the temperature difference between the hot bottom wall ($T_ H$) and the cold top wall ($T_ C$), and $L_y$ is the vertical height of the domain.  
ここで、 $\Delta T = T_ H - T_ C$ は下部の高温壁（$T_ H$）と上部の低温壁（$T_ C$）の温度差、 $L_ y$ は領域の鉛直高さを表します。

---

### 4.3 Boundary and Initial Conditions / 境界条件・初期条件

#### Boundary condition / 境界条件

The top and bottom boundaries are isothermal, while the left and right boundaries are adiabatic (zero heat flux).   
上・下部壁面は等温条件（固定温度）、左・右部壁面は断熱条件（熱流束ゼロ）に設定します。

$$
\begin{aligned}
T(x, 0, t) &= T_ H, \\
T(x, L_ {y}, t) &= T_ C, \\
\frac{\partial T}{\partial x} \bigg|_ {x=0,L_ {x}} &= 0. 
\end{aligned}
$$

For velocity, appropriate boundary conditions (free-slip or no-slip) should be chosen depending on the target reference benchmark. For example, the following benchmark tests are widely known:<br>
速度については、比較対象とするベンチマークに応じて適切な境界条件（自由滑り条件または滑りなし条件）を選択してください。例えば、以下のベンチマークテストが知られています。

- Air convection ($Pr=0.71$) under the **no-slip condition**: Ouertatani et al. (2008) [[6]](#ouertatani-2008)
- Mantle convection ($Pr > 10^{23}$) under the **free-slip condition**: Blankenbach et al. (1989) [[7]](#blankenbach-1989)

#### Initial condition / 初期条件

The fluid is initially at rest. The initial temperature follows a linear conductive profile with a small perturbation applied near the bottom wall ($y \leq 0.1 L_ y$) to induce convection.  
初期条件として静止状態を考えます。初期温度場は熱伝導解（線形プロファイル）とし、対流を誘起するために下部壁面近傍（$y \leq 0.1 L_ y$）に微小な正弦波の温度摂動を与えています。

$$
\begin{aligned}
\boldsymbol{u}(x,y,0) &= 0, \\
p(x,y,0) &= 0, \\ 
T(x,y,0) &= -\frac{\Delta T}{L_y} y + T_H + \delta T,
\end{aligned}
$$

where the perturbation is given by:  
ここで、温度摂動として次式を与えています。

$$
\delta T = 
\begin{cases}
0.01 \Delta T \cos(\pi x / L_ x) & (y \leq 0.1 L_ y) \\
0 & (y > 0.1 L_ y)
\end{cases}.
$$

In this code, a regular particle configuration is used for the initial configuration. The initial particle spacings $\Delta x$ and $\Delta y$ along the $x$ and $y$ directions, respectively, are given by the following equations:<br>
本コードでは、初期粒子配置として規則的な配置を考えます。すなわち、初期粒子配置時における $x$ 方向および $y$ 方向の粒子間隔 $\Delta x$ および $\Delta y$ は以下のように与えられます。

$$
\Delta x = \frac{{L_ {x}}}{n_ {x}}, \quad \Delta y = \frac{{L_ {y}}}{n_ {y}},
$$

where $n_ {x}=$  `NUM_X` and $n_ {y}=$ `NUM_Y` are the numbers of particles along the $x$ and $y$ directions, respectively. This code requires that $\Delta x = \Delta y$.<br>
ここで、 $n_ {x}$ および $n_ {y}$ は初期状態における $x$ 方向および $y$ 方向の粒子数を表します。本コードでは $\Delta x = \Delta y$ とします。

---

### 4.4 Verification: Comparison with Reference Data / 検証: 参照解との比較

The steady-state behavior of the thermal convection can be evaluated using the volume-averaged Root Mean Square (RMS) velocity and the average Nusselt numbers at the top and bottom walls:  
熱対流の定常状態における振る舞いは、系全体の二乗平均平方根（RMS）速度と、上・下部壁面における平均ヌッセルト数を用いて評価されます。

$$
\begin{aligned}
U_ {\mathrm{rms}} &= \sqrt{ \frac{1}{L_ x L_ y} \int_{\Omega} |\boldsymbol{u} |^2 \mathrm{d}\Omega }, \\
Nu &= - \frac{1}{L_ x} \int_{0}^{L_ x} \left( \frac{L_ y}{\Delta T} \frac{\partial T}{\partial y} \right) \mathrm{d} x.
\end{aligned}
$$

The analysis script calculates these values and outputs them to `steady_state_results.csv`. To verify your simulation, please visually compare these output values with the standard reference solutions provided by Ouertatani et al. (2008) [[6]](#ouertatani-2008) for air ($Pr=0.71$) or Blankenbach et al. (1989) [[7]](#blankenbach-1989) for mantle convection ($Pr \to \infty$). Error calculations are not performed automatically.  
解析スクリプトは上記の値を計算し、`steady_state_results.csv` に出力します。空気（$Pr=0.71$）の対流の場合は Ouertatani et al. (2008) [[6]](#ouertatani-2008)、マントル対流（$Pr \to \infty$）の場合は Blankenbach et al. (1989) [[7]](#blankenbach-1989) の論文中の表と目視で比較してください。本プログラムではそれらの誤差計算は自動的に行われません。

---

### 4.5 Time Step / 時間刻み幅

The time step $\Delta t$ is determined by the minimum of the relaxed CFL condition, relaxed momentum diffusion condition, and thermal diffusion condition. <br>
時間刻み幅 $\Delta t$ は、緩和されたCFL条件、緩和された運動量拡散条件、および熱拡散条件のうち、最も厳しい（小さい）値によって決定されます。 

$$
\Delta t = \min \left( \zeta \xi C_ {\mathrm{CFL}} \frac{\Delta x}{c}, \quad \xi^2 C_ {\mathrm{DIF}} \frac{(\Delta x)^2}{\nu}, \quad C_ {\mathrm{DIF}} \frac{(\Delta x)^2}{\kappa} \right),
$$

where $C_ {\mathrm{CFL}} =$ `COE_CFL` and $C_ {\mathrm{DIF}} =$ `COE_DIF` are appropriate coefficients ($0 < C_ {\mathrm{CFL}}, C_ {\mathrm{DIF}} < 1$), $\Delta x$ is the particle spacing for the initial regular configuration, $c = \sqrt{K / \rho_ 0}$ is the physical sound speed, and $\zeta =$ `ZETA_RSST` and $\xi =$ `XI_VIM` are the relaxation parameters. <br>
ここで、 $C_ {\mathrm{CFL}} =$ `COE_CFL` および $C_ {\mathrm{DIF}} =$ `COE_DIF` は適当な係数 ($0 < C_ {\mathrm{CFL}}, C_ {\mathrm{DIF}} < 1$)、 $\Delta x$ は初期規則配置時における粒子間隔、 $c = \sqrt{K / \rho_ 0}$ は物理的な音速、 $\zeta =$ `ZETA_RSST` および $\xi =$ `XI_VIM` は緩和パラメータをそれぞれ表します。

Since the thermal diffusion time for the entire system is $\tau _{\mathrm{TH}} = L^{2}_ y / \kappa$, the required number of simulation steps $N_{\mathrm{step}}$ for the system to reach a thermal equilibrium (steady state) is estimated as follows:<br>
系全体に対する熱拡散時間は $\tau_ {\mathrm{TH}} = L^{2}_ y / \kappa$ であるため、系全体が熱的な平衡状態（定常状態）に至るまでに必要な計算ステップ数 $N_{\mathrm{step}}$ は以下のように見積もられます。

$$
N_{\mathrm{step}} \sim \frac{\tau_{\mathrm{TH}}}{\Delta t} = \frac{L_y^2 / \kappa}{\Delta t}.
$$

#### Setting of Relaxation Parameters / 緩和パラメータの設定

The setting of the relaxation parameters $\zeta$ and $\xi$ depends strongly on whether the target system is a low-Prandtl-number fluid (e.g., air) or a high-Prandtl-number fluid (e.g., Earth's mantle). <br>
緩和パラメータ $\zeta$ と $\xi$ の設定は、対象が空気のような低プラントル数流体か、マントルのような高プラントル数流体かによって大きく異なります。 

**1. For Low-Prandtl-Number Fluids (e.g., Air) / 低プラントル数流体（空気など）の場合**:<br>
For low-Pr fluids, the flow is inertia-dominated. To artificially reduce the speed of sound, set $\zeta > 1$ while keeping $\xi = 1$. The characteristic velocity $U$ can be approximated by the free-fall velocity $U \sim \sqrt{\alpha_ {\mathrm{th}} \Delta T g L_ y}$. Based on this, determine $\zeta$ to satisfy the Mach number condition $M = U / (c/\zeta) < 0.1$.<br>
低Pr数流体では慣性が支配的です。音速を人為的に遅くするために、 $\zeta > 1$ と設定します（ただし、慣性変化法は使用しないため、 $\xi = 1$ と固定してください）。ここで、代表速度 $U$ は自由落下速度 $U \sim \sqrt{\alpha_ {\mathrm{th}} \Delta T g L_ y}$ によって近似できます。これをもとに、マッハ数条件 $M = U / (c/\zeta) < 0.1$ を満たすように $\zeta$ を決定してください。
> [!NOTE]
> Since the actual maximum velocity is determined as a result of the simulation, it must be verified after simulation whether the Mach number condition is satisfied.<br>
> 実際の最大速度はシミュレーションの結果として求まるため、シミュレーション終了後に、マッハ数条件が本当に満たされているかどうかを確認してください。

**2. For High-Prandtl-Number Fluids (e.g., Mantle) / 高プラントル数流体（マントルなど）の場合:**<br>
For high-Pr fluids, not only the speed of sound but also the extremely short viscous diffusion time severely restricts the time step. To relax both restrictions, the VIM parameter $\xi$ is introduced. By setting $\xi > 1$, the effective speed of sound becomes $\zeta \xi$ times slower, relaxing the CFL condition by a factor of $\zeta \xi$. Furthermore, the time step limit based on the viscous diffusion time is relaxed by a factor of $\xi^2$. Since determining the optimal values for these parameters involves arbitrariness and often requires preliminary numerical experiments, refer to Shobuzako's Ph.D. thesis [[8]](#shobuzako-2025) for specific determination methods.<br>
マントルなどの高Pr数流体では、音速に加えて、極めて短い粘性拡散時間によって時間刻み幅が制限されます。この両方の制限を緩和するためにVIMパラメータ $\xi$ を導入します。 $\xi > 1$ と設定することで、実効的な音速は $\zeta \xi$ 倍遅くなり、結果としてCFL条件は $\zeta \xi$ 倍緩くなります。さらに、粘性拡散時間による制限は $\xi^2$ 倍緩くなります。これらのパラメータの決定には任意性が含まれ、事前の数値実験が必要になる場合が多いため、具体的な決定法については菖蒲迫の博士論文 [[8]](#shobuzako-2025) を参照してください。 

---

### 4.6 Parameter Settings / パラメータ設定

Set up the parameters in [config.h](../../config.h) according to the following settings.  
以下のパラメータ設定を参考にして、[config.h](../../config.h) を適切に設定してください。

#### Required Settings / 必須設定（固定値）

The following parameters must be set to the specified values.  
以下のパラメータは必ずこの値に設定してください。

| Parameter<br>パラメータ | Value<br>値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `TARGET_PROBLEM` | **4** | Select the Boussinesq Convection<br>ブシネスク熱対流を選択します |
| `TEM_BOUNDARY_TOP`<br>`TEM_BOUNDARY_BOTTOM` | **1** | Top and bottom walls must be **Isothermal** (constant temperature)<br>上・下部壁面を等温条件（固定温度）に設定してください |
| `TEM_BOUNDARY_LEFT`<br>`TEM_BOUNDARY_RIGHT` | **2** | Left and right walls must be **Adiabatic** (zero heat flux)<br>左・右部壁面を断熱条件に設定してください |
| `RK` | **2** or **4** | Order of the Runge-Kutta method<br>ルンゲクッタ法における次数を選択してください |
| `KERNEL_TYPE` | from **1** to **5** | Select the kernel function in the SPH calculation<br>SPH計算におけるカーネル関数を指定してください |
| `SPH_MODEL` | from **1** to **6** | Select the discretization model of the SPH method<br>SPH法における離散化モデルを選択してください |
| `WALL_MODEL` | from **1** to **3** | Select the wall boundary model in the SPH method<br>SPH法における壁境界モデルを選択してください |

> [!NOTE]
> For mathematical details of the discretization and wall boundary models, see [theory_manual.pdf](./theory_manual.pdf).<br>
> 離散化モデル、壁境界モデルの数理的な詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

#### Recommended Settings / 推奨設定（変更可能）

The following parameters must also be set, but their values can be freely chosen by the user. For fluid properties and relaxation parameters, refer to the specific benchmark tables below.  
以下のパラメータも必ず設定する必要がありますが、具体的な値は自由に設定できます。物性値や緩和パラメータについては、後述の各ベンチマークテストに対する表を参照してください。

| Parameter<br>パラメータ | Recommended Value<br>推奨値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `U_BOUNDARY_*` | **2** (Air), **1** (Mantle) | No-slip for air and free-slip for mantle, corresponding to each benchmark.<br>各ベンチマークに対応するように、空気の場合は滑りなし(**2**)、マントルの場合は自由滑り(**1**)を推奨します |
| `TEM_TOP` | **0.0d0** | Top wall temperature $T_C$<br>上部壁面の温度 $T_ C$ を設定してください |
| `TEM_BOTTOM` | `TEM_TOP` $+ \Delta T$ | Bottom wall temperature $T_ H$ (See tables below for $\Delta T$)<br>下部壁面の温度 $T_H$ を設定してください（$\Delta T$ は後述の表を参照） |
| `SAVE_NAME` | - | Output file name (`results/SAVE_NAME/`)<br>結果の保存ファイル名を指定してください |
| `READ_NAME` | `"new"` or specified `SAVE_NAME` | Set to `"new"` for a fresh start (see [config_guide.md](./config_guide.md))<br>新規計算時は `"new"` を設定してください |
| `OMP_THREADS` | **8** | Number of threads for OpenMP<br>OpenMPで使用するスレッド数を指定してください |
| `LEN_X`, `LEN_Y` | **0.1d0** (Air)<br>**1.0d6** (Mantle) | System length $L$ [m]<br>系の長さを設定してください |
| `NUM_X`, `NUM_Y` | **50**, **100**, **200**, and **400**. | Spatial resolution ($\Delta x = \Delta y$)<br>空間解像度を設定してください |
| `START_STEP` | **1** or **a specified step** | Set to 1 for a fresh start<br>新規計算時は1を設定してください |
| `END_STEP` | - | Final simulation step (Set a sufficiently large value to reach a steady state. See [Section 4.5](#45-time-step--時間刻み幅))<br>定常状態に達するよう十分に大きな値を設定してください（[Section 4.5](#45-time-step--時間刻み幅) を参照） |
| `WRITE_STEP` | - | Output interval in steps<br>出力間隔（ステップ）を指定してください |
| `COE_CFL`, `COE_DIF`| **0.5d0**, **0.2d0** | Coefficients for the time step<br>時間刻み幅に関する係数を設定してください |
| `ZETA_RSST` | See tables below<br>下表を参照 | RSST parameter $\zeta$<br>RSSTパラメータ $\zeta$ を設定してください |
| `XI_VIM` | See tables below<br>下表を参照 | VIM parameter $\xi$<br>VIMパラメータ $\xi$ を設定してください |
| `RHO_REF` | **1.0d0** (Air)<br>**4.0d3** (Mantle) | Reference mass density $\rho_ 0$ [kg m$^{-3}$]<br>基準密度を設定してください |
| `VIS_REF` | See tables below<br>下表を参照 | Reference viscosity $\eta$ [Pa s]<br>粘性率（一定）を設定してください |
| `K_REF` | **1.4d5** (Air)<br>**2.0d11** (Mantle) | Reference bulk modulus $K$ [Pa]<br>体積弾性率（一定）を設定してください |
| `K_TH_REF` | **1.0d-2** (Air)<br>**5.0d0** (Mantle) | Reference thermal conductivity $k_ {\mathrm{th}}$ [W m$^{-1}$ K$^{-1}$]<br>熱伝導率（一定）を設定してください |
| `CP_REF` | **1.0d3** (Air)<br>**1.25d3** (Mantle) | Reference specific heat capacity $c_ p$ [J kg$^{-1}$ K$^{-1}$]<br>比熱（一定）を設定してください |
| `ALPHA_REF` | **7.1d-3** (Air)<br>**2.5d-5** (Mantle) | Reference thermal expansion coefficient $\alpha_ {\mathrm{th}}$ [K$^{-1}$]<br>熱膨張率（一定）を設定してください |
| `GRAVITY` | **10.0d0** | Gravitational acceleration $g$ [m s$^{-2}$]<br>重力加速度を設定してください |
| `COE_H` | **1.2d0** | Coefficient of the smoothing length $h$ ($h =$ `COE_H` $\times \Delta x$)<br>スムージング長 $h$ の係数を設定してください |
| `PST_C` | **1.5d0** | Coefficient for the Particle Shifting Technique (PST)<br>粒子再配列（PST）のシフト係数を設定してください |
| `COE_DELTA_SPH` | **0.1d0** | Coefficient for the $\delta$-SPH method<br>$\delta$-SPH法の係数を設定してください |

> [!NOTE]
> - Any other parameters in [config.h](../../config.h) will be ignored.<br>
> [config.h](../../config.h) 内のその他のパラメータの値は無視されます。
> 
> - For a detailed explanation of each parameter, see [config_guide.md](./config_guide.md).<br>
> 各パラメータの詳細な意味については [config_guide.md](./config_guide.md) をご参照ください。

<br>

#### Parameters depending on the Rayleigh Number / $Ra$ に依存するパラメータ

The optimal physical properties and relaxation parameters vary depending on the target Rayleigh number ($Ra$). For example, refer to the tables below for the settings of Air ($Pr=0.71$) and Mantle ($Pr > 10^{23}$) convection.  
最適な物性値および緩和パラメータは、対象とするレイリー数 ($Ra$) に応じて変化します。例えば、空気 ($Pr=0.71$) およびマントル対流 ($Pr > 10^{23}$) の設定については以下の表を参考にしてください。

**1. Settings for Air Convection / 空気の熱対流の設定値**  
For air convection, $Ra$ can be controlled by changing the temperature difference $\Delta T$ while keeping the viscosity. The VIM is not used ($\xi = 1$).  
空気の熱対流では、粘性率を一定に保ち、温度差 $\Delta T$ を変えることで $Ra$ を制御します。VIMは使用しません（$\xi = 1$）。

| $Ra$ | $\Delta T$ (for `TEM_BOTTOM`) | `VIS_REF` ($\eta$) | `ZETA_RSST` ($\zeta$) | `XI_VIM` ($\xi$) |
| :--- | :--- | :--- | :--- | :--- |
| **$10^4$** | **1.0d-2** | **7.1d-6** | **1.08d4** | **1.0d0** |
| **$10^5$** | **1.0d-1** | **7.1d-6** | **4.20d3** | **1.0d0** |
| **$10^6$** | **1.0d0** | **7.1d-6** | **1.71d3** | **1.0d0** |

<br>

**2. Settings for Mantle Convection / マントル対流の設定値 (Blankenbach et al., 1989 [[7]](#blankenbach-1989))**  
For mantle convection, $Ra$ can be controlled by changing the viscosity $\eta$ while keeping the temperature difference $\Delta T = 1000$ constant. The VIM is utilized to relax the extremely small time step.  
マントル対流では、温度差 $\Delta T = 1000$ を一定に保ち、粘性率 $\eta$ を変えることで $Ra$ を制御します。極小の時間刻み幅を緩和するため、VIMを活用します。

| $Ra$ | $\Delta T$ (for `TEM_BOTTOM`) | `VIS_REF` ($\eta$) | `ZETA_RSST` ($\zeta$) | `XI_VIM` ($\xi$) |
| :--- | :--- | :--- | :--- | :--- |
| **$10^4$** | **1.0d3** | **1.0d23** | **9.2d0** | **1.1d11** |
| **$10^5$** | **1.0d3** | **1.0d22** | **1.3d1** | **1.7d10** |
| **$10^6$** | **1.0d3** | **1.0d21** | **2.0d1** | **2.5d9** |


---

### 4.7 Output data format / 結果の出力形式

The Fortran code exports the simulation results as unformatted binary files. You can read these files using your preferred post-processing software (e.g., Python, MATLAB) or the provided Python analysis scripts.  
Fortranコードにおいて、シミュレーション結果はバイナリファイル（Unformatted binary stream）として出力されます。出力されたファイルは、PythonやMATLAB等の任意の解析ツール、または付属のPython解析スクリプトを用いて読み込むことができます。

**Output Directories and Files / 出力先とファイル構成**<br>
- `results/SAVE_NAME/config/`: <br>Contains the simulation settings (`config.h`, `parameters.csv`) and the terminal output log (`run.log`).<br>計算設定（`config.h`, `parameters.csv`）および実行ログ（`run.log`）が保存されます。

- `results/SAVE_NAME/data/`: <br>Contains the sequential snapshot data (`[step].dat`).<br>スナップショットデータ（`[step].dat`）が保存されます。

<br>

**Binary Data Format of `[step].dat` / スナップショットデータのフォーマット**<br>
Each snapshot file stores the following 1D arrays sequentially for all particles (from index `1` to `NUM_TOTAL`):  
各スナップショットファイルには、全粒子（インデックス `1` から `NUM_TOTAL`）に対する以下の1次元配列が順番にベタ書きで格納されています。

1. `ptype` (32-bit Integer / 32ビット整数)
2. `x` (64-bit Double / 64ビット浮動小数点数)
3. `y` (64-bit Double / 64ビット浮動小数点数)
4. `u` (64-bit Double / 64ビット浮動小数点数)
5. `v` (64-bit Double / 64ビット浮動小数点数)
6. `rho` (64-bit Double / 64ビット浮動小数点数)
7. `pre` (64-bit Double / 64ビット浮動小数点数)
8. `tem` (64-bit Double / 64ビット浮動小数点数)

> [!NOTE]
> For the detail of the data format, see [write_data_mod.f90](../../source/io/write_data_mod.f90).<br>
> データ形式の詳細は [write_data_mod.f90](../../source/io/write_data_mod.f90) をご参照ください。

By using these output files, you can calculate the Nusselt numbers at the walls and evaluate the history of the RMS velocity and the effective Mach number to verify the stability of the numerical scheme and compare them with the reference values.  
これらの出力ファイルを処理することで、壁面におけるヌッセルト数、RMS速度、実効的なマッハ数等を算出でき、数値スキームの安定性の確認や参照値との比較検証などを行うことができます。


<br>

## 参考文献

<a id="taylor-1937">[1]</a> Taylor, G. I. and Green, A. E. (1937) Mechanism of the production of small eddies from large ones, *Proceedings of the Royal Society of London. A. Mathematical and Physical Sciences* Vol. 158, No. 895, pp. 499–521, [https://doi.org/10.1098/rspa.1937.0036](https://doi.org/10.1098/rspa.1937.0036).

<a id="morris-1997">[2]</a> Morris, J. P., Fox, P. J., and Zhu, Y. (1997) Modeling Low Reynolds Number Incompressible Flows Using SPH, *Journal of Computational Physics*, Vol. 136, No. 1, pp. 214-226, [https://doi.org/10.1006/jcph.1997.5776](https://doi.org/10.1006/jcph.1997.5776).

<a id="ghia-1982">[3]</a> Ghia, U., Ghia, K. N., and Shin, C. T. (1982) High-Re solutions for incompressible flow using the Navier-Stokes equations and a multigrid method, *Journal of Computational Physics*, Vol. 48, No. 3, pp. 387-411, [https://doi.org/10.1016/0021-9991(82)90058-4](https://doi.org/10.1016/0021-9991(82)90058-4).

<a id="hotta-2012">[4]</a> Hotta, H., Rempel, M., Yokoyama, T.,  Iida, Y., and Fan, Y. (2012) Numerical calculation of convection with reduced speed of sound technique, *Astronomy & Astrophysics*, Vol. 539, No. A30, [https://doi.org/10.1051/0004-6361/201118268](https://doi.org/10.1051/0004-6361/201118268).

<a id="takeyama-2017">[5]</a> Takeyama, K., Saitoh, T. R., Makino, J. (2017) Variable inertia method: A novel numerical method for mantle convection simulation, *New Astronomy*, Vol. 50, pp. 82-103, [https://doi.org/10.1016/j.newast.2016.07.002](https://doi.org/10.1016/j.newast.2016.07.002).

<a id="ouertatani-2008">[6]</a> Ouertatani, N., Cheikh, N. B., Beya, B. B., and Lili, T. (2008) Numerical simulation of two-dimensional Rayleigh-Bénard convection in an enclosure, *Comptes Rendus Mécanique*, Vol. 336, pp. 464-470, [https://doi.org/10.1016/j.crme.2008.02.004](https://doi.org/10.1016/j.crme.2008.02.004).

<a id="blankenbach-1989">[7]</a> Blankenbach, B., Busse, F., Christensen, U., Cserepes, L., Gunkel, D., Hansen, U., Harder, H., Jarvis, G., Koch, M., Marquart, G., Moore, D., Olson, P., Schmeling, H., Schnaubelt, T. (1989) A benchmark comparison for mantle convection codes, *Geophysical Journal International*, Vol. 98, Issue 1, pp. 23-38, [https://doi.org/10.1111/j.1365-246X.1989.tb05511.x](https://doi.org/10.1111/j.1365-246X.1989.tb05511.x).

<a id="shobuzako-2025">[8]</a> Shobuzako, K. (2025) LS-SPH 法と高速化陽解法の開発に基づく高精度メッシュフリー惑星内部シミュレーション, Ph.D. thesis (Kyushu University, Japan).