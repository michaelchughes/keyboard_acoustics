function KeyInfo = alignWAVandGroundTruth( wavfilename, detectedPeakTimes, KeyInfo, PEAK_WIDTH_SEC )

%if isfield( KeyInfo, 'Toffset' )
%    return;
%end

%  ----------------------------------------------- Find offset
%  Find match between detected peaks and first 5 true presses

nVerify = 5;
GT_START = KeyInfo.pTimes( 1:nVerify );
didFindAcceptable = 0;
for dd = 1:15
    DETECT_START = detectedPeakTimes( dd-1 + (1:nVerify)  );
    
    eachError = abs( DETECT_START - GT_START );
    medError = median( eachError );
    if all( abs(eachError - medError ) < PEAK_WIDTH_SEC/4  )
        didFindAcceptable = 1;
        break;
    end
end

assert( 1==didFindAcceptable, 'ERROR: could not align !' );

% % indicates how much to add to GT to make it align with detections
KeyInfo.Toffset = detectedPeakTimes(dd);

% if ~isfield( KeyInfo, 'wavNames' )
%     KeyInfo.wavNames = {};
%     KeyInfo.Toffset = [];
% end
% mm = strmatch( wavfilename, KeyInfo.wavNames )
% if isempty( mm )
%     KeyInfo.Toffset(end+1) = detectedPeakTimes(dd);
%     KeyInfo.wavNames{ end+1 } = wavfilename;
% else
%     KeyInfo.Toffset(mm) = detectedPeakTimes(dd);
% end