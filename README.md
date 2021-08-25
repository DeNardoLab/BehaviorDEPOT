# BehaviorDEPOT ReadME

- BehaviorDEPOT is currently pre-release and is undergoing a substantial update that should be released late-Aug 2021 (v1.0)

- To find out more about BehaviorDEPOT or to cite the software in your own paper, see our pre-print on bioRxiv: https://www.biorxiv.org/content/10.1101/2021.06.20.449150v1

- Demo data is now avaiable that can be used to test installation, classifiers, and modules. Due to limitations on file size, the original video file (necessary to run the analysis module from scratch) is not available on Github but can be downloaded from: https://drive.google.com/file/d/1SC1w37i0pgUdB_-ShLc-LCrIKkbUh9va/view?usp=sharing

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

**----------------------------------------------------------------------------------------------------**

## BehaviorDEPOT
An open-sourced behavioral analysis toolbox designed to first compile and clean point-tracking output from DeepLabCut, and then classify behavioral epochs using custom behavior classifiers. 

## Motivation
We wanted a tool that seamlessly takes in output from DeepLabCut, smoothes out hiccups in tracking, and identifies bouts of specific behaviors, in particular freezing, as well as helpful metrics about animal movement. 

## Language, dependencies, and environments
BehaviorDEPOT was written using MATLAB 2020b and requires the Signal Processing Toolbox, Image Processing Toolbox, and Statistics and Machine Learning Toolbox.
Compatibility has been tested on Windows 10 and MacOS Catalina using Matlab 2018 - 2020b.
Installation
BehaviorDEPOT is written as a MATLAB app. Simply open the install file and allow MATLAB to install BehaviorDEPOT. It will appear under the ‘apps’ tab in Matlab. Click the app to launch.
 
## Customization
BehaviorDEPOT is written to be flexible to enable users to generate custom classifiers for unique behaviors or arena situations. 
If you’re curious about any of the code, want to tweak it, or create your own classifier, you can access the underlying scripts by simply right clicking on the app and navigating to where the app files are installed. To edit the GUI, you can open the BehaviorDEPOT.mlapp file in MATLAB’s ‘App Designer’.

## Credits
BehaviorDEPOT was developed by Chris Gabirel, Benita Jin, Zachary Zeidler, and Laura DeNardo. If you find this tool useful, please cite the work:
{will be updated upon publication}

## License
This work is licensed under the GNU General Public License 3.0.

**----------------------------------------------------------------------------------------------------**

# USAGE GUIDE

### Analysis Module
1) After installation, launch BehaviorDEPOT from App window in Matlab.

2) Select which classifiers to use:
    - Certain classifiers have adjustable parameters. Click on ‘Edit Params’ to adjust those parameters.
    
3) Set distance calibration
    - Calibration can be calculated using ImageJ. Open a frame from a video and measure out the pixel distance of a known dimension (e.g. arena length). Use that to calculate the        pixel-to-centimeter ratio.
    
4) Enter number of ROIs

5) Choose whether or not to filter based on frame-locked events
    - Input for these is required to be a spreadsheet file (.csv, .xlsx), with each event as a row, the start frame in the first column and the end frame in the second column.

6) Select plotting preferences
    - ‘View Spatial Trajectory’ plots all the positions of the animal across the session.
    - ‘View spatiotemporal trajectory’ plots position across time, color coding the location points.
    - ‘View behavior location’ overlays a marker on the locations where behavior(s) of interest occurred.

7) Select single session or batch process
    - Single session for analyzing one paired DLC output and video file.
    - Batch process for analyzing multiple files with the same parameters. The required input structure for batch processing:
      - Grandparent folder, which is selected for analysis.
        - Parent folder 1 (Containing exclusively a single, matching pair of spreadsheet and video files)
             \**A single event file can also be included, and must be indicated with ‘cue’ in the filename (eg myevents_cue.csv)*
        - Parent folder 2 (same as above)
        - Parent folder n (same as above)

8) Hit Start.
 
