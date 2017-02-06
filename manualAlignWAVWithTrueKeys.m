function [KeyInfo] = manualAlignWAVWithTrueKeys( wavfilename, KeyInfo, beepTime )

nDS = 1; % downsample factor
[wav_sound, sampleFreq] = wavread( wavfilename, [1 60*44100] );
if size( wav_sound,1 ) > 1
    wav_sound = wav_sound(:,1);
end
% Keep only the first minute!
wav_sound = wav_sound( 1:round(60*sampleFreq) );
wav_time = ( 1:length(wav_sound) ) / sampleFreq;


if strcmp( KeyInfo.keyNames{1} , 'BEEP' )
    durations =  KeyInfo.rTimes(2:end) - KeyInfo.pTimes(2:end);
    startID = 1+find( durations > 0.05, 1, 'first' );
    
    pTimes = KeyInfo.pTimes(startID:end) - KeyInfo.pTimes(1);
    rTimes = KeyInfo.rTimes(startID:end) - KeyInfo.pTimes(1);
    keyNames = KeyInfo.keyNames(startID:end);
else
    pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
    rTimes = KeyInfo.rTimes - KeyInfo.pTimes(1);
    keyNames = KeyInfo.keyNames;
end

% -------------------------------- interactive segmentation
Tbuf = 0.1;
nKeys = 5;
isDone = 0;
figure;

Ymin = min(wav_sound)-0.5*std(wav_sound);
Ymax = max( wav_sound );
Z = 0;
if exist( 'beepTime', 'var' ) && ~isempty(beepTime)
    Z = pTimes(1);
    pTimes = pTimes - Z;
    rTimes = rTimes - Z;
    Toff = beepTime + Z + Tbuf;
else
    beepTime = 0;
    Toff = Tbuf;
end

while ~isDone
    clf;
    hold on;
    
    for kk = 1:nKeys
        
        xs = [pTimes(kk) rTimes(kk)];
        ys = [Ymin Ymin];
        
        plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
        text( mean(xs), mean(ys), keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
    end
    
    maxID = round( (rTimes(nKeys)+Tbuf) *sampleFreq );
    offsetID = round( (Toff-Tbuf)*sampleFreq );
    plot( wav_time(1:nDS:maxID), wav_sound( offsetID + (1:nDS:maxID) ) );
    
    plot( [0 0], [Ymin Ymax], 'k-' );
    
    xlim( [-Tbuf rTimes(nKeys)+Tbuf] );
    ylim( [Ymin-0.1 Ymax] );
    
    [newToff, yClick] = ginput( 1 );
    
    if yClick > Ymax
        isDone = 1;
    else
        Toff = Toff + newToff;
        Toff = max( Toff, Tbuf );
    end
end
Toff = Toff - (Z + Tbuf);

KeyInfo.Toffset = Toff;
fprintf( 'Toffset = %.3f\n', Toff );
end
%
% peakWAVLocs = ceil( KeyInfo.Toffset*sampleFreq ) + ceil( (eps+peakTimes) * sampleFreq );
%
% Tstart = 1;
% Tstop = 10*MAX_PLOT_SEC;
% cleanPeaks = zeros( size( wav_sound) );
% cleanPeaks( peakWAVLocs ) = 1;
% curKeyID = 1;
% Ymin = min(wav_sound)-0.01;
%  for ww = 1:min(10,ceil(  (Tstop-Tstart)/MAX_PLOT_SEC ) )
%
%         figure(200+ww);
%         set( gcf, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5] );
%         hold on;
%
%         wwINDS = (  wav_time >= (ww-1)*MAX_PLOT_SEC ) & ( wav_time < ww*MAX_PLOT_SEC );
%
%         ts = wav_time( wwINDS );
%         sound = wav_sound( wwINDS );
%         peaks = cleanPeaks( wwINDS );
%
%         for kk = curKeyID:length( KeyInfo.keyNames )
%             if pTimes(kk) > ts(end)-KeyInfo.Toffset
%                 break;
%             end
%             xs = KeyInfo.Toffset+[pTimes(kk) rTimes(kk)];
%             ys = [Ymin Ymin];
%
%             figure(200+ww);
%             plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
%             text( mean(xs), mean(ys), KeyInfo.keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
%         end
%         curKeyID = kk;
%
%         if curKeyID == 1
%             close gcf;
%         end
%
%         plot( ts(1:nDS:end), sound(1:nDS:end), 'b-' );
%         plot( ts(1:nDS:end), peaks(1:nDS:end), 'k-' );
%
%         grid on;
%  end
