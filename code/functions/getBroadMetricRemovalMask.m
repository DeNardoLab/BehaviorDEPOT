function toRemove = getBroadMetricRemovalMask(coefficients, numMetrics)
%getBroadMetricRemovalMask Select weak metric coefficients for removal.

arguments
    coefficients {mustBeNumeric, mustBeVector}
    numMetrics (1,1) double {mustBeInteger, mustBeNonnegative}
end

if numel(coefficients) ~= numMetrics + 1
    error('BehaviorDEPOT:getBroadMetricRemovalMask:CoefficientCountMismatch', ...
        'Expected one GLM intercept plus one coefficient per metric.');
end

toRemove = reshape(abs(coefficients(2:end)) < 1, 1, []);
end
