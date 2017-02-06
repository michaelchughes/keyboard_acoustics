function [] = plotWAVPeaksWithTrueKeys( wavfilename, KeyInfo, peakTimes, startID )

if ~exist( 'startID', 'var' )
    startID = 1;
end

if strcmp( KeyInfo.keyNames{1} , 'BEEP' )
    pTimes = KeyInfo.pTimes(2:end) - KeyInfo.pTimes(1);
    rTimes = KeyInfo.rTimes(2:end) - KeyInfo.pTimes(1);
    keyNames = KeyInfo.keyNames(2:end);
else
    pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
    rTimes = KeyInfo.rTimes - KeyInfo.pTimes(1);
    keyNames = KeyInfo.keyNames;
end

% Keep only the first minute!
sampleFreq = 44100;
startIDX =  floor( (peakTimes(startID) )*sampleFreq );
stopIDX = ceil(  ( 1*60 +peakTimes(startID) )*sampleFreq );

MAX_PLOT_SEC = 5;
nDS = 1; % downsample factor
[wav_sound, sampleFreq] = wavread( wavfilename, [startIDX stopIDX] );
%[wav_sound, sampleFreq] = wavread( wavfilename, [1, 1e7] );
if size( wav_sound,1 ) > 1
    wav_sound = wav_sound(:,1);
end

%wav_sound = wav_sound( 1:round( 3*60*sampleFreq ) );
%wav_time = ( 1:length(wav_sound) ) / sampleFreq;
wav_time =  peakTimes(startID) + ( 1:length(wav_sound) ) / sampleFreq;



%peakWAVLocs = ceil( KeyInfo.Toffset*sampleFreq ) + ceil( (eps+peakTimes) * sampleFreq );
peakWAVLocs = ceil( eps+(peakTimes-peakTimes(startID)) * sampleFreq );
peakWAVLocs = peakWAVLocs( peakWAVLocs > 0 );
%ystart = round(pTimes(1)*sampleFreq );
%ystop  = round(pTimes(100)*sampleFreq );
Ymax = prctile( wav_sound, 99.999);
Tstart =  peakTimes(startID)-0.5;
Tstop =  peakTimes(startID+20)+0.5;
cleanPeaks = zeros( size( wav_sound) );
cleanPeaks( peakWAVLocs ) = Ymax;
[~,curKeyID] = min( abs( peakTimes(startID)-KeyInfo.Toffset - pTimes  )  );
%curKeyID=1;
for ww = 1:ceil(  (Tstop-Tstart)/MAX_PLOT_SEC )
        figure;
        clf;
        set( gcf, 'Units', 'Normalized', 'Position', [0 0.9-0.1*(ww+1) 0.5 0.1] );
        hold on;
        
        wwINDS = (  wav_time >= Tstart+(ww-1)*MAX_PLOT_SEC ) & ( wav_time < Tstart+ww*MAX_PLOT_SEC );
        
        ts = wav_time( wwINDS );
        sound = wav_sound( wwINDS );
        peaks = cleanPeaks( wwINDS );
        
        Ymin = min( wav_sound( wwINDS ) )-0.01;
        
        for kk = curKeyID:length( keyNames )
            if pTimes(kk) > ts(end)-KeyInfo.Toffset
                break;
            end
            xs = KeyInfo.Toffset+[pTimes(kk) rTimes(kk)];
            ys = [Ymin Ymin];
            
            plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
            text( mean(xs), mean(ys), keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 13 );
        end
        curKeyID = kk;
        
        if curKeyID == 1
            close gcf;
        end
        
        plot( ts(1:nDS:end), sound(1:nDS:end), 'b-' );        
        plot( ts(1:nDS:end), peaks(1:nDS:end), 'k-' );
        
        grid on;
        
        ylim( [Ymin-0.1 Ymax+0.1] );
 end
 
 
% if ~isfield( KeyInfo, 'Toffset' )
%    % -------------------------------- interactive segmentation
%    Tbuf = 0.1;
%    nKeys = 5;
%    isDone = 0;
%    figure;
%    
%    Ymin = min(wav_sound)-0.5*std(wav_sound);
%    Ymax = max( wav_sound );
%    Toff = Tbuf;
%    while ~isDone       
%       clf;
%       hold on;
%             
%       for kk = 1:nKeys
% 
%             xs = [pTimes(kk) rTimes(kk)];
%             ys = [Ymin Ymin];
%             
%             plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
%             text( mean(xs), mean(ys), KeyInfo.keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
%       end 
%        
%       maxID = round( (rTimes(nKeys)+Tbuf) *sampleFreq );
%       offsetID = round( (Toff-Tbuf)*sampleFreq );
%       plot( wav_time(1:nDS:maxID), wav_sound( offsetID + (1:nDS:maxID) ) );
%       
%       plot( [0 0], [Ymin Ymax], 'k-' );
%       
%       xlim( [-Tbuf rTimes(nKeys)+Tbuf] );
%       ylim( [Ymin-0.1 Ymax] );
%       
%       [newToff, yClick] = ginput( 1 );
% 
%       if yClick > Ymax
%             isDone = 1;
%             Toff = Toff - Tbuf;
%       else
%             Toff = Toff + newToff;
%             Toff = max( Toff, Tbuf );
%       end
%    end
%    KeyInfo.Toffset = Toff;
%    fprintf( 'Toffset = %.2f\n', Toff );
% end
 