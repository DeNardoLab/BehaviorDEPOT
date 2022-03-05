function Params = makeParamsStruct(P)

    %% Copy Classifier Parameters from P.Params struct
    Params = P.Params;
    
    %% Basic Information
    Params.Video = P.Video;
    Params.roi_name = P.roi_name;
    Params.tracking_fileType = P.tracking_fileType;
    Params.hampel = P.hampel;
    Params.hampel_span = P.hampel_span;
    Params.cutoffThreshold = P.cutoffThreshold;
    
    %% Smoothing Params
    Params.Smoothing.method = P.smoothMethod;
    Params.Smoothing.span = P.smoothSpan;
    
    %% Spatial ROI Params
    Params.do_roi = P.do_ROI;
    Params.num_roi = P.number_ROIs;
    Params.roi = P.roi_limits;

    Params.plotSpace = P.viewSpatialTrajectory;
    Params.plotSpaceTime = P.viewSpatioTemporalTrajectory;
    Params.plotBeh = P.viewBehaviorLocations;
    Params.do_events = P.do_events;

    %% Misc Params
    Params.px2cm = round(P.px2cm);
    Params.cueFile = [];
    Params.batchSession = P.batchSession;
    if P.batchSession == 1
        Params.reuse_cue_name = P.reuse_cue_name;
    end
end