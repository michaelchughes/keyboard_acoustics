close all;

DATA = load('/data/liv/mhughes/KeyboardAcoustics/data/ENRON_micMacbook/detectTrue/descrFFT_wSize100-minFreqHz0-maxFreqHz12000/XY.mat' );
KeyInfo = load('/data/liv/mhughes/KeyboardAcoustics/data/ENRON_micMacbook/detectTrue/descrFFT_wSize100-minFreqHz0-maxFreqHz12000/KeyInfo.mat' );
KeyInfo = KeyInfo.KeyInfo{1};


X = DATA.X;
Y = DATA.Y;
nKeys = length(Y);

keyNames = KeyInfo.keyNames(2:nKeys+1);
pTimes = KeyInfo.pTimes(2:nKeys+1);
rTimes = KeyInfo.rTimes(2:nKeys+1);

spaceINDS = strmatch( '<space>', keyNames );
shiftINDS = union( strmatch( '<left shift>', keyNames ),  strmatch( '<right shift>', keyNames ) );


makeHistogramPressDurations( pTimes, rTimes, keyNames );
makeHistogramPressDurations( pTimes, rTimes, keyNames, 'shift' );
makeHistogramPressDurations( pTimes, rTimes, keyNames, '<space>');
% pressDurations = rTimes - pTimes;
% [~, sortIDs] = sort( pressDurations );
% 
% durationBounds = linspace(0, 0.5, 30);
% durationBounds(end) = Inf;
% durationCounts = histc( pressDurations, durationBounds );
% 
% 
% spaceDurCounts = histc( pressDurations(spaceINDS), durationBounds );
% figure;
% bar( [durationBounds(1:end-1) 0.5], spaceDurCounts );
% 
% 
% shiftDurCounts = histc( pressDurations(shiftINDS), durationBounds );
% figure;
% bar( [durationBounds(1:end-1) 0.5], shiftDurCounts );