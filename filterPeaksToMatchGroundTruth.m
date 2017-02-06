function [cleanPeakTimes, cleanPeakKeyNames] = filterPeaksToMatchGroundTruth( KeyInfo, peakTimes, PROXIMITY_THR_SEC )
% INPUT:
%  peakTimes: assumed to start at zero and aligned with KeyInfo times

pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
keyNames = KeyInfo.keyNames;

cleanPeakTimes = [];
cleanPeakKeyNames = {};
%cleanPeakWAVLocs = [];

% Find the ** best ** match for each ground truth key press
for kk = 1:length( keyNames )
    if pTimes(kk) > peakTimes(end) + PROXIMITY_THR_SEC
        break;
    end
    
    % Find best match
    distToTrue_kk = abs( pTimes(kk) - peakTimes);
        
    [bestDist, bestID] = min( distToTrue_kk );
        
    if bestDist < PROXIMITY_THR_SEC
        assert( KeyInfo.Toffset >= 0, 'not sure about this!!' );
            
        %cleanPeakWAVLocs(end+1) = detectedPeakLocs( bestID );
        cleanPeakKeyNames{end+1} = keyNames{kk};
        cleanPeakTimes(end+1) = peakTimes( bestID );
    end
    
end