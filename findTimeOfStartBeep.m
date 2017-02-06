function [beepTime] = findTimeOfStartBeep(wavfilename)

BEEP_FREQ = 440;

minFreq_Hz = 0;
wSize_sec = 0.0025;
SAMP_FREQ = 44100;
FFTparams.minFreq_Hz = 0;
FFTparams.maxFreq_Hz = 12000;
FFTparams.wSize_sec  = wSize_sec;

%wavfilename = '/home/mhughes/Dropbox/KeyboardAcoustics/RAND100_test01_macbook.wav';

[wav_sound, sampleFreq]=wavread( wavfilename, [1 10e5] );
wav_time = ( 1:length(wav_sound) ) / sampleFreq;


peakTimes = 0:wSize_sec:wav_time(end);
[X, freqs] = calcFFTdescriptor( wavfilename, peakTimes, FFTparams );
X = X';
bmin=max(max(abs(X)))/300;
X = 20*log10( max(abs(X),bmin)/bmin );
figure( 103);
imagesc( peakTimes, freqs, X );
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

[~,bestID] = min( abs( freqs - BEEP_FREQ ) );
powerAtBeep = X(bestID,:  );
figure( 203); hold on;
plot( peakTimes, powerAtBeep );
deltaAtBeep = [0 diff( powerAtBeep )];
plot( peakTimes, deltaAtBeep, 'g' );
[~, maxID] = max( deltaAtBeep );

MIN_PEAK_THR = 15; %3*std( powerAtBeep(1:maxID) ) + median( powerAtBeep(1:maxID) );
if powerAtBeep( maxID+1 ) >= MIN_PEAK_THR
    beepTime = peakTimes( maxID );
    plot( [beepTime beepTime], [0 deltaAtBeep(maxID)], 'k--' );
    fprintf( 'Beep Time: %.3f sec from start of wav audio\n', beepTime );
else
    beepTime = [];
    fprintf( 'warning: no beep detected');
end

