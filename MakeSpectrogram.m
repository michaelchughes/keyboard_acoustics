% get a portion of signal
minFreq_Hz = 0;
wSize_sec = 0.020;
SAMP_FREQ = 44100;
FFTparams.minFreq_Hz = 0;
FFTparams.maxFreq_Hz = 12000;
FFTparams.wSize_sec  = wSize_sec;

wavfilename = '/data/liv/mhughes/KeyboardAcoustics/ABCscience_test01_macbook.wav';

[y, sampleFreq]=wavread( wavfilename, [1 5e5] );
wav_time = ( 1:length(y) ) / sampleFreq;

if size( y, 2) > 1
    y = y(:,1);
end

NFFT = 1024;
WINDOW = round( SAMP_FREQ * wSize_sec );
OVERLAP = ceil( WINDOW/2 );

% specgram(   y,nfft,fs,window,overlap  )
%[B,f,t]=specgram(y, NFFT, SAMP_FREQ, WINDOW, OVERLAP);
[B,freqs,ts] = spectrogram( y, WINDOW, OVERLAP, NFFT, SAMP_FREQ );

% calculate amplitude 50dB down from maximum
bmin=max(max(abs(B)))/300;

B = max(abs(B),bmin)/bmin;

%P = 20*log10(max(abs(B),bmin)/bmin);
P = 20*log10( abs(B) );
% plot top 50dB as image
figure(101);
imagesc(ts,freqs, P);
% label plot
axis xy;
ylim( [0 FFTparams.maxFreq_Hz] );
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

peakTimes = 0:wSize_sec:wav_time(end);
[X, freqs] = calcFFTdescriptor( wavfilename, peakTimes, FFTparams );
X = X';

% figure(102);
% imagesc( peakTimes, freqs, X );
% axis xy;

bmin=max(max(abs(X)))/300;
X = 20*log10( max(abs(X),bmin)/bmin );
figure( 103);
imagesc( peakTimes, freqs, X );
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colorbar;

% keepINDS = freqs > minFreq_Hz;
% RawPeaks = sum( B(keepINDS,:), 1 );
% figure(201);
% plot( ts, RawPeaks );