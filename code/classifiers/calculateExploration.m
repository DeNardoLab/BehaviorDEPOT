% BehaviorDEPOT Exploration Classifier File
% ZZ 2022.03.07

%FUNCTION: calculate object exploration

function Exploration = calculateExploration(Params, Tracking, Metrics)    

    %% Select the thresholds for the behavior you wish to capture:
    % You may set any number of different thresholds that work with your behavior-of-interest.
    % The thresholds themselves are set in the associated 'P_' file
    objDistThresh = Params.Exploration.objDistThresh;
    noseDist = Params.Exploration.noseDist;
    px2cm = Params.px2cm;
    
    %% Calculate object exploration perimeter
    obj_roi = Params.roi{1,1};
    tmp = polygeom(obj_roi(:,1),obj_roi(:,2));  % get center of object
    obj_x = tmp(2);
    obj_y = tmp(3);
    
    roi_ext = zeros(size(obj_roi));  % instantiate matrix for new roi
    
    % move extended point relative to object center
    for i = 1:length(obj_roi)
        i_pt = obj_roi(i,:);
        v = i_pt - [obj_x obj_y];
        i_dist = pdist([i_pt; obj_x obj_y]);
        scale = (i_dist+px2cm*objDistThresh) / i_dist;
        roi_ext(i,:) = [obj_x obj_y] + v*scale;
    end
        
    %% find nose in ROI and head angle toward object
    nose = Tracking.Smooth.Nose;
    nose_in = inpolygon(nose(1,:),nose(2,:),roi_ext(:,1),roi_ext(:,2));
    
    head = Tracking.Smooth.BetwEars;
    ang_in = zeros(size(nose_in)); % create empty angle vector
    nose_in_ind = find(nose_in == 1);  % index of possible vectors
    for i = 1:length(nose_in_ind)
        j = nose_in_ind(i);
        v = nose(:,j) - head(:,j);
        i_dist = pdist([nose(:,j); head(:,j)]);
        pt_ext = head(:,j) + v*10;
        % extend line from head to nose, sample points along line
        [xx,yy]=fillline(head(:,j), pt_ext, 10*10*objDistThresh*px2cm);        
        % determine if line intersects with original object roi
        tmp_in = inpolygon(xx,yy,obj_roi(:,1),obj_roi(:,2));
        if sum(tmp_in) > 0
            ang_in(j) = 1;
        end
    end
    
    % exclude when nose is within original ROI (climbing)
    roi_small = zeros(size(obj_roi));  % instantiate matrix for new roi
    
    % shrink roi points
    for i = 1:length(obj_roi)
        i_pt = obj_roi(i,:);
        v = i_pt - [obj_x obj_y];
        i_dist = pdist([i_pt; obj_x obj_y]);
        scale = (i_dist-(noseDist*px2cm)) / i_dist;
        roi_small(i,:) = [obj_x obj_y] + v*scale;
    end
    
    % get points for nose in small ROI, then create inverse binary vector
    % use of inverse vector is to sum all components
    climb_tmp = inpolygon(nose(1,:),nose(2,:),roi_small(:,1),roi_small(:,2));
    climb_in = ones(size(ang_in));
    climb_in(find(climb_tmp == 1)) = 0;
    
    % same for between ears or tail is in object ROI (climbing)
    head_tmp = inpolygon(head(1,:),head(2,:),obj_roi(:,1),obj_roi(:,2));
    head_in = ones(size(ang_in));
    head_in(find(head_tmp == 1)) = 0;
    
    tail = Tracking.Smooth.Tailbase;
    tail_tmp = inpolygon(tail(1,:),tail(2,:),obj_roi(:,1),obj_roi(:,2));
    tail_in = ones(size(ang_in));
    tail_in(find(tail_tmp == 1)) = 0;
    
    % find intersection of vectors
    vec_add = nose_in + ang_in + climb_in + head_in + tail_in;
    withinBehaviorThreshold_ind = find(vec_add == 5);
    withinBehaviorThreshold = zeros(size(ang_in));
    withinBehaviorThreshold(withinBehaviorThreshold_ind) = 1;
    %% Convolve raw behavior frames to smooth behavior labeling
    % Units for windowWidth and countThreshold is frames (not seconds)
    
    % In our hands, windowWidth is usually best at around the size of
    % the smallest behavior bout you wish to detect
    
    % countThreshold can vary more from behavior-to-behavior; however, ~1/3
    % the value of the windowWidth is usually a decent value
    % behavior is abrupt; do not want to smooth
    % smoothed_frames = convolveFrames(withinBehaviorThreshold, Params.Exploration.windowWidth, Params.Exploration.countThreshold);
    smoothed_frames = withinBehaviorThreshold;
    %% Collect list of start/stop inds from post-convolution vector
    [behavior_start_inds, behavior_stop_inds] = findStartStop(smoothed_frames);
    
    %% Apply minimum duration threshold to start/stop inds
    % Units for Params.BehaviorName.minDuration is in seconds (not frames)
    [behavior_start_inds, behavior_stop_inds] = applyMinThreshold(behavior_start_inds, behavior_stop_inds, Params.Exploration.minDuration, Params.Video.frameRate);

    %% Apply maximum duration threshold to start/stop inds
    % Units for Params.BehaviorName.maxDuration is in seconds (not frames)
    
    %% Generate behavior structure
    % This function will package the final data into a structure for output
    % Be sure to change 'BehaviorName' to your behavior both here and at
    % the function call line (at the top)
    Exploration = genBehStruct(behavior_start_inds, behavior_stop_inds, Params.numFrames);


