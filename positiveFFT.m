function [X,freq]=positiveFFT(x,Fs)
N=length(x); %get the number of points

%this part of the code generates that frequency axis
if mod(N,2)==0
    k=-N/2:N/2-1; % N even
    midpt = N/2 + 1;
else
    k=-(N-1)/2:(N-1)/2; % N odd
    midpt = ceil(N/2);
end
T=N/Fs;
freq=k/T;  %the frequency axis

%takes the fft of the signal, and adjusts the amplitude accordingly
X=fft(x)/N; % normalize the data
X=fftshift(X); %shifts the fft data so that it is centered

X = abs(  X(midpt:end) );
freq = freq(midpt:end);