9) Follow the onscreen prompts to enter and customize your data. Depending on your settings:
    - If doing ‘single session’, you will be prompted to use the directory browser to select the spreadsheet and video files for analysis. 
    - If doing ‘batch process’, you will be prompted to select the folder containing directories for analysis (see batch process instructions for data organization)
    - You may be prompted by the GUI to draw and name ROIs or parts of the arena, depending on your settings.
    - You will be prompted to select the body part corresponding to your custom named part.
    - You may be prompted to select timestamp files containing the start and stop frames of temporal events, and then name those events.
    
10) Results will be saved in a new folder in the same directory as the data.

### Converting Manual Annotations to BehaviorDEPOT format (hB files)
1) Save manual annotations as a 3 column table (1st: Start Frame, 2nd: Stop Frame, 3rd: Behavior Label)
    - Function is compatible with data tables in .mat or .csv files
    - To import data from larger excel/csv files, select "import data" in Matlab and create 3 column tables for each video analyzed
    - After importing data as a table, save the table file as a .mat

2) Run convertHumanAnnotations function in Matlab
    - Inputs: 
      - 1) table_filename: str/char pointing to MATLAB table file (requires path if not in current directory)
      - 2) total_frames: int, optional total number of frames in analyzed video
        - NOTE: if total_frames is empty, function will use the video file IF IN SAME FOLDER AS INPUT TABLE
      - 3) output_filename: str/char, optional; (default behavior = hB_[original filename])
  
3) Results will be saved as an hBehavior structure (similar in format to Behavior structures from Analysis Module)
    - File name will be 'hB_[original filename]' or named as [output_filename] if applicable

### Output: Analysis Module
1) Data is saved in separate analysis folder within the directory of the tracking spreadsheet.

2) Depending on settings, output will include:
    - ‘Behavior Bouts.fig’ - a plot indicating when behavior occurred across time
    - ‘[BehaviorName] Map.fig’ - a map of the animal location across time, with location of behaviors indicated
    - Behavior.mat - struct containing all behaviors analyzed. Within each behavior struct:
      - Bouts: start and stop frames of each behavior bout
      - Count: number of behavior bouts
      - Length: duration of each behavior bout
      - Vector:  behavior vector across all frames
    - Metrics.mat - a struct containing information about speed, movement, and velocity of the tracked parts
      - Diff: contains the location differential across frames for various points
      - Velocity: the velocity at each frame
      - Acceleration: the acceleration at each frame
      - Location:  location of animal
      - Movement_cmpersec:  movement speed in cm/sec
      - DistanceTravelled_cm: total distance traveled in cm
    - Tracking.mat - a struct containing the location of each tracked part
      - The first layer of Tracking contains the original information from the tracking spreadsheet
      - Smooth: contains the location of each tracked part after smoothing
    - Behavior_Filter.mat - contains Behavior information filtered by space or time
      - Temporal: contains Behavior information during cue frames
        - EventVector: a vector indicating when the events occurred
        - EventBouts: start and stop frames of each event
        - [Behavior]: e.g. Freezing
          - BehInEventVector:  vector when behavior occurred during an event (ie both EventVector and BehaviorVector are true)
          - Cue_BehInEventVector: events as rows, each containing a vector representing behavior
          - PerBehInEvent:  percent behavior in event. Proportion of behavior occurring during the event (vs outside of the event)
          - PerBehDuringCue:  percent of event duration that behavior occurs.
            \**Eg if Freezing occurred for 50% of first event, and 30% of second event, values would be {0.5, 0.3}*
      - Spatial: contains Behavior information in ROIs
        - PerTimeInROI:  percent total time spent in the ROI
        - inROIVector:  vector of whether animal was in ROI or not
        - [Behavior]
          - inROIbehaviorVector: vector of when animal was in ROI and engaging in behavior (eg both inROIVector and BehaviorVector are true)
          - PerBehaviorInROI:  percent of behavior that occurred within the ROI
      - Intersect
        - SpaTemBeh:  intersection of spatial, temporal, and behavior vectors
        - ROIduringCue_PerTime:  percent time of event that animal spent in ROI
        - ROIduringCue_Vector:  vector, one row per event, of when animal was in ROI during each event

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
