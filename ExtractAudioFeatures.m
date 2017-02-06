%Tstart = 9.057;
close all;
clear all;

GetGroundTruthKeyTimeInfo();

cleanPeakTimes = [];
cleanKeyNames = {};

truePeakTimes = pTimes;

sampleFreq = 44100;
Tstart = 3.68;
Tstop  = 554;
T_disp_window = Tstop-Tstart;
%T_disp_window = 20;

POWER_THR = 0.02;%0.012;
TIME_WINDOW = 0.200;  % 150 ms

MIN_FREQ = 4000;
MAX_FREQ = 12000;

W = 0.010*sampleFreq;  % window length is 0.0025 seconds
N = pow2( nextpow2( W ) );  % Transform length
halfW = floor(W/2);

MFCC_NUM_FRAMES = 16;

% A. Kelly says "filterbank of 32, a window time of 10ms, window shift of 2.5ms and the first 16 coefficients were taken
MFCC_FRAME_SHIFT_SEC = 0.0025;
MFCC_FRAME_SHIFT = round( MFCC_FRAME_SHIFT_SEC*sampleFreq );

MFCC_FRAME_WIDTH_SEC = 0.010;
MFCC_FRAME_WIDTH = round( MFCC_FRAME_WIDTH_SEC*sampleFreq );

MFCC_NUM_COEFS = 16;
MFCC_NUM_FILTERS = 32;
fracLow  = 0;
fracHigh = MAX_FREQ/sampleFreq;

% ========================================= Load .WAV sound data

% 44100 Hz ==> 44100 samples per second
QWERTYsound = wavread( '/data/liv/mhughes/KeyboardAcoustics/QWERTY_test03_headset.wav', [Tstart*sampleFreq  Tstop*sampleFreq] );
%plot( QWERTYsound );