%% Support functions
function [ geom, iner, cpmo ] = polygeom( x, y ) 
%POLYGEOM Geometry of a planar polygon
%
%   POLYGEOM( X, Y ) returns area, X centroid,
%   Y centroid and perimeter for the planar polygon
%   specified by vertices in vectors X and Y.
%
%   [ GEOM, INER, CPMO ] = POLYGEOM( X, Y ) returns
%   area, centroid, perimeter and area moments of 
%   inertia for the polygon.
%   GEOM = [ area   X_cen  Y_cen  perimeter ]
%   INER = [ Ixx    Iyy    Ixy    Iuu    Ivv    Iuv ]
%     u,v are centroidal axes parallel to x,y axes.
%   CPMO = [ I1     ang1   I2     ang2   J ]
%     I1,I2 are centroidal principal moments about axes
%         at angles ang1,ang2.
%     ang1 and ang2 are in radians.
%     J is centroidal polar moment.  J = I1 + I2 = Iuu + Ivv
 
% H.J. Sommer III - 16.12.09 - tested under MATLAB v9.0
% H.J. Sommer III, Ph.D., Professor of Mechanical Engineering, 337 Leonhard Bldg
% The Pennsylvania State University, University Park, PA  16802
% (814)863-8997  FAX (814)865-9693  hjs1-at-psu.edu  www.mne.psu.edu/sommer/
 
% check if inputs are same size
if ~isequal( size(x), size(y) ),
  error( 'X and Y must be the same size');
end
 
% temporarily shift data to mean of vertices for improved accuracy
xm = mean(x);
ym = mean(y);
x = x - xm;
y = y - ym;
  
% summations for CCW boundary
xp = x( [2:end 1] );
yp = y( [2:end 1] );
a = x.*yp - xp.*y;
 
A = sum( a ) /2;
xc = sum( (x+xp).*a  ) /6/A;
yc = sum( (y+yp).*a  ) /6/A;
Ixx = sum( (y.*y +y.*yp + yp.*yp).*a  ) /12;
Iyy = sum( (x.*x +x.*xp + xp.*xp).*a  ) /12;
Ixy = sum( (x.*yp +2*x.*y +2*xp.*yp + xp.*y).*a  ) /24;
 
dx = xp - x;
dy = yp - y;
P = sum( sqrt( dx.*dx +dy.*dy ) );
 
% check for CCW versus CW boundary
if A < 0,
  A = -A;
  Ixx = -Ixx;
  Iyy = -Iyy;
  Ixy = -Ixy;
end
 
% centroidal moments
Iuu = Ixx - A*yc*yc;
Ivv = Iyy - A*xc*xc;
Iuv = Ixy - A*xc*yc;
J = Iuu + Ivv;
 
% replace mean of vertices
x_cen = xc + xm;
y_cen = yc + ym;
Ixx = Iuu + A*y_cen*y_cen;
Iyy = Ivv + A*x_cen*x_cen;
Ixy = Iuv + A*x_cen*y_cen;
 
% principal moments and orientation
I = [ Iuu  -Iuv ;
     -Iuv   Ivv ];
[ eig_vec, eig_val ] = eig(I);
I1 = eig_val(1,1);
I2 = eig_val(2,2);
ang1 = atan2( eig_vec(2,1), eig_vec(1,1) );
ang2 = atan2( eig_vec(2,2), eig_vec(1,2) );
 
% return values
geom = [ A  x_cen  y_cen  P ];
iner = [ Ixx  Iyy  Ixy  Iuu  Ivv  Iuv ];
cpmo = [ I1  ang1  I2  ang2  J ];
end

function [xx,yy]=fillline(startp,endp,pts)
% take starting, ending point & number of points in between, make line to connect between 2 coordinates
% shaz (2022). Get points for a line between 2 points 
% (https://www.mathworks.com/matlabcentral/fileexchange/29104-get-points-for-a-line-between-2-points), MATLAB Central File Exchange. Retrieved February 24, 2022.
        m=(endp(2)-startp(2))/(endp(1)-startp(1)); %gradient 

        if m==Inf %vertical line
            xx(1:pts)=startp(1);
            yy(1:pts)=linspace(startp(2),endp(2),pts);
        elseif m==0 %horizontal line
            xx(1:pts)=linspace(startp(1),endp(1),pts);
            yy(1:pts)=startp(2);
        else %if (endp(1)-startp(1))~=0
            xx=linspace(startp(1),endp(1),pts);
            yy=m*(xx-startp(1))+startp(2);
        end
end
end