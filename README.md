# BehaviorDEPOT

BehaviorDEPOT is currently pre-release and is undergoing a substantial update that should be released late-Aug 2021 (v1.0)

Demo data is now avaiable that can be used to test installation, classifiers, and modules. Due to limitations on file size, the original video file (necessary to run the analysis module from scratch) is not available on Github but can be downloaded from: https://drive.google.com/file/d/1SC1w37i0pgUdB_-ShLc-LCrIKkbUh9va/view?usp=sharing

**Patch Notes v0.51**
- Updated smoothing algorithm to better perform on behavior videos
- Updated freezing algorithm sliding convolution values
- Removed option to select video file type; changed code to automatically detect video
- Patched minor bugs in analysis, exploration, and optimization modules
- Updated code structure of validation and inter-rater modules
- Updated inter-rater module to match current directory structure
- Updated inter-rater module to automatically identify 'hB' and 'analyzed folders'
- Updated validation module to match current directory structure
- Updated validation module with enhanced plotting features
- Updated prepBatch.m to automatically ignore results folders in data directories


**Module Descriptions:**

**Analysis Module:** Allows user to input one or more videos plus DLC-analyzed files to smooth tracking data, calculate a wide array of metrics, and classify behaviors with or without spatial and temporal filtering.

**Inter-Rater Module:** Allows user to make comparisons and visualizations of behavior annotations from multiple users using an averaged-rater projection or a chosen rater as a reference; includes useful visualizations and the ability to output a report of errors between each user and the reference dataset.

**Validation Module:** Allows user to choose a batch of BehDEPOT-analyzed files (with associated hBehavior files) and quickly generate performance statistics and visualizations for each video and average statistics for the entire set.

**Classifier Optimization Module:** Allows user to choose a behavior classifier, 1-2 classifier parameters (i.e. thresholds), a range of test values, and a human annotation file to quickly examine effects of chosen values on classifier performance (reporting F1 score and ROC-based AUC values for range of tested parameters)

**Data Exploration Module:** Allows user to choose 1 or 2 metrics from a BehDEPOT-analyzed file and an associated hBehavior file to sort data by chosen behavior and generates a report comparing the behavior subset to the complete dataset based on the selected Metrics. 
