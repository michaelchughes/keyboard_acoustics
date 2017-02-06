function [durationCounts, durationBounds] = makeHistogramPressDurations(  pTimes, rTimes, keyNames, queryName )

MAX_DUR = 0.5;
pressDurations = rTimes - pTimes;

if exist( 'queryName', 'var' )
    if strcmp( queryName, 'shift' )
        keepIDs = union( strmatch( '<left shift>', keyNames), strmatch('<right shift>', keyNames)  );
    else
        keepIDs = strmatch( queryName, keyNames );
    end
else
    queryName = 'All Keys';
    keepIDs = 1:length(pressDurations);
end


durationBounds = linspace(0, 0.5, 30);
durationCounts = histc( pressDurations( keepIDs), durationBounds );

figure;
bar( [durationBounds(1:end-1) 0.5], durationCounts/sum(durationCounts) );
title( ['Press Duration Histogram - ' queryName] );
xlim( [0 MAX_DUR] );

end