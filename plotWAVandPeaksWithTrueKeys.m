function [] = plotWAVandPeaksWithTrueKeys( wavfilename, KeyInfo, deltaPower, tgrid, peakTimes, POWER_THR )
PEAK_WIDTH_SEC = 0.1;
MAX_PLOT_SEC = 5;
nDS = 1; % downsample factor
[wav_sound, sampleFreq] = wavread( wavfilename );

if size( wav_sound, 2 ) > 1
    wav_sound = wav_sound(:,1);
end

wav_time = ( 1:length(wav_sound) ) / sampleFreq;

wav_sound = wav_sound ./max( abs(wav_sound) );
yOFFSET = 1.25 * prctile( abs(wav_sound), 99.999 );

if ~isfield( KeyInfo, 'Toffset' )
    KeyInfo = alignWAVandGroundTruth( peakTimes, KeyInfo, PEAK_WIDTH_SEC );
end

if peakTimes(1) ~= 0
    peakTimes = peakTimes - KeyInfo.Toffset;
    peakTimes = peakTimes( peakTimes >= 0 );
end
% 
% tgrid = tgrid ;
% keepINDS = tgrid >= 0;
% tgrid = tgrid( keepINDS );
% deltaPower = deltaPower( keepINDS );

peaks = zeros( size( tgrid ) );
for pp = 1:length( peakTimes )
    [~,bestID] = min( abs( tgrid - peakTimes(pp) ) );
    peaks( bestID ) = 2*POWER_THR;
end

peakWAVLocs = ceil( KeyInfo.Toffset*sampleFreq ) + ceil( (eps+peakTimes) * sampleFreq );

Tstart = 1;
Tstop = 10*MAX_PLOT_SEC;
pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
rTimes = KeyInfo.rTimes - KeyInfo.pTimes(1);
cleanPeaks = zeros( size( wav_sound) );
cleanPeaks( peakWAVLocs ) = max( wav_sound );
curKeyID = 1;
 for ww = 1:min(10,ceil(  (Tstop-Tstart)/MAX_PLOT_SEC ) )
        
        figure(200+ww);
        set( gcf, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5] );
        hold on;
               
        % ---------- plot real wav sound
        wwINDS = (  tgrid >= (ww-1)*MAX_PLOT_SEC ) & ( tgrid < ww*MAX_PLOT_SEC );
        
        plot( tgrid(wwINDS), yOFFSET + deltaPower(wwINDS), 'g-' );
        hold on;
        plot( tgrid(wwINDS), yOFFSET + peaks(wwINDS), 'k-' );
        plot( tgrid(wwINDS), yOFFSET + POWER_THR*ones( 1, sum(wwINDS) ), 'r--' );
        
        % ---------- plot real wav sound
        wwINDS = (  wav_time >= (ww-1)*MAX_PLOT_SEC ) & ( wav_time < ww*MAX_PLOT_SEC );
        
        ts = wav_time( wwINDS );
        sound = wav_sound( wwINDS );
        peaks = cleanPeaks( wwINDS );
        
        plot( ts(1:nDS:end), sound(1:nDS:end), 'b-' );        
        plot( ts(1:nDS:end), peaks(1:nDS:end), 'k-' );
        
        for kk = curKeyID:length( KeyInfo.keyNames )
            if pTimes(kk) > ts(end)-KeyInfo.Toffset
                break;
            end
            xs = KeyInfo.Toffset+[pTimes(kk) rTimes(kk)];
            ys = [0.9*yOFFSET 0.9*yOFFSET];
            
            figure(200+ww);
            plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
            text( mean(xs), mean(ys), KeyInfo.keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
        end
        curKeyID = kk;
        
        if curKeyID == 1
            close gcf;
        end
 end