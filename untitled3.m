

tic
parpool
parfor i = 1:2
    smooth(Tracking.Raw.nose(i,:),20,'lowess');
end
toc

tic
for i = 1:2
    smooth(Tracking.Raw.nose(i,:),20,'lowess');
end
toc