function Params = makeParamsStruct(P)

    %% Copy Classifier Parameters from P.Params struct
    Params = P.Params;
    
    %% Basic Information
    Params.Video = P.Video;
    Params.tracking_type = P.tracking_type;
    Params.hampel = P.hampel;
    Params.hampel_span = P.hampel_span;
    Params.cutoffThreshold = P.cutoffThreshold;
    
    %% Smoothing Params
    Params.Smoothing.method = P.smoothMethod;
    Params.Smoothing.span = P.smoothSpan;
    Params.Smoothing.useGPU = P.use_GPU;
    
    %% Spatial ROI Params
    Params.do_roi = P.do_ROI;
    if Params.do_roi
        Params.num_roi = P.number_ROIs;
        Params.roi = P.roi_limits;
        Params.roi_names = P.roi_names;
    end
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
        Params.reuse_roi_names = P.reuse_roi_names;
        Params.reuse_roi_limits = P.reuse_roi_limits;
    end
end