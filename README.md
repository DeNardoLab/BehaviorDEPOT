# BehaviorDEPOT

BehaviorDEPOT is an open-source MATLAB toolbox for preparing rodent
pose-estimation data, classifying behavioral bouts, and analyzing spatial and
temporal behavior measures from DeepLabCut or SLEAP tracking output.

[Install](https://github.com/DeNardoLab/BehaviorDEPOT/releases/latest) ·
[Documentation](https://github.com/DeNardoLab/BehaviorDEPOT/wiki) ·
[Demo data](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Demo-Data) ·
[Paper](https://doi.org/10.7554/eLife.74314)

## Install

1. Download `BehaviorDEPOT_v1_7.mltbx` from the
   [latest release](https://github.com/DeNardoLab/BehaviorDEPOT/releases/latest).
2. In MATLAB, double-click the downloaded `.mltbx`, or choose **Home >
   Add-Ons > Install from File**.
3. Open the **Apps** tab and select **BehaviorDEPOTv1.7**.

See the Wiki for [installation details](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Installation-&-Dependencies),
[input preparation](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Inputs),
the [Analysis Module](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Analysis-Module),
and [outputs](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Outputs).

## Requirements and compatibility

BehaviorDEPOT v1.7 requires MATLAB and:

- Signal Processing Toolbox
- Curve Fitting Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox

The Parallel Computing Toolbox is optional. BehaviorDEPOT v1.7 is compatible
with MATLAB R2022b through R2026a Update 3 and has been tested on Windows 11
across that range.

## Start here

- [Prepare a first analysis](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Analysis-Module)
- [Organize batch-session inputs](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Inputs#batch-session-layout)
- [Use demo data](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Demo-Data)
- [Use validation, optimization, exploration, or inter-rater tools](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Support-Modules)
- [Get help with setup or input problems](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Help-&-Troubleshooting)

## Version 1.7

v1.7 adds persistent tracked-part registration defaults, redesigned tracked
part and ROI workflows, validated batch input handling, and improved output
and settings behavior. See [What's New in
v1.7](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/What's-new-in-v1.7)
and the complete [v1.7 changelog](v1.7%20CHANGELOG.md).

## Demo data and models

The repository includes tracking files and selected analysis outputs under
[`demo/`](demo). Download the associated source videos from the
[demo-data archive](https://drive.google.com/drive/folders/1VNv9FuXyiI4xgt-RokcVvWk-1dBovuqO?usp=sharing).
Sample DeepLabCut models are available from the
[model archive](https://drive.google.com/drive/folders/1Fl4PmLz6CWQcqOjfQ1q_60ZCZjI5949-?usp=sharing).

## Customize or build from source

The installer is intended for end users. For customization or to build a new
toolbox release, clone this repository and work from:

- [`project files/BehaviorDEPOT_GUI_v1_7.mlapp`](project%20files/BehaviorDEPOT_GUI_v1_7.mlapp):
  editable App Designer source;
- [`project files/BehaviorDEPOTv1.7.prj`](project%20files/BehaviorDEPOTv1.7.prj):
  MATLAB project file; and
- [`project files/toolbox.ignore`](project%20files/toolbox.ignore): packaging
  exclusions for future toolbox builds.

Behavior classifiers and supporting runtime code are under [`code/`](code).
See [Customization](https://github.com/DeNardoLab/BehaviorDEPOT/wiki/Customizing-BehaviorDEPOT)
for guidance. Do not edit the MATLAB-managed installed add-on.

## Citation

Gabriel CJ, Zeidler Z, Jin B, Guo C, Goodpaster CM, Kashay AQ, Wu A, Delaney
M, Cheung J, DiFazio LE, Sharpe MJ, Aharoni D, Wilke SA, DeNardo LA. 2022.
BehaviorDEPOT is a simple, flexible tool for automated behavioral detection
based on markerless pose tracking. *eLife* 11:e74314.
https://doi.org/10.7554/eLife.74314

## License

BehaviorDEPOT is released under the [GNU General Public License v3.0](LICENSE).
