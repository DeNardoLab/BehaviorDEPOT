# BehaviorDEPOT ReadME

## Documentation is being moved over to the BehaviorDEPOT Wiki page (https://github.com/DeNardoLab/BehaviorDEPOT/wiki). Head there to check out updated documentation!

- BehaviorDEPOT v1.7 is now live! Please give it a try, and let us know of any issues you may encounter.

- To find out more about BehaviorDEPOT or to cite the software in your own paper, see our publication: https://elifesciences.org/articles/74314

- Demo data is now available that can be used to test installation, classifiers, spatial/temporal filtering, and modules. Due to limitations on file size, the original video file (necessary to run the analysis module from scratch) is not available on Github but can be downloaded from: https://drive.google.com/drive/folders/1VNv9FuXyiI4xgt-RokcVvWk-1dBovuqO?usp=sharing

- Sample DeepLabCut networks that have been trained on our data are available for use. These may work on your own data, depending on the individual camera/chamber setup, but these models can serve as starting points for quickly training your own new networks! Find them here: https://drive.google.com/drive/folders/1Fl4PmLz6CWQcqOjfQ1q_60ZCZjI5949-?usp=sharing

**----------------------------------------------------------------------------------------------------**

# BehaviorDEPOT

BehaviorDEPOT is an open-source MATLAB app for preparing pose-tracking data,
classifying behavioral bouts, and analyzing spatial and temporal behavior
measures from DeepLabCut or SLEAP tracking output.

## Version 1.7

BehaviorDEPOT v1.7 adds persistent keypoint-registration defaults, redesigned
keypoint-registration and ROI workflows, improved noninteractive pipeline
support, and more reliable output handling.

See v1.7 CHANGELOG for the complete release notes.

## Installation

1. Download `BehaviorDEPOT_v1_7.mltbx` from the latest GitHub release.
2. Open the downloaded file in MATLAB and follow the Add-On installation
   prompts.
3. Launch BehaviorDEPOT from the MATLAB **Apps** tab.

For detailed usage instructions, see the BehaviorDEPOT Wiki (https://github.com/DeNardoLab/BehaviorDEPOT/wiki).

## Requirements

BehaviorDEPOT requires MATLAB and these products:

- Curve Fitting Toolbox
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox
- Image Processing Toolbox
- Parallel Computing Toolbox (optional)

## Quick Start

1. Launch BehaviorDEPOT from the MATLAB **Apps** tab.
2. Select one or more behavior classifiers and adjust their parameters as
   needed.
3. Set the pixel-to-centimeter calibration.
4. Choose single-session or batch processing.
5. Select the tracking and video files, then follow prompts to register
   tracked body parts, define ROIs, or configure temporal cues.
6. Start analysis. Results are saved in an `_analyzed` folder next to the
   source video.

For batch processing, each session folder should contain one video and its
matching tracking file. Optional cue files must include `cue` in the filename.

## v1.7 Highlights

- Persistent keypoint-registration defaults for previously seen tracking labels.
- Side-by-side keypoint registration with tracking-preview support.
- Redesigned ROI selection with naming, redraw, delete, and cancel controls.
- Noninteractive support for explicit file manifests and validated inputs.
- Output folders use the video filename without its extension.
- Improved path handling across analysis and supporting modules.

## Manual Annotations

Use `convertHumanAnnotations_BD` to convert manual annotations into
BehaviorDEPOT-compatible `hB_*.mat` files. Annotation tables must contain:

1. Start frame
2. Stop frame
3. Behavior label

Input tables can be `.mat` or `.csv` files.

## Customization

The editable App Designer source is
`BehaviorDEPOT_GUI_v1_7.mlapp`. Behavior classifiers and supporting functions
are located under `code`.

Deprecated compatibility utilities are retained under `code/deprecated` and
are not part of the supported runtime API.

## Demo Data and Models

- Demo data: (https://drive.google.com/drive/folders/1VNv9FuXyiI4xgt-RokcVvWk-1dBovuqO?usp=sharing)
- Example DeepLabCut networks: (https://drive.google.com/drive/folders/1Fl4PmLz6CWQcqOjfQ1q_60ZCZjI5949-?usp=sharing)

## Citation

Please cite:

Gabriel C, Jin B, Zeidler Z, DeNardo LA. BehaviorDEPOT: an open-source
application for automated analysis of rodent behavior. *eLife*.
https://elifesciences.org/articles/74314

## License

BehaviorDEPOT is released under the [GNU General Public License v3.0](LICENSE).
**----------------------------------------------------------------------------------------------------**

### Module Descriptions:

#### Analysis Module:
Allows user to input one or more videos plus DLC-analyzed files to smooth tracking data, calculate a wide array of metrics, and classify behaviors with or without spatial and temporal filtering.

#### Inter-Rater Module:
Allows user to make comparisons and visualizations of behavior annotations from multiple users using an averaged-rater projection or a chosen rater as a reference; includes useful visualizations and the ability to output a report of errors between each user and the reference dataset.

#### Validation Module:
Allows user to choose a batch of BehDEPOT-analyzed files (with associated hBehavior files) and quickly generate performance statistics and visualizations for each video and average statistics for the entire set.

#### Classifier Optimization Module:
Allows user to choose a behavior classifier, 1-2 classifier parameters (i.e. thresholds), a range of test values, and a human annotation file to quickly examine effects of chosen values on classifier performance (reporting F1 score and ROC-based AUC values for range of tested parameters)

#### Data Exploration Module:
Allows user to choose 1 or 2 metrics from a BehDEPOT-analyzed file and an associated hBehavior file to sort data by chosen behavior and generates a report comparing the behavior subset to the complete dataset based on the selected Metrics.
