function [peakTimes, deltaPower, tgrid] = detectPeaksInWAV( wavfilename, doPlot, MIN_FREQ, MAX_FREQ, POWER_THR, FRAME_WIDTH_SEC, PEAK_WIDTH_SEC)
% INPUT
%   
% LEGEND
%   wav_sound :   Nx1 col vector of
%   peakTimes :   Px1 vector where peakTimes(pp) 
%                     gives the time (in seconds) of each detected peak
%   peakLocsInWAV : Px1 vector where pp-th entry
%                      gives the index (1...N) of each peak in wav_sound
%                    peakLocsInWAV(pp) = peakTimes(pp)*sampleFreq

% [wav_sound, sampleFreq] = wavread( wavfilename );
% if size( wav_sound,1 ) > 1
%     wav_sound = wav_sound(:,1);
% end
% wav_time =  ( 1:length(wav_sound) ) / sampleFreq;


FFTparams.wSize_sec = 0.050;
FFTparams.minFreq_Hz = 400;
FFTparams.maxFreq_Hz = 12000;

Tstart = 19;
Tstop  = 50;

Wtime = (FFTparams.wSize_sec)/2;
tgrid = (Tstart+1):Wtime:Tstop;

[X, freqs] = calcFFTdescriptor( wavfilename, tgrid, FFTparams );
X = X';
imagesc(tgrid,freqs, X);


%[B,freqs,ts] = spectrogram( wav_sound, WINDOW, OVERLAP, NFFT, sampleFreq );
% calculate amplitude 50dB down from maximum
%bmin=max(max(abs(B)))/300;
%B = max(abs(B),bmin)/bmin;
%P = 20*log10( abs(B) );
%keepINDS = MIN_FREQ <= freqs & freqs <= MAX_FREQ;
%freqs = freqs(keepINDS);
%P = P( :, keepINDS );



% -------------------------------------------------------- DEPRECATED
% curKeyID = 1;
% [wav_sound, sampleFreq] = wavread( wavfilename );
% 
% W = sampleFreq*FRAME_WIDTH_SEC;
% N = pow2( nextpow2( W ) );  % Transform length
% halfW = round(W/2);
% 
% xgrid = halfW+1:halfW:length(wav_sound)-halfW;
% tgrid = xgrid/sampleFreq;
% 
% FreqPower = zeros( 1, length(xgrid) );
% for ii = 1:length( xgrid );
%     curWindowIDs = xgrid(ii) + (-halfW:halfW);
%     X = abs( fft( wav_sound( curWindowIDs ), N ) );
%     
%     freqs = (0:N-1)*sampleFreq/N;
%     keepINDS = freqs < MAX_FREQ & freqs >= MIN_FREQ;
%     
%     X = X( keepINDS );
%     freqs = freqs( keepINDS );
%     
%     FreqPower(ii) = sum( X );
%     
% end
% 
% FreqPower = FreqPower/max(FreqPower);
% 
% deltaPower = FreqPower - [0 FreqPower(1:end-1)];
% deltaPower( deltaPower < 0 ) = 0;
% 
% peakIDs = find( deltaPower >= POWER_THR );
% pp = 1;
% gg = 0;
% goodPeaks = [];
% excludeINDS = 0==ones( 1, length( tgrid ) );
% while ( pp  <= length( peakIDs )  )
%     if ~excludeINDS( peakIDs(pp) )
%         gg = gg + 1;
%         %  walk backwards until we reach a local minimum
%         for aa = peakIDs(pp)-1:-1:peakIDs(pp)-10
%             if aa <= 1
%                 goodPeaks(gg) = aa+1;
%                 break;
%             elseif deltaPower( aa ) >= deltaPower( aa+1 )
%                 goodPeaks(gg) = aa+1;
%                 break;
%             end
%         end
%         % clf; plot( deltaPower( aa-2:peakIDs(pp)+1 ) ); hold on; plot( [4 4], [0 0.5], 'k-' );
%         excludeINDS = tgrid > tgrid( peakIDs(pp) )  & (tgrid <= (tgrid( peakIDs(pp) ) + PEAK_WIDTH_SEC) );
%     end
%     pp = pp+1;
% end
% 
% peakTimes = tgrid( goodPeaks );


% ================================================== Plot detected peaks
% 
% if doPlot
%     
%     peakLocs = zeros( 1, length( tgrid ) );
%     peakLocs( goodPeaks ) = 0.5;
%     
%     MAX_PLOT_SEC = 20;
%     
%     Tstart = 1;
%     Tstop  = length(wav_sound)/sampleFreq;
%     
%     if ~isfield( KeyInfo, 'Toffset' )
%         KeyInfo = alignWAVandGroundTruth( peakTimes, KeyInfo, PEAK_WIDTH_SEC );
%     end
%     
%     peakTimes = peakTimes - KeyInfo.Toffset;
%     peakTimes = peakTimes( peakTimes >= 0 );
%     
%     tgrid = tgrid - KeyInfo.Toffset;
%     keepINDS = tgrid >= 0;
%     tgrid = tgrid( keepINDS );
%     peakLocs  = peakLocs( keepINDS );
%     deltaPower = deltaPower( keepINDS );
%     
%     pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
%     rTimes = KeyInfo.rTimes - KeyInfo.pTimes(1);
%     
%     KeyInfo.peakLocsInWAV = round(peakTimes*sampleFreq);
%     
%     %  ----------------------------------------------- Actually plot
%     for ww = 1:min(10,ceil(  (Tstop-Tstart)/MAX_PLOT_SEC ) )
%         
%         figure(200+ww);
%         set( gcf, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5] );
%         
%         wwINDS = (  tgrid >= (ww-1)*MAX_PLOT_SEC ) & ( tgrid < ww*MAX_PLOT_SEC );
%         
%         plot( tgrid(wwINDS), deltaPower(wwINDS), 'g-' );
%         hold on;
%         plot( tgrid(wwINDS), peakLocs(wwINDS), 'k-' );
%         
%         for kk = curKeyID:length( KeyInfo.keyNames )
%             if pTimes(kk) > tgrid( find( wwINDS, 1, 'last') )
%                 break;
%             end
%             xs = [pTimes(kk) rTimes(kk)];
%             ys = [0 0];
%             
%             figure(200+ww);
%             plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
%             text( mean(xs), mean(ys), KeyInfo.keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
%         end
%         curKeyID = kk;
%         
%         xlim( [min( tgrid(wwINDS) )-0.5 max(tgrid(wwINDS))+0.5] );
%         ylim( [-0.1 1] );
%         
%     end
%     
% end % doPlot