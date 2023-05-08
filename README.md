# BehaviorDEPOT ReadME


- **Documentation is being moved over to the BehaviorDEPOT Wiki (https://github.com/DeNardoLab/BehaviorDEPOT/wiki). Head there for the latest documentation!**

- **BehaviorDEPOT has been published! For more information or to cite BehaviorDEPOT in your own work, check out our paper on eLife: https://elifesciences.org/articles/74314**

- BehaviorDEPOT v1.5 is now live! Please give it a try, and let us know of any issues you may encounter.

- View original BehaviorDEPOT pre-print on bioRxiv: https://www.biorxiv.org/content/10.1101/2021.06.20.449150v2

- Demo data is now available that can be used to test installation, classifiers, spatial/temporal filtering, and modules. Due to limitations on file size, the original video file (necessary to run the analysis module from scratch) is not available on Github but can be downloaded from: https://drive.google.com/drive/folders/1VNv9FuXyiI4xgt-RokcVvWk-1dBovuqO?usp=sharing

- Sample DeepLabCut networks that have been trained on our data are available for use. These may work on your own data, depending on the individual camera/chamber setup, but these models can serve as starting points for quickly training your own new networks! Find them here: https://drive.google.com/drive/folders/1Fl4PmLz6CWQcqOjfQ1q_60ZCZjI5949-?usp=sharing

## Patch Notes v1.5
### Major Updates 
- [x]  Drastically speed up pipeline (2-5x!!!) using parallel processing for smoothing (option to select in GUI) 
- [NOTE: requires Parallel Processing Toolbox]
- [x]  Most recent GUI settings are now loaded by default
- [x]  Classifier optimization module now supports batch analysis on a parent directory containing folders with BD output and human annotation files (hB)

### Minor Updates
- [x]  Added ability to re-use ROI name and/or limits in batch mode
- [x]  Added menu option to redraw an ROI
- [x]  Add option to select tracking file type (DLC H5, SLEAP H5, DLC CSV, etc.) from GUI
- [x]  Add ability to re-do part registration
    
### Bug Fixes
- [x]  Fixed issue with validation module output naming
- [x]  Fixed issue with optimization module initilization
- [x]  Fixed issue causing pipeline to crash using H5 files (DLC or SLEAP)
- [x]  Fixed issue with CSV detection (eliminate the requirement and force manual selection OR figure out a more complex way of doing it automatically)    

**----------------------------------------------------------------------------------------------------**

## BehaviorDEPOT
An open-sourced behavioral analysis toolbox designed to first compile and clean point-tracking output from DeepLabCut, and then classify behavioral epochs using custom behavior classifiers. 

## Motivation
We wanted a tool that seamlessly takes in output from DeepLabCut, smoothes out hiccups in tracking, and identifies bouts of specific behaviors, in particular freezing, as well as helpful metrics about animal movement. 

## Language, dependencies, and environments
BehaviorDEPOT was written using MATLAB 2020b and requires the following MATLAB toolboxes:
1) Signal Processing Toolbox
2) Curve Fitting Toolbox
3) Image Processing Toolbox
4) Statistics and Machine Learning Toolbox
5) Parallel Processing Toolbox **(Optional)**

Compatibility has been tested on Windows 10 and MacOS Catalina using Matlab 2018 - 2020b.

## Installation
BehaviorDEPOT is written as a MATLAB app. Simply open the install file and allow MATLAB to install BehaviorDEPOT. It will appear under the ‘apps’ tab in Matlab. Click the app to launch.
 
## Customization
BehaviorDEPOT is written to be flexible to enable users to generate custom classifiers for unique behaviors or arena situations. 
If you’re curious about any of the code, want to tweak it, or create your own classifier, you can access the underlying scripts by simply right clicking on the app and navigating to where the app files are installed. To edit the GUI, you can open the BehaviorDEPOT.mlapp file in MATLAB’s ‘App Designer’.

## Credits
BehaviorDEPOT was developed by Chris Gabirel, Benita Jin, Zachary Zeidler, and Laura DeNardo. If you find this tool useful, please cite the work:
{will be updated upon publication}

## License
This work is licensed under the GNU General Public License 3.0.

## Module Descriptions:

#### Data Prep Module:
Allows user to input one or more videos plus DLC-analyzed files to smooth tracking data, calculate a wide array of metrics, process custom ROI and temporal filters. Output of this module are several structures containing smoothed tracking and kinematic/postural metrics of animal behavior.

#### Behavior Analysis Module:
Allows user to use pre-built or customized classifier files to quantify behaviors with or without spatial and temporal filtering.

#### Inter-Rater Module:
Allows user to make comparisons and visualizations of behavior annotations from multiple users using an averaged-rater projection or a chosen rater as a reference; includes useful visualizations and the ability to output a report of errors between each user and the reference dataset.

#### Validation Module:
Allows user to choose a batch of BehDEPOT-analyzed files (with associated hBehavior files) and quickly generate performance statistics and visualizations for each video and average statistics for the entire set.

#### Classifier Optimization Module:
Allows user to choose a behavior classifier, 1-2 classifier parameters (i.e. thresholds), a range of test values, and a human annotation file to quickly examine effects of chosen values on classifier performance (reporting F1 score and ROC-based AUC values for range of tested parameters). Can be run on single sessions or batches of sessions with average performance reported.

#### Data Exploration Module:
Allows user to choose 1 or 2 metrics from a BehDEPOT-analyzed file and an associated hBehavior file to sort data by chosen behavior and generates a report comparing the behavior subset to the complete dataset based on the selected Metrics. Comes in 'Broad' and 'Focused' modes to help find and test metrics for new classifiers.
