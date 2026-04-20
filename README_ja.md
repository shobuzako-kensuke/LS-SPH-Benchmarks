<div align="center">

# LS-SPH-Benchmarks <!-- omit in toc -->

<img src="materials/images/CF_TG_OD.png" alt="Logo" width="100%">

<br>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19181862.svg)](https://doi.org/10.5281/zenodo.19181862)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Fortran](https://img.shields.io/badge/Fortran-Intel%20ifx-734f96?style=for-the-badge&logo=fortran&logoColor=white)]()
[![Python](https://img.shields.io/badge/Python-3.12%2B-blue?style=for-the-badge&logo=python&logoColor=white)]()

<p align="center">
  本リポジトリは，メッシュフリー法の一種である <strong>Smoothed Particle Hydrodynamics (SPH) 法</strong>と，その高精度版である「<strong>最小二乗SPH (Least-Squares SPH; LS-SPH) 法</strong>」による様々なベンチマークプログラムを提供しています．
</p>

[**View in English**](README.md)

</div>


## 目次 <!-- omit in toc -->
- [🔥 実装されているベンチマークテスト](#-実装されているベンチマークテスト)
- [⚙️ 動作環境](#️-動作環境)
- [🖥️ 使い方](#️-使い方)
  - [1. 本リポジトリの取得](#1-本リポジトリの取得)
  - [2. 計算の実行](#2-計算の実行)
  - [3. 結果の可視化](#3-結果の可視化)
- [📁 ディレクトリ構造](#-ディレクトリ構造)
- [🧑‍💻 本プログラムを利用される場合](#-本プログラムを利用される場合)
- [🪪 ライセンス](#-ライセンス)

<br>

## 🔥 実装されているベンチマークテスト

- **解析解との比較による精度検証テスト (Verification)**
  - 2D拡散方程式を用いた壁境界処理の検証テスト
  - Taylor–Green vortex flow（非圧縮性Navier–Stokes方程式の厳密解との比較）
- **妥当性検証のための流体ベンチマークテスト (Validation)**
  - Lid-driven cavity flow
  - Boussinesq convection


| Taylor–Green vortex | Lid-driven cavity flow | Boussinesq convection |
| :---: | :---: | :---: |
| <img src="" alt="Taylor-Green vortex" width="300"> | <img src="" alt="Cavity flow" width="300"> | <img src="" alt="Boussinesq convection" width="300"> |

<br>

## ⚙️ 動作環境

計算には **Intel Fortran** ，結果の解析および可視化には **Python** を使用しています．

| カテゴリ | 必要な環境 | メモ |
| :--- | :--- | :--- |
| **OS** | Unix系環境 | テスト環境：Windows Subsystem for Linux (WSL) |
| **コンパイラ** | Intel Fortran | テスト環境：`ifx` (デフォルト設定) |
| **ビルド** | Make | Fortranファイルのコンパイルに利用 |
| **可視化** | Python | テスト環境：`Python 3.12.0` (`matplotlib`, `numpy` 等が必要) |
| **動画作成** | `ffmpeg` | Pythonによるアニメーション出力で必要 |

> [!TIP]
> - 「WSLの導入」や「WSL上へのIntel Fortran/Python環境の構築」に関するQiita記事を執筆していますので適宜ご参照ください．
>     - [WSL2のインストールとアンインストール](https://qiita.com/zakoken/items/61141df6aeae9e3f8e36)
>     - [WSL2によるgfortranとintel fortranの環境構築](https://qiita.com/zakoken/items/2a5e629020ce68f3efe1)
>     - [WSL2によるPython3の環境構築](https://qiita.com/zakoken/items/8ddfda7267e7d95b3c46)
> 
> - `ffmpeg` をインストールしていない場合は，ターミナルで `sudo apt install ffmpeg` を実行してください．

<br>


## 🖥️ 使い方

### 1. 本リポジトリの取得
- ターミナルで `git clone` コマンドを実行するか，ZIPファイルとして本プログラム全体をローカル環境（お使いのPCなど）にダウンロードし展開してください．

### 2. 計算の実行
1. `config.h` でパラメータ（解く問題やソルバーの種類など）を設定してください．
2. ターミナルから `make` を実行し，Fortranファイルをコンパイルしてください．
3. コンパイル完了後，ルートディレクトリに `start_calculation` という実行ファイルが生成されるので，ターミナルから `./start_calculation` を実行してください．

> [!NOTE]
> 計算結果（バイナリファイル）は自動的に `results/` ディレクトリに保存されます．
  
### 3. 結果の可視化
- `analysis_main.py` で解析あるいは出力するデータを選択した後，これを実行してください．

> [!NOTE]
> 出力された図や動画は自動的に `figures/` ディレクトリに保存されます．

<br>

## 📁 ディレクトリ構造

```
LS-SPH-Benchmarks/
├── analysis/              # Python解析コード
├── materials/             # プロジェクト関連資料
│   ├── documents/         # 解説書など
│   └── images/            # README用画像など
├── source/                # Fortranソースコード
│   ├── boundary/          # 境界処理
│   ├── check/             # エラーチェック
│   ├── core/              # 配列の定義
│   ├── equation/          # 支配方程式
│   ├── integrator/        # 時間積分
│   ├── io/                # 入出力サブルーチン
│   ├── kernel/            # カーネル関数
│   ├── neighbor/          # 近傍粒子探索
│   ├── setup/             # 問題設定と初期条件
│   ├── shifting/          # 粒子再配列法
│   ├── solver/            # SPHソルバー
│   └── main.f90           # メインプログラム
├── .gitignore             # Gitで無視するファイルの指示書
├── analysis_main.py       # 解析用メインプログラム
├── CHANGELOG.md           # バージョン履歴
├── CITATION.cff           # 引用情報
├── config.h               # 設定ファイル
├── CONTRIBUTORS.md        # 本リポジトリへの貢献者
├── initialize.py          # 初期化スクリプト
├── input.f90              # 計算条件の設定ファイル
├── LICENSE                # ライセンス
├── Makefile               # コンパイル指令書
├── README.md              # 本ドキュメント（英語）
└── README_ja.md           # 本ドキュメント（日本語）
```

> [!NOTE]
> プログラムのコンパイルおよび実行に伴い，中間バイナリファイルを格納する `build/`，計算データを出力する `results/`，画像や動画を保存する `figures/` ディレクトリが**自動的に**生成されます．

> [!Tip]
> 各プログラムファイルの使い方や詳細は `materials/documents` をご覧ください．

<br>

## 🧑‍💻 本プログラムを利用される場合

本リポジトリを利用される際は，以下の**2つの文献**を引用してください．

**[1] 論文**<br>
Shobuzako, K., Yoshida, S., Kawada, Y., Nakashima, R., Fujioka, S., & Asai, M. (2025).  
A generalized smoothed particle hydrodynamics method based on the moving least squares method and its discretization error estimation.  
*Results in Applied Mathematics*, 26, 100594. [https://doi.org/10.1016/j.rinam.2025.100594](https://doi.org/10.1016/j.rinam.2025.100594)  
DOI: 10.1016/j.rinam.2025.100594

**[2] ソフトウェア**<br>
Shobuzako, K. (2025). *LS-SPH-Benchmarks* (Version 1.0.0) [Computer software]. Zenodo.  
[https://doi.org/10.5281/zenodo.19181862](https://doi.org/10.5281/zenodo.19181862)

<details>
<summary>📄 BibTeX を表示（クリックして展開）</summary>

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

## 🪪 ライセンス

本リポジトリは [MITライセンス](LICENSE) に準拠しています．