curKeyID = 1;
for ww = 1:ceil( (Tstop-Tstart)/T_disp_window )
    wav_start = (ww-1)*T_disp_window*sampleFreq+1;
    wav_stop  = min(  length(QWERTYsound), floor( ww*T_disp_window*sampleFreq ) );
    y = QWERTYsound( wav_start:wav_stop  );
    
    xgrid = halfW+1:halfW:length(y)-halfW;
    tgrid = (ww-1)*T_disp_window  + xgrid/sampleFreq;
    
    wav_t_grid = (ww-1)*T_disp_window + (1:(T_disp_window*sampleFreq) )./sampleFreq;
    
    FreqPower = zeros( 1, length(xgrid) );
    for ii = 1:length( xgrid );
        curWindowIDs = xgrid(ii) + (-halfW:halfW);
        X = abs( fft( y( curWindowIDs ), N ) );
        
        freqs = (0:N-1)*sampleFreq/N;
        
        keepINDS = freqs < MAX_FREQ & freqs >= MIN_FREQ;
        X = X( keepINDS );
        freqs = freqs( keepINDS );
        
        FreqPower(ii) = sum( X );
        
    end
    
    FreqPower = FreqPower/max(FreqPower);
    
    %     figure(100+ww);
    %     set( gcf, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5] );
    %     clf;
    %     %FreqPower = FreqPower( tgrid >= Tstart );
    %     %tgrid = tgrid( tgrid >= Tstart )-Tstart;
    %     plot( tgrid, FreqPower );
    %     hold on;
    
    deltaPower = FreqPower - [0 FreqPower(1:end-1)];
    deltaPower( deltaPower < 0 ) = 0;
    
    
    
    peakIDs = find( deltaPower >= POWER_THR );
    pp = 1;
    gg = 0;
    goodPeaks = [];
    excludeINDS = 0==ones( 1, length( tgrid ) );
    while ( pp  <= length( peakIDs )  )
        if ~excludeINDS( peakIDs(pp) )
            gg = gg + 1;
            %  walk backwards until we reach a local minimum
            for aa = peakIDs(pp)-1:-1:peakIDs(pp)-10
                if aa <= 1
                    goodPeaks(gg) = aa+1;
                    break;
                elseif deltaPower( aa ) >= deltaPower( aa+1 )
                    goodPeaks(gg) = aa+1;
                    break;
                end
            end
            % clf; plot( deltaPower( aa-2:peakIDs(pp)+1 ) ); hold on; plot( [4 4], [0 0.5], 'k-' );
            excludeINDS = tgrid > tgrid( peakIDs(pp) )  & (tgrid <= (tgrid( peakIDs(pp) ) + TIME_WINDOW) );
        end
        pp = pp+1;
    end
    
    peakLocs = zeros( 1, length( tgrid ) );
    peakLocs( goodPeaks ) = 0.5;
    
   
    if T_disp_window < 30
        figure(200+ww);
        set( gcf, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5] );
        clf;
        
        plot( tgrid, deltaPower, 'g-' );
        hold on;
        plot( tgrid, peakLocs, 'k-' );

        for kk = curKeyID:length( keyNames )
            if pTimes(kk)-pTimes(1) > tgrid(end)
                break;
            end
            xs = [pTimes(kk)-pTimes(1) rTimes(kk)-pTimes(1)];
            ys = [0 0];
            %         figure(100+ww);
            %         plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
            %         text( mean(xs), mean(ys), keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
            %
            figure(200+ww);
            plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
            text( mean(xs), mean(ys), keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
            
        end
        
        %     figure(100+ww);
        %     xlim( [min(tgrid)-0.5 max(tgrid)] );
        %     ylim( [-0.1 1] );
        
        figure(200+ww);
        xlim( [min(tgrid)-0.5 max(tgrid)] );
        ylim( [-0.1 1] );
    end
    
    
    % ======================================  Keep only *CLEAN* detections
    %  i.e. those that align with the ground truth times well
    
    detectedPeakTimes = tgrid( peakLocs > 0 );
    cleanPeakLocs = [];
    for kk = curKeyID:length( keyNames )
        if pTimes(kk)-pTimes(1) > tgrid(end)
            break;
        end
        
        % Find best match
        distToTrue_kk = abs( pTimes(kk)-pTimes(1) - detectedPeakTimes);
        
        [bestDist, bestID] = min( distToTrue_kk );
        if bestDist < 0.050
            cleanPeakLocs(end+1) = goodPeaks( bestID );
            cleanKeyNames{end+1} = keyNames{kk};
            cleanPeakTimes(end+1) = detectedPeakTimes( bestID );
        end
        
    end
    curKeyID = kk;
    
    % =============================== Find peak locs in raw audio signal
    rawID = zeros( 1, length( cleanPeakLocs )   );
    for gg = 1:length( cleanPeakLocs )
        tID = cleanPeakLocs(gg);
        rawID(gg) = round(tID*halfW);
    end
    
    rawPeakLocs = zeros( 1, length( y ) );
    rawPeakLocs( rawID ) = max( y );
    
    %figure(100+ww);
    %hold on;
    %plot( wav_t_grid, y );
    %plot( wav_t_grid, rawPeakLocs, 'g-' );
    
    % ========================================== Compute MFCC features
    peak_starts = rawID;
    peak_stops  = rawID+MFCC_FRAME_WIDTH+MFCC_FRAME_SHIFT*(MFCC_NUM_FRAMES-1);
    
    keepINDS = peak_stops < length(y);
    
    peak_starts = peak_starts( keepINDS );
    peak_stops  = peak_stops( keepINDS );
    
    
    MFCCdata = zeros( length( peak_starts ), MFCC_NUM_FRAMES*MFCC_NUM_COEFS  );
    for gg = 1:length( peak_starts )
        
        mfcc = melfcc( y( peak_starts(gg):peak_stops(gg) ), sampleFreq, ...
            'maxfreq', MAX_FREQ, ...
            'numcep', MFCC_NUM_COEFS, ...
            'wintime', MFCC_FRAME_WIDTH_SEC, ...
            'hoptime', MFCC_FRAME_SHIFT_SEC, ...
            'preemph', 0, 'dither', 0);
        
        mfcc = mfcc(:,1:MFCC_NUM_FRAMES);
        MFCCdata( gg, : ) = mfcc(:);
    end
    
end


return;



% melcepst( s, fs, nc, n, p, inc, fLow, fHigh )
%      s	 speech signal
%      fs  sample rate in Hz (default 11025)
%      nc  number of cepstral coefficients excluding 0'th coefficient (default 12)
%      n   length of frame (default power of 2 <30 ms))
%      p   number of filters in filterbank (default floor(3*log(fs)) )
%      inc frame increment (default n/2)
%      fLow low end as fraction of fs
%      fHigh high end as fraction of fs
%mfcc = melcepst( QWERTYsound( start:stop ), sampleFreq, 'Mtaz', ...
%                MFCC_NUM_COEFS, MFCC_FRAME_WIDTH, MFCC_NUM_FILTERS, ...
%                MFCC_FRAME_SHIFT, fracLow, fracHigh );