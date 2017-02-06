function [X, Ytrue] = getGroundTruthMFCCs( wavfilename, detectedPeakTimes, KeyInfo, MAX_FREQ, MFCC_FRAME_WIDTH_SEC, MFCC_FRAME_SHIFT_SEC, MFCC_NUM_COEFS, MFCC_NUM_FRAMES)
PROXIMITY_THR_SEC = 0.025;
MAX_PLOT_SEC = 2;
nDS = 1; % downsample factor
[wav_sound, sampleFreq] = wavread( wavfilename );
wav_time = ( 1:length(wav_sound) ) / sampleFreq;

detectedPeakLocs = ceil( KeyInfo.Toffset*sampleFreq ) + ceil( (eps+detectedPeakTimes) * sampleFreq );

MFCC_FRAME_SHIFT = round( MFCC_FRAME_SHIFT_SEC*sampleFreq );
MFCC_FRAME_WIDTH = round( MFCC_FRAME_WIDTH_SEC*sampleFreq );
MAX_TIME_SEC = length(wav_sound)/sampleFreq;

pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
rTimes = KeyInfo.rTimes - KeyInfo.pTimes(1);
keyNames = KeyInfo.keyNames;

cleanPeakTimes = [];
cleanPeakKeyNames = {};
cleanPeakWAVLocs = [];

% Find the ** best ** match for each ground truth key press
for kk = 1:length( keyNames )
    if pTimes(kk) > MAX_TIME_SEC
        break;
    end
    
    % Find best match
    distToTrue_kk = abs( pTimes(kk) - detectedPeakTimes);
        
    [bestDist, bestID] = min( distToTrue_kk );
        
    if bestDist < PROXIMITY_THR_SEC
        assert( KeyInfo.Toffset >= 0, 'not sure about this!!' );
            
        cleanPeakWAVLocs(end+1) = detectedPeakLocs( bestID );
        cleanPeakKeyNames{end+1} = keyNames{kk};
        cleanPeakTimes(end+1) = detectedPeakTimes( bestID );
    end
    
end


Tstart = 1;
Tstop = 10*MAX_PLOT_SEC;
pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
rTimes = KeyInfo.rTimes - KeyInfo.pTimes(1);
cleanPeaks = zeros( size( wav_sound) );
cleanPeaks( cleanPeakWAVLocs ) = 1;
curKeyID = 1;
 for ww = 1:min(5,ceil(  (Tstop-Tstart)/MAX_PLOT_SEC ) )
        
        figure(200+ww);
        set( gcf, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5] );
        hold on;
        
        wwINDS = (  wav_time >= (ww-1)*MAX_PLOT_SEC ) & ( wav_time < ww*MAX_PLOT_SEC );
        
        ts = wav_time( wwINDS );
        sound = wav_sound( wwINDS );
        peaks = cleanPeaks( wwINDS );
        
        plot( ts(1:nDS:end), sound(1:nDS:end), 'b-' );        
        plot( ts(1:nDS:end), peaks(1:nDS:end), 'k-' );
        
        for kk = curKeyID:length( cleanPeakKeyNames )
            if pTimes(kk) > ts(end)-KeyInfo.Toffset
                break;
            end
            xs = KeyInfo.Toffset+[pTimes(kk) rTimes(kk)];
            ys = [min(wav_sound)-0.5*std(wav_sound) min(wav_sound)-0.5*std(wav_sound)];
            
            figure(200+ww);
            plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
            text( mean(xs), mean(ys), KeyInfo.keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
        end
        curKeyID = kk;
        
 end
 
% ========================================== Compute MFCC features
peak_starts = cleanPeakWAVLocs;
peak_stops  = cleanPeakWAVLocs+MFCC_FRAME_WIDTH+MFCC_FRAME_SHIFT*(MFCC_NUM_FRAMES-1);

keepINDS = peak_stops < length(wav_sound);
peak_starts = peak_starts( keepINDS );
peak_stops  = peak_stops( keepINDS );
Ytrue = cleanPeakKeyNames( keepINDS )';

X = zeros( length( peak_starts ), MFCC_NUM_FRAMES*MFCC_NUM_COEFS  );
for gg = 1:length( peak_starts )
    
    mfcc = melfcc( wav_sound( peak_starts(gg):peak_stops(gg) ), sampleFreq, ...
        'maxfreq', MAX_FREQ, ...
        'numcep', MFCC_NUM_COEFS, ...
        'wintime', MFCC_FRAME_WIDTH_SEC, ...
        'hoptime', MFCC_FRAME_SHIFT_SEC ...
        );
    
    mfcc = mfcc(:,1:MFCC_NUM_FRAMES);
    X( gg, : ) = mfcc(:);
end
