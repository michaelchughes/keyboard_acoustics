
sampleFreq = 1000;
freqA = 5;
freqB = 10;

ts = linspace(0, 2*pi, round(2*pi*sampleFreq) );
close all
xs = cos( freqA*2*pi*ts ); % + cos( freqB*2*pi*ts);
K = 4096;
freqs = (0:K-1)*sampleFreq/K;


Y = abs( fft( xs,K) );

subplot(2,1,1);
plot( ts, xs );
subplot(2,1,2);
plot( freqs, Y );