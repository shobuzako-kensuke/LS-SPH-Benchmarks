# Configuration Guide (`config.h`)

This document provides a comprehensive guide to the parameters defined in [config.h](../../config.h).<br>
The Fortran code must be recompiled (`make`) after [config.h](../../config.h) is changed.

本ドキュメントは [config.h](../../config.h) に定義されているパラメータの解説書です。<br>
[config.h](../../config.h) の内容を変更した場合、必ずFortranコードを再コンパイル（`make`）してください。

<br>

> [!NOTE]
> - For the recommended settings for each benchmark test, see [benchmarks_detail.md](./benchmarks_detail.md).  
各ベンチマークテストにおける推奨設定は [benchmarks_detail.md](./enchmarks_detail.md) をご参照ください。
>
> - For mathematical details and references, see [theory_manual.pdf](./theory_manual.pdf).  
具体的な数式や文献情報は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。


<br>

## 1. Target Problem / 解析する問題 (`TARGET_PROBLEM`)

Select the benchmark problem to simulate.  
実行するベンチマーク問題を選択します。

| Value (`TARGET_PROBLEM`) | Description (English) | Description (日本語) |
| :---: | :--- | :--- |
| **1** | Diffusion Equation Test | 拡散方程式テスト |
| **2** | Taylor-Green Vortex | Taylor-Green渦 |
| **3** | Lid-driven Cavity Flow | キャビティ流れ |
| **4** | Boussinesq Convection (Bottom-heated) | ブシネスク熱対流（底面加熱） |

> [!NOTE]
> Parameters in [config.h](../../config.h) that are not related to the selected benchmark test will be ignored.  
> 選択したベンチマークテストに無関係な [config.h](../../config.h) 内のパラメータは無視されます。

<br>

## 2. Velocity Boundary Conditions / 速度境界条件 (`U_BOUNDARY_*`)

Define the velocity boundary condition for each wall (TOP, BOTTOM, LEFT, RIGHT).  
各壁（上下左右）の速度境界条件を定義します。

| Value (`U_BOUNDARY_*`) | Description (English) | Description (日本語) |
| :---: | :--- | :--- |
| **1** | Free-slip boundary condition (Neumann for the Diffusion Equation Test) | 自由滑り境界条件（拡散方程式テストの場合はノイマン条件） |
| **2** | No-slip boundary condition (Dirichlet for the Diffusion Equation Test) | 滑りなし境界条件（拡散方程式テストの場合はディリクレ条件） |
| **3** | Moving wall boundary condition (constant velocity) <br>*Note*: Option 3 is valid only for the top wall. Set the velocity using `U_TOP`. | 移動壁境界条件（一定速度） <br>*注意*: オプション3は上壁に対してのみ有効です。`U_TOP` で速度を指定してください。 |

<br>

## 3. Temperature Boundary Conditions / 温度境界条件 (`TEM_BOUNDARY_*`)

Define the thermal boundary condition for each wall (TOP, BOTTOM, LEFT, RIGHT).  
各壁（上下左右）の温度境界条件を定義します。

| Value (`TEM_BOUNDARY_*`) | Description (English) | Description (日本語) |
| :---: | :--- | :--- |
| **1** | Isothermal boundary condition (constant temperature) <br>*Note*: Set the temperature using `TEM_TOP`, `TEM_BOTTOM`, etc. | 等温境界条件（一定温度）<br>*注意*: `TEM_TOP` や `TEM_BOTTOM` 等で具体的な温度 (K) を指定してください。 |
| **2** | Adiabatic boundary condition (zero heat flux) | 断熱境界条件（熱流束ゼロ） |

> [!NOTE]
> Temperature boundary conditions are valid only for the thermal convection problem (`TARGET_PROBLEM 4`).  
> 温度境界条件の設定は熱対流計算時 (`TARGET_PROBLEM 4`) のみ有効になります。


<br>

## 4. Input/Output Settings / ファイルの入出力設定

Specify the output file name.  
出力ファイル名を指定します。

| Parameter | Description (English) | Description (日本語) |
| :--- | :--- | :--- |
| `SAVE_NAME` | Output directory name under `results/` | `results/` 以下に作成される出力ディレクトリ名 |
| `READ_NAME` | Target directory name when restarting<br> | 再計算時に読み込まれるディレクトリ名 |

> [!NOTE]
> - To start a new simulation from the first step (no restart), set `READ_NAME "new"` (default).
> 
> - To restart a previous simulation, specify the saved target name. (Example: To restart from step 100 of a simulation saved as `SAVE_NAME "Taylor_Green"`, set `READ_NAME "Taylor_Green"` and set the starting step to `START_STEP 100`.)
> ---
> - 1ステップ目から計算する場合（リスタートしない場合）は、`READ_NAME "new"` としてください（デフォルト設定）  
> 
> - 途中から再計算したい場合は、そのファイル名を指定してください。例えば、`SAVE_NAME "Taylor_Green"` の100ステップ目から再計算したい場合は、 `READ_NAME "Taylor_Green"` として、後述する計算開始ステップを `START_STEP 100` としてください。

<br>

## 5. Parallel Computing Settings / 並列計算の設定

Configure the parallel computing.  
並列計算に関する設定を行います。

| Parameter | Description (English) | Description (日本語) |
| :--- | :--- | :--- |
| `OMP_THREADS` | Number of threads for OpenMP | OpenMPで使用するスレッド数 |

<br>

## 6. Domain (SI Units) & Spatial Resolution / 計算領域と空間解像度

Define the domain and the number of particles.  
計算領域と粒子数を定義します。

| Parameter | Description (English) | Description (日本語) |
| :--- | :--- | :--- |
| `LEN_X`, `LEN_Y` | System length in the X and Y directions (unit: m) | X方向およびY方向のシステム長 $L_ x, L_ y$ [m] |
| `NUM_X`, `NUM_Y` | Number of particles in the X and Y directions | X方向およびY方向の粒子数 |

> [!NOTE]
> Initial particle spacing ($\Delta x$) is automatically calculated as `LEN_X / NUM_X`.  
> 初期粒子間隔 ($\Delta x$) は `LEN_X / NUM_X` として自動計算されます。

> [!IMPORTANT]
> When setting a rectangular domain, the ratio of the system lengths must perfectly match the ratio of the number of particles to ensure an isotropic initial particle spacing ($\Delta x = \Delta y$). For example, if `LEN_X = 2.0` and `LEN_Y = 1.0`, you must set `NUM_X` to be exactly twice `NUM_Y`.  
> 
> 矩形領域を設定する場合、初期の粒子間隔が等方的 ($\Delta x = \Delta y$) になるように、システム長と粒子数の比率を**必ず一致**させてください。例えば `LEN_X = 2.0`、`LEN_Y = 1.0` とした場合、`NUM_X` は `NUM_Y` の2倍に設定する必要があります。

<br>

## 7. Time Integration & Numerical Parameters / 時間積分と数値計算パラメータ

Configure parameters for the time integration scheme (Runge-Kutta method), including its order, computational steps, and time step size.  
時間積分法 (ルンゲ・クッタ法) の次数や計算ステップ数、時間刻み幅などを設定します。


| Parameter | Description (English) | Description (日本語) |
| :--- | :--- | :--- |
| `RK` | Order of Runge-Kutta method (Available: **2** or **4**) | ルンゲクッタ法の次数 (**2** または **4** を指定) |
| `START_STEP` | Write **1** for a fresh start, or specify the step number for a restart | 新規計算時は **1**、リスタート時は再開するステップ数を指定します |
| `END_STEP` | The final step of the simulation | シミュレーションの終了ステップ数 |
| `WRITE_STEP` | File output interval | ファイル出力のステップ間隔 |
| `THRESHOLD` | Threshold for checking the steady state | 定常状態を判定するための誤差閾値 |
| `COE_CFL`, `COE_DIF` | Coefficients for the time step ($\Delta t$) of the CFL and diffusion conditions | CFL条件および拡散条件に関する時間刻み幅 ($\Delta t$) の係数 |
| `ZETA_RSST` | Relaxation parameter for the Reduced Speed of Sound Technique (RSST) | 音速抑制法 (RSST) の緩和パラメータ |
| `XI_VIM` | Relaxation parameter for the Variable Inertial Method (VIM) | 慣性変化法 (VIM) の緩和パラメータ |

> [!NOTE]
> The effective time step $\Delta t$ is determined by the following equation.  
> 実効的な時間刻み幅 $\Delta t$ は次式により決定されます。
> 
> $$
> \Delta t = \min \left( C_ {\mathrm{CFL}} \times \frac{\Delta x}{c/(\zeta \xi)} , \quad C_ {\mathrm{DIF}} \times \frac{(\Delta x)^2}{\nu / \xi^2} , \quad C_ {\mathrm{DIF}} \times \frac{(\Delta x)^2}{\kappa} \right) ,
> $$
> 
> where $C_ {\mathrm{CFL}} =$ `COE_CFL`, $C_ {\mathrm{DIF}} =$ `COE_DIF`, $\Delta x$ is the particle spacing for the initial regular configuration, $c = \sqrt{K/\rho}$ is the speed of sound ($K$ is the bulk modulus and $\rho$ is the density), $\nu$ is the kinematic viscosity, $\kappa$ is the thermal diffusivity, and $\zeta$ and $\xi$ are the relaxation parameters for the Reduced Speed of Sound Technique (RSST) and the Variable Inertial Method (VIM), respectively.  
> 
> ここで、 $C_ {\mathrm{CFL}} =$ `COE_CFL`、 $C_ {\mathrm{DIF}} =$ `COE_DIF`、 $\Delta x$ は初期規則配置時における粒子間隔、 $c = \sqrt{K/\rho}$ は音速 ($K$は体積弾性率、 $\rho$は密度)、 $\nu$ は動粘性率、 $\kappa$ は熱拡散率、 $\zeta, \xi$ はそれぞれ音速抑制法 (RSST) および慣性変化法 (VIM) の緩和パラメータを表します。

> [!NOTE]
> Details of the RSST and VIM are provided in [theory_manual.pdf](./theory_manual.pdf).  
> RSST および VIM の詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

## 8. Fluid Physical Properties / 流体の物性値

All physical properties must be defined in SI units.  
すべての物性値はSI単位で定義してください。

| Parameter | Description (English) | Description (日本語) |
| :--- | :--- | :--- |
| `RHO_REF` | Reference density $\rho_ 0$ [kg m$^{-3}$] | 基準状態における密度 $\rho_ 0$ [kg m$^{-3}$] |
| `VIS_REF` | Reference viscosity $\eta$ [Pa s] | 基準状態における粘性率 $\eta$ [Pa s] |
| `K_REF` | Reference bulk modulus $K$ [Pa] | 基準状態における体積弾性率 $K$ [Pa] |
| `K_TH_REF` | Reference thermal conductivity $k_ {\mathrm{th}}$ [W m$^{-1}$ K$^{-1}$] | 基準状態における熱伝導率 $k_ {\mathrm{th}}$ [W m$^{-1}$ K$^{-1}$] |
| `CP_REF` | Reference specific heat capacity $c_ {p}$ [J kg$^{-1}$ K$^{-1}$] | 基準状態における比熱 $c_ {p}$ [J kg$^{-1}$ K$^{-1}$] |
| `ALPHA_REF` | Reference thermal expansion coefficient $\alpha_ {\mathrm{th}}$ [K$^{-1}$] | 基準状態における熱膨張率 $\alpha_ {\mathrm{th}}$ [K$^{-1}$] |

> [!NOTE]
> For the Diffusion Equation Test (`TARGET_PROBLEM 1`), all settings except for `RHO_REF` are ignored. In addition, the settings for thermal conductivity (`K_TH_REF`), specific heat (`CP_REF`), and the thermal expansion coefficient (`ALPHA_REF`) are valid only for the thermal convection problem (`TARGET_PROBLEM 4`).  
> 
> 拡散方程式テスト(`TARGET_PROBLEM 1`) では、`RHO_REF` 以外の設定が無視されます。また、熱伝導率 (`K_TH_REF`)、比熱 (`CP_REF`)、熱膨張率 (`ALPHA_REF`) の設定は、熱対流計算時 (`TARGET_PROBLEM 4`) のみ有効になります。

<br>

## 9. Simulation Parameters / その他のシミュレーションパラメータ

Specify additional simulation parameters.  
その他のシミュレーションパラメータを設定します。

| Parameter | Description (English) | Description (日本語) |
| :--- | :--- | :--- |
| `GRAVITY` | Magnitude of the gravitational acceleration (m/s^2) | 重力加速度の大きさ (m/s^2) |
| `POS_PERT` | Magnitude of the positional perturbation for the Diffusion Equation Test ($0 \leq$ `POS_PERT` $< 0.5$) | 拡散方程式テストにおける初期粒子配置の摂動の大きさ ($0 \leq$ `POS_PERT` $< 0.5$) |
| `TG_A`, `TG_B` | Number of vortices in the X and Y directions of Taylor-Green Vortex | Taylor-Green Vortex におけるX方向およびY方向の渦の数 |

> [!NOTE]
> The position $\vec{x} _{i}$ of particle $i$ for the Diffusion Equation Test is determined by the following equation.  
> 拡散方程式テストにおける粒子 $i$ の位置 $\vec{x}_ {i}$ は次式により決定されます。
> 
> $$
> \vec{x}_ {i} = \vec{x}_ {i,0} + (\epsilon \Delta x) \vec{e} ,
> $$
> 
> where $\vec{x}_ {i,0}$ is its position for the regular configuration , $\epsilon =$ `POS_PERT` is the magnitude of the positional perturbation, $\Delta x$ is the particle spacing for the regular configuration, and $\vec{e}$ is a 2D random vector whose components range from $-1$ to $1$.  
> 
> ここで、 $\vec{x}_ {i,0}$ は規則配置時における粒子位置、 $\epsilon =$ `POS_PERT` は位置摂動の大きさ、 $\Delta x$ は規則配置時における粒子間隔、 $\vec{e}$ は各要素の値が $-1$ から $1$ の間をランダムに取る2次元ベクトルをそれぞれ表します。

<br>

## 10. SPH Parameters / SPH関連のパラメータ

Define the smoothing length $h$, the shifting coefficient for the Particle Shifting Technique (PST), and the magnitude of the density diffusion term in the $\delta$-SPH method.  
スムージング長 $h$、粒子再配列法 (PST) のシフト係数、 $\delta$-SPH法における密度拡散項の大きさを指定します。

| Parameter | Description (English) | Description (日本語) |
| :--- | :--- | :--- |
| `COE_H` | Coefficient of the smoothing length ($h =$ `COE_H` $\times \Delta x$) | スムージング長の係数 ($h =$ `COE_H` $\times \Delta x$)|
| `PST_C` | Shifting coefficient for the Particle Shifting Technique (PST) | 粒子再配列法 (PST) のシフト係数 |
| `COE_DELTA_SPH` | Coefficient of the density diffusion term (Recommended for $\delta$-SPH: 0.1) | 密度拡散項の係数 ($\delta$-SPH法における推奨値: 0.1)|

> [!NOTE]
> The particle shift $\Delta \vec{x}$ in the internal region is determined by the following equation.  
> 内部領域の粒子シフト $\Delta \vec{x}$ は次式により決定されます。
> 
> $$
> \Delta \vec{x} = - (C_ {\mathrm{PST}} \times U_ {\max} \Delta t) \sum_ {j} h V_ {j} \left( 1 + 0.2 \left(\frac{W(|\vec{x}_ {ij}|; h)}{W(\Delta x; h)}\right)^4 \right) \nabla_ {i} W(|\vec{x}_ {ij}|; h) ,
> $$
> 
> where $C_ {\mathrm{PST}} =$ `PST_C`, $U_ {\max}$ is the maximum velocity in the system, $\Delta t$ is the time step, $h$ is the smoothing length, $V_ {j}$ is the volume of the neighboring particle $j$, $W(|\vec{x}_ {ij}|; h)$ is the value of the kernel function for the distance between particle $i$ and its neighbor $j$ with the smoothing length $h$, and $\Delta x$ is the particle spacing for the regular configuration.  
> 
> ここで、 $C_ {\mathrm{PST}} =$ `PST_C`、 $U_ {\max}$ は系の最大速度、 $\Delta t$ は時間刻み幅、 $h$ はスムージング長、 $V_ {j}$ は近傍粒子 $j$ の体積、 $W(|\vec{x}_ {ij} |; h)$ は粒子 $i$ と近傍粒子 $j$ の距離および $h$ に関するカーネル関数の値、 $\Delta x$ は規則配置時における粒子間隔をそれぞれ表します。

> [!NOTE]
> Details of the PST and $\delta$-SPH method are provided in [theory_manual.pdf](./theory_manual.pdf).  
> PST および $\delta$-SPH法の詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。
 
<br>

## 11. Kernel Function / カーネル関数 (`KERNEL_TYPE`)

Specify the kernel function used in the SPH calculation.  
SPH計算で用いるカーネル関数を指定します。

| Value | Type (English) | Type (日本語) |
| :---: | :--- | :--- |
| **1** | Cubic spline kernel | 3次スプラインカーネル |
| **2** | Quintic spline kernel | 5次スプラインカーネル |
| **3** | Wendland $C^2$ kernel | Wendland $C^2$ カーネル |
| **4** | Wendland $C^4$ kernel | Wendland $C^4$ カーネル |
| **5** | Wendland $C^6$ kernel | Wendland $C^6$ カーネル |

> [!NOTE]
> See [theory_manual.pdf](./theory_manual.pdf) for the mathematical details.  
> カーネル関数の式の詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。

<br>

## 12. SPH Discretization Model / SPH離散化手法 (`SPH_MODEL`)

Specify the spatial discretization method in the SPH calculation.  
SPH計算における空間離散化手法を指定します。

| Value | Model (English) | Model (日本語) |
| :---: | :--- | :--- |
| **1** | Classical SPH (sum model) | 古典的SPH（和モデル） |
| **2** | Classical SPH (difference model) | 古典的SPH（差モデル） |
| **3** | LS-SPH (2nd-order Taylor expansion) | 最小二乗SPH（2次テイラー展開） |
| **4** | LS-SPH (3rd-order Taylor expansion) | 最小二乗SPH（3次テイラー展開） |
| **5** | LS-SPH (4th-order Taylor expansion) | 最小二乗SPH（4次テイラー展開） |
| **6** | LS-SPH (5th-order Taylor expansion) | 最小二乗SPH（5次テイラー展開） |

> [!NOTE]
> See [theory_manual.pdf](./theory_manual.pdf) for the mathematical details.  
> 式の詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。


<br>

## 13. Wall Boundary Model / 壁境界モデル (`WALL_MODEL`)

Specify the wall boundary model for the SPH calculation.   
SPH計算における壁境界モデルを指定します。

| Value | Model (English) | Model (日本語) |
| :---: | :--- | :--- |
| **1** | Fixed ghost particle scheme (1st-order interpolation) | 固定ゴースト粒子法（1次精度内挿） |
| **2** | Fixed ghost particle scheme (2nd-order interpolation) | 固定ゴースト粒子法（2次精度内挿） |
| **3** | Fixed ghost particle scheme (3rd-order interpolation) | 固定ゴースト粒子法（3次精度内挿） |

> [!NOTE]
> See [theory_manual.pdf](./theory_manual.pdf) for the mathematical details.  
> 式の詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください。
