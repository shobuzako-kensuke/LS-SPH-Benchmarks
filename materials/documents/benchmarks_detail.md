# Benchmark Details & Recommended Settings <!-- omit in toc -->

This document provides a practical guide for running each benchmark test. It includes the details of each benchmark test, recommended parameters for [config.h](../../config.h), and the expected results to help you verify your simulation.

各ベンチマークテストの詳細，[config.h](../../config.h) の推奨パラメータ設定，およびシミュレーションが正しく動作したかを確認するための「期待される結果」をまとめています．

> [!NOTE]
> - For a detailed explanation of each parameter, see [config_guide.md](./config_guide.md).  
> 各パラメータの詳細な意味については [config_guide.md](./config_guide.md) をご参照ください
>
> - For mathematical details (governing equations, analytical solutions, and discretization schemes), see [theory_manual.pdf](./theory_manual.pdf).  
> 支配方程式，解析解の導出，離散化スキームなどの数理的な詳細は [theory_manual.pdf](./theory_manual.pdf) をご参照ください．

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
  - [1.7 Expected Results / 期待される結果](#17-expected-results--期待される結果)

<br>

## 1. Diffusion Equation Test / 拡散方程式テスト

### 1.1 Overview / 概要
This test solves the Poisson equation under an appropriate boundary condition as a steady state of the diffusion equation. This is implemented for verifying the discretization accuracy of the Laplacian, the effect of particle disorder (positional perturbation), and the effect of the wall boundary treatment in the SPH method.

適切な境界条件におけるポアソン方程式の解を，拡散方程式の定常解として得るテストです．ラプラシアンの離散化精度，粒子配置の不規則性（位置摂動）の効果，およびSPH法における壁境界モデルの影響などを検証するために実装しました．

---

### 1.2 Governing Equation / 支配方程式

The governing equation is the following 2D diffusion equation with a source term:  
支配方程式は，以下のソース項付きの2次元拡散方程式です．

$$
\frac{\partial f}{\partial t} = \nabla^{2} f + 2 \pi^{2} \sin(\pi x) \cos(\pi y),
$$

where $f(x,y,t)$ is a scalar function and $t$ is the time. The computational domain $\Omega$ is a unit square ($\Omega = [0, 1] \times [0, 1]$). For simplicity, the diffusion coefficient is set to unity.  

ここで， $f(x,y,t)$ はスカラー関数， $t$ は時間を表します．計算領域 $\Omega$ として，長さが1の正方形領域を考えます ($\Omega = [0, 1] \times [0, 1]$)．簡単のため，拡散係数は$1$としています．

---

### 1.3 Boundary and Initial Conditions / 境界条件・初期条件

#### Boundary condition / 境界条件

The following Dirichlet or Neumann conditions are imposed.   
境界条件として以下のディリクレ条件またはノイマン条件を課します．

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

A Dirichlet condition of $f=0$ is always imposed at the corners of the computational domain to avoid the non-uniqueness of the solution that arises when only Neumann boundary conditions are applied.  

計算領域の四隅（コーナー）においては，ノイマン条件のみを課した場合における解の不定性を防ぐため，常に $f=0$ というディリクレ条件を課しています．

---

#### Initial condition / 初期条件

The initial condition is set to $f(x,y,0) = 0$.  
初期条件として $f(x,y,0) = 0$ が設定されています．

---

For this test, the particle position is fixed in space. The fixed position $\vec{x}_ {i}$ of a particle $i$ is defined as:  
本テストでは粒子位置は空間的に固定されます．粒子 $i$ の固定位置 $\vec{x}_ {i}$ は次式により定義されます．

$$
\vec{x}_ {i} = \vec{x}_ {i,0} + (\epsilon \Delta x) \vec{e} ,
$$

where $\vec{x}_ {i,0}$ is its position for the regular configuration, $\epsilon =$ `POS_PERT` is the magnitude of the positional perturbation, $\Delta x$ is the particle spacing for the regular configuration, and $\vec{e}$ is a 2D random vector whose components range from $-1$ to $1$.  

ここで， $\vec{x}_ {i,0}$ は規則配置時における粒子 $i$ の位置， $\epsilon =$ `POS_PERT` は位置摂動の大きさ， $\Delta x$ は一様配置時における粒子間隔， $\vec{e}$ は各要素の値が $-1$ から $1$ の間をランダムに取る2次元ベクトルをそれぞれ表します．


---

### 1.4 Verification: Comparison with Analytical Solution / 検証: 解析解との比較

Under the above boundary conditions, the analytical solution at the steady state ($\partial f / \partial t = 0$) can be obtained as follows:  
上述の境界条件のもとで，定常状態 ($\partial f / \partial t = 0$) における解析解 $f^{\mathrm{ana}}_ {\mathrm{s}} (x,y)$ は以下のように求められます．

$$
f^{\mathrm{ana}}_ {\mathrm{s} }(x,y) = \sin \left(\pi x \right) \cos \left(\pi y \right).
$$

To compare the numerical result with the analytical solution, the following error norms are used:  
数値解と解析解との比較検証には，以下の誤差指標を使用しています．

$$
\begin{aligned}
&L_ {1} = \frac{1}{N} \sum^{N}_ {i} \Big| f^{\mathrm{cal}}_ {\mathrm{s}} (x_ {i}, y_ {i}) - f^{\mathrm{ana}}_ {\mathrm{s}} (x_ {i}, y_ {i}) \Big|, \\
&L_ {2} = \sqrt{ \frac{1}{N} \sum^{N}_ {i} \Big( f^{\mathrm{cal}}_ {\mathrm{s}} (x_ {i}, y_ {i}) - f^{\mathrm{ana}}_ {\mathrm{s}} (x_ {i}, y_ {i}) \Big)^{2} }, \\
&L_ {\infty} = \max_ {1 \leq i \leq N} \Big| f^{\mathrm{cal}}_ {\mathrm{s}} (x_ {i}, y_ {i}) - f^{\mathrm{ana}}_ {\mathrm{s}} (x_ {i}, y_ {i}) \Big|, \\
\end{aligned}
$$

where $N$ is the total number of particles, and $f^{\mathrm{cal}}_ {\mathrm{s}} (x, y)$ is the numerical result at the steady state.  
ここで， $N$ は全粒子数， $f^{\mathrm{cal}}_ {\mathrm{s}} (x, y)$ は定常状態における数値解をそれぞれ表します．

---

### 1.5 Time Step & Steady-state Criterion / 時間刻み幅と定常状態の判定

The time step $\Delta t$ is determined by:  
時間刻み幅 $\Delta t$ は次式より決定されます．

$$
\Delta t = C_ {\mathrm{DIF}} \times \frac{(\Delta x)^{2}}{D}.
$$

where $C_ {\mathrm{DIF}}=$ `COE_DIF` is a coefficient ($0 < C_ {\mathrm{DIF}} < 1$), $\Delta x$ is the particle spacing for the regular configuration, and $D = 1$ is the diffusion coefficient.  
ここで， $C_ {\mathrm{DIF}}=$ `COE_DIF` は適当な係数 ($0 < C_ {\mathrm{DIF}} < 1$)， $\Delta x$ は規則配置時における粒子間隔， $D = 1$ は拡散係数です．

---

The steady state is considered to be reached when the following condition is satisfied:  
以下の条件を満たしたとき，定常状態に達したと判定されます．

$$
\max_ {1 \leq i \leq N} \Big| f^{\mathrm{cal}} (x_ {i}, y_ {i}, t_ {n}) - f^{\mathrm{cal}} (x_ {i}, y_ {i}, t_ {n-1})\Big| < \epsilon_ {\mathrm{s}},
$$

where $t_ {n}$ is the time at step $n$ and $\epsilon_ {\mathrm{s}} =$ `THRESHOLD` is the convergence threshold.  
ここで， $t_ {n}$ は $n$ ステップ時の時刻， $\epsilon_ {\mathrm{s}} =$ `THRESHOLD` は収束閾値を表します．

Once the steady state is reached, the simulation terminates regardless of the specified `END_STEP`.  
定常状態に達したと判定されると，`END_STEP` の設定に関わらず計算が終了します．

<br>

Since the diffusion time for the entire system is $\tau_ {\mathrm{DIF}} = L^{2} / D = 1$ (where $L$ is the characteristic length and $L = 1, D = 1$ in this test), the number of steps $N_ {\mathrm{step}}$ required to reach the steady state is estimated as follows:  
系全体に対する拡散時間は $\tau_ {\mathrm{DIF}} = L^{2} / D = 1$ ($L$ は代表長さで，本問題では $L = 1, D = 1$) であるため，定常状態に達するまでに必要なステップ数 $N_ {\mathrm{step}}$ は以下のように見積もられます．

$$
N_ {\mathrm{step}} \sim \frac{\tau_ {\mathrm{DIF}}}{\Delta t} = \frac{1}{C_ {\mathrm{DIF}} (\Delta x)^{2}} = \frac{n^{2}}{C_ {\mathrm{DIF}}},
$$

where $n =$ `NUM_X` $=$ `NUM_Y` is the number of particles in one side of the square domain, satisfying the relationship $\Delta x = L / n$.  
ここで， $n =$ `NUM_X` $=$ `NUM_Y` は正方形の1辺あたりの粒子数で， $\Delta x = L / n$ の関係を満たします．

---

### 1.6 Parameter Settings / パラメータ設定

Set up the parameters in [config.h](../../config.h) according to the following settings.  
以下のパラメータ設定を参考にして，[config.h](../../config.h) を適切に設定してください．

#### Required Settings / 必須設定（固定値）

The following parameters must be set to the specified values.  
以下のパラメータは必ずこの値に設定してください．

| Parameter<br>パラメータ | Value<br>値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `TARGET_PROBLEM` | **1** | Select the Diffusion Equation Test<br>拡散方程式テストを選択します |
| `U_BOUNDARY_*` | **1** or **2** | The value of **1** corresponds to the Neumann boundary condition, while that of **2** to the Dirichlet boundary condition<br>**1** はノイマン条件，**2**はディリクレ条件に対応しています |
| `LEN_X`, `LEN_Y` | **1.0d0** | Set the system length to unity<br>系の長さは1と設定してください |
| `RK` | **2** or **4** | Order of the Runge-Kutta method<br>ルンゲクッタ法における次数を選択してください |
| `KERNEL_TYPE` | from **1** to **5** | Select the kernel function in the SPH calculation<br>SPH計算におけるカーネル関数を指定してください |
| `SPH_MODEL` | from **1** to **6** | Select the discretization model of the SPH method<br>SPH法における離散化モデルを選択してください |
| `WALL_MODEL` | from **1** to **3** | Select the wall boundary model in the SPH method<br>SPH法における壁境界モデルを選択してください |

<br>

#### Recommended Settings / 推奨設定（変更可能）

The following parameters must also be set, but their values can be freely chosen by the user. The "Recommended Values" indicate the settings used for code verification.  

以下のパラメータも必ず設定する必要がありますが，具体的な値は自由に設定できます．表中の「推奨値」は，本コードの動作確認に使用した値を示しています．

| Parameter<br>パラメータ | Recommended Value<br>推奨値 | Notes<br>備考 |
| :--- | :--- | :--- |
| `SAVE_NAME` | - | Output file name (`results/SAVE_NAME/`)<br>結果の保存ファイル名を指定してください |
| `READ_NAME` | `"new"` or specified `SAVE_NAME` | Set to `"new"` for a fresh start, or use a specified `SAVE_NAME` for a restart (see [config_guide.md](./config_guide.md))<br>新規計算時は `"new"`，再計算時はその `SAVE_NAME` を入力してください ([config_guide.md](./config_guide.md)を参照)|
| `OMP_THREADS` | **8** | Number of threads for OpenMP<br>OpenMPで使用するスレッド数を指定してください |
| `NUM_X`, `NUM_Y` | **10**, **20**, **45**, **100**, **200**, **450**, or **1000** | Spatial resolution (`NUM_X` must be equal to `NUM_Y`)<br>空間解像度を設定してください（`NUM_X` は `NUM_Y` と等しい必要があります） |
| `START_STEP` | **1** or **a specified step** | Set to 1 for a fresh start, or use a specified step for a restart<br>新規計算時は1，再計算時は特定のステップを設定してください |
| `END_STEP` | $\sim$ `NUM_X` $^2$ / `COE_DIF` | Set to approximately the diffusion time for the entire domain (see [Section 1.5](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定))<br>系全体に対する拡散時間程度に設定してください（詳しくは[1.5節](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定)を参照） |
| `WRITE_STEP` | - | Output interval in steps<br>出力間隔（ステップ）を指定してください |
| `THRESHOLD` | **1.0d-10** | Convergence threshold for determining the steady state (see [Section 1.5](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定))<br>定常状態の判定に用いる収束閾値を設定してください（詳しくは[1.5節](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定)を参照） |
| `COE_DIF` | **0.2d0** | Coefficient of the time step (see [Section 1.5](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定))<br>時間刻み幅に関する係数を設定してください（詳しくは[1.5節](#15-time-step--steady-state-criterion--時間刻み幅と定常状態の判定)を参照） |
| `RHO_REF` | **1.0d0** | Mass density for the SPH calculation<br>SPH計算で用いる質量密度を設定してください |
| `POS_PERT` | **0.0d0** or **0.2d0** | Positional perturbation (0.0: Regular, see [Section 1.3](#13-boundary-and-initial-conditions--境界条件初期条件))<br>位置摂動を設定してください（0.0: 規則配置，詳しくは[1.3節](#13-boundary-and-initial-conditions--境界条件初期条件)を参照） |
| `COE_H` | **1.2d0** | Coefficient of the smoothing length $h$ in the SPH method ($h =$ `COE_H` $\times \Delta x$)<br>SPH計算におけるスムージング長 $h$ の係数 ($h =$ `COE_H` $\times \Delta x$) |


> [!NOTE]
> Any other parameters in [config.h](../../config.h) will be ignored.   
> [config.h](../../config.h) 内のその他のパラメータの値は無視されます．

---

### 1.7 Expected Results / 期待される結果
After running the simulation and the analysis script, you should obtain a steady-state distribution that perfectly matches the analytical solution.  
計算および解析スクリプトの実行後、解析解と完全に一致する定常分布が得られます。

<div align="center">
  <!-- TODO: Replace with the actual image path -->
  <img src="../images/benchmark_diffusion_result.png" alt="Diffusion Result" width="60%">
  <p><em>Fig 1. Comparison between the numerical result and the analytical solution.</em></p>
</div>

---

