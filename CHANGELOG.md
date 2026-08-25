# Changelog (変更履歴)

All notable changes to this project will be documented in this file.<br>
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

本プロジェクトのすべての変更点を記録しています．<br>
本仕様は [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) および [Semantic Versioning](https://semver.org/spec/v2.0.0.html) に基づいています．

<!-- ## [Unreleased]

### Added (新機能)

### Changed (仕様変更)

### Removed (機能廃止)

### Fixed (不具合修正) -->


<!-- ## [1.0.0](https://github.com/shobuzako-kensuke/LS-SPH-Benchmarks/releases/tag/v1.0.0) - 2026-03-23 -->

 ## [Unreleased]

### Added / 新機能

- Basic Fortran source codes in the [source/](/source/) directory<br>Fortranソースコードを [source/](/source/) ディレクトリに格納

- Basic analysis scripts in the [analysis/](/analysis/) directory<br>Python解析スクリプトを [analysis/](/analysis/) ディレクトリに格納
  
- Benchmark test including **Diffusion Equation Test**, **Taylor-Green Vortex**, **Lid-driven Cavity Flow**, and **Boussinesq Convection (Bottom-heated)**<br>ベンチマークテスト (**拡散方程式テスト**, **Taylor-Green渦**, **キャビティ流れ**, **ブシネスク対流**) を実装 

- [requirements.txt](/requirements.txt) for virtual environment<br>仮想環境構築に使用する [requirements.txt](/requirements.txt) を追加

- Documentation in [/materials/documents/](/materials/documents/) including the recommended settings for each benchmark test, the guide for [config.h](/config.h), and theoretical manual<br>各ベンチマークテストの推奨設定，[config.h](/config.h) の解説書，理論マニュアル等のドキュメント一式を [/materials/documents/](/materials/documents/) 内に追加

### Changed / 仕様変更

- Release tag in [CITATION.cff](/CITATION.cff)<br>リリースタグ [CITATION.cff](/CITATION.cff) を変更

- Added Japanese comments to [CHANGELOG.md](/CHANGELOG.md)<br>[CHANGELOG.md](/CHANGELOG.md) に日本語を追加

- Renamed the main analysis script from `analysis_main.py` to [analyze.py](/analyze.py)<br>メイン解析スクリプトの名称を `analysis_main.py` から [analyze.py](/analyze.py) に変更

- Enhanced [Makefile](/Makefile) to easily switch between Intel `ifx` and GNU `gfortran` compilers<br>[Makefile](/Makefile) を改良し，Intel `ifx` と GNU `gfortran` コンパイラの切り替えを容易化

- Initialization script ([initialize.py](/initialize.py)) to adapt to the new program structure<br>新しいプログラム構造に適合するように初期化スクリプト [initialize.py](/initialize.py) を変更

- Updated [README.md](/README.md) and added Japanese comments<br>[README.md](/README.md) の内容をアップデートし日本語を追加

### Removed / 機能廃止

- `CONTRIBUTIONS.md`
- `README_ja.md`

<br>

## [0.1.0](https://github.com/shobuzako-kensuke/LS-SPH-Benchmarks/releases/tag/v0.1.0) - 2026-04-20

### Added / 新機能

- [materials/](/materials/) directory for project documentation<br>説明書などを格納する [materials/](/materials/) ディレクトリを追加

- [source/](/source/) directory for Fortran source code<br>Fortranソースコードを格納する [source/](/source/) ディレクトリを追加

- [Makefile](/Makefile) for compiling the Fortran source code<br>Fortranソースコードをコンパイルするための [Makefile](/Makefile) を追加

- [config.h](/config.h) for setting up the simulation problem and input parameters<br>問題設定およびパラメータ設定を行う [config.h](/config.h) を追加

- [initialize.py](/initialize.py) for initialization<br>初期化スクリプト [initialize.py](/initialize.py) を追加

- `analysis_main.py` for analyzing simulation results<br>計算結果を解析する `analysis_main.py` を追加

### Changed / 仕様変更

- Added comments to [.gitignore](/.gitignore)<br>[.gitignore](/.gitignore) にコメントを追加

- Updated release tag in [CITATION.cff](/CITATION.cff)<br>リリースタグ [CITATION.cff](/CITATION.cff) を変更

- Updated contents of `CONTRIBUTIONS.md`<br>`CONTRIBUTIONS.md` を更新

- Updated [README.md](/README.md) and [README_ja.md](/README_ja.md)<br>[README.md](/README.md) および [README_ja.md](/README_ja.md) を更新

### Removed / 機能停止
- `input.f90` replaced by [config.h](/config.h)<br>`input.f90` を削除して代わりに [config.h](/config.h) を使用

<br>

## [0.0.0](https://github.com/shobuzako-kensuke/LS-SPH-Benchmarks/releases/tag/v0.0.0) - 2026-03-23

### Added / 新機能
- Initial release<br>初回リリース