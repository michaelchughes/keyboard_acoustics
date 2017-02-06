function [X, freqs, keepIDs] = calcFFTdescriptor( wavfilename, keyTimePoints, FFTparams )
% INPUT
%   wavfilename : 
%   keyPoints   : Px1 col vector
%                     p-th entry in (1...N) gives location in wav audio
%                       of the p-th keypoint
%   FFTparams   :  struct with fields
%                     minFreq_Hz
%                     maxFreq_Hz
%                     wSize_sec
%                     nBins
                    

[wav_sound, sampleFreq] = wavread( wavfilename );
plot( wav_sound );

W = round( FFTparams.wSize_sec*sampleFreq);

keyPoints = ceil( eps+keyTimePoints*sampleFreq );
% Filter out key press events recorded by software logger
%    but not captured in the audio recording
keepINDS = keyPoints+W-1 <= length( wav_sound );
keyPoints = keyPoints( keepINDS );
P = length( keyPoints );
keepIDs = find( keepINDS );

X = zeros( P,  ceil(W/2)  );

[~, freqs] = positiveFFT( wav_sound(1:W), sampleFreq );
keepINDSfreqs = FFTparams.minFreq_Hz <= freqs & freqs <= FFTparams.maxFreq_Hz;
freqs = freqs(keepINDSfreqs);
for pp = 1:P
    
    cur_wav_sound = wav_sound( keyPoints(pp):keyPoints(pp)+W-1  );
    
    X(pp,:) = positiveFFT( cur_wav_sound, sampleFreq );
    
    %X_fft = abs( fft( cur_wav_sound, K ) );
    %X_fft = X_fft( keepINDS );
    
    %X_binned = zeros( 1, FFTparams.nBins );
    %for bb = 1:FFTparams.nBins
    %    X_binned(bb) = sum( X_fft( binINDS(bb,:) ) );
    %end
    
    %X(pp,:) = X_binned;
end

X = X( :, keepINDSfreqs );




%W = sampleFreq*FFTparams.wSize_sec;

% freqs = (0:K-1)*sampleFreq/K;
% keepINDS = FFTparams.minFreq_Hz <= freqs & freqs <=  FFTparams.maxFreq_Hz ;
% freqs = freqs( keepINDS );

% freqs_bounds = linspace( FFTparams.minFreq_Hz, FFTparams.maxFreq_Hz, FFTparams.nBins+1 );
% for bb = 1:FFTparams.nBins
%     binINDS(bb,:) = freqs_bounds(bb) <= freqs & freqs < freqs_bounds(bb+1);
% end