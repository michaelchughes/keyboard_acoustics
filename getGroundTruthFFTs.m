function [X, Ytrue] = getGroundTruthMFCCs( wavfilename, detectedPeakTimes, KeyInfo, MAX_FREQ, MFCC_FRAME_WIDTH_SEC, MFCC_FRAME_SHIFT_SEC, MFCC_NUM_COEFS, MFCC_NUM_FRAMES)
PROXIMITY_THR_SEC = 0.05;

MAX_PLOT_SEC = 1;

[wav_sound, sampleFreq] = wavread( wavfilename );
wav_time = ( 1:length(wav_sound) ) / sampleFreq;

detectedPeakLocs =  ceil( (eps+detectedPeakTimes) * sampleFreq );

MFCC_FRAME_SHIFT = round( MFCC_FRAME_SHIFT_SEC*sampleFreq );
MFCC_FRAME_WIDTH = round( MFCC_FRAME_WIDTH_SEC*sampleFreq );
MAX_TIME_SEC = length(wav_sound)/sampleFreq;

pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
keyNames = KeyInfo.keyNames;

cleanPeakTimes = [];
cleanKeyNames = {};
cleanLocs = [];
for kk = 1:length( keyNames )
    if pTimes(kk) > MAX_TIME_SEC
        break;
    end
    
    % Find best match
    distToTrue_kk = abs( pTimes(kk) - detectedPeakTimes);
    
    [bestDist, bestID] = min( distToTrue_kk );
    
    if distToTrue_kk( bestID ) > 0.05
        fprintf( 'Terrible Match found!\n' );
    end
    
    if bestDist < PROXIMITY_THR_SEC
        cleanLocs(end+1) = detectedPeakLocs( bestID );
        cleanKeyNames{end+1} = keyNames{kk};
        cleanPeakTimes(end+1) = detectedPeakTimes( bestID );
    end
    
end

Tstart = 1;
Tstop = 5*MAX_PLOT_SEC;
pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
rTimes = KeyInfo.rTimes - KeyInfo.pTimes(1);
cleanPeaks = zeros( size( wav_sound) );
cleanPeaks( cleanPeakWAVLocs ) = 1;
curKeyID = 1;
 for ww = 1:min(4,ceil(  (Tstop-Tstart)/MAX_PLOT_SEC ) )
        
        figure(200+ww);
        set( gcf, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5] );
        hold on;
        
        wwINDS = (  wav_time >= (ww-1)*MAX_PLOT_SEC ) & ( wav_time < ww*MAX_PLOT_SEC );
        
        plot( wav_time( wwINDS ), wav_sound( wwINDS ), 'b-' );        
        plot( wav_time(wwINDS), cleanPeaks(wwINDS), 'k-' );
        
        for kk = curKeyID:length( cleanKeyNames )
            if pTimes(kk) > tgrid( find( wwINDS, 1, 'last') )
                break;
            end
            xs = [pTimes(kk) rTimes(kk)];
            ys = [min(wav_sound)-0.4 min(wav_sound)-0.4];
            
            figure(200+ww);
            plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
            text( mean(xs), mean(ys), KeyInfo.keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
        end
        curKeyID = kk;
        
 end


% ========================================== Compute FFT features
peak_starts = cleanLocs;
peak_stops  = cleanLocs+MFCC_FRAME_WIDTH+MFCC_FRAME_SHIFT*(MFCC_NUM_FRAMES-1);

keepINDS = peak_stops < length(wav_sound);

peak_starts = peak_starts( keepINDS );
peak_stops  = peak_stops( keepINDS );
Ytrue = cleanKeyNames( keepINDS )';

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
