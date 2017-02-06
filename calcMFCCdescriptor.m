function [X] = calcMFCCdescriptor( wavfilename, keyTimePoints, Params )
% INPUT
%   wavfilename :
%   keyTimePoints   : Px1 col vector
%                     p-th entry in (1...N) gives time in raw wav audio
%                       of the p-th keypoint
%   Params   :  struct with fields
%                     minFreq_Hz
%                     maxFreq_Hz
%                     winSize_sec
%                     nFrames
[wav_sound, sampleFreq] = wavread( wavfilename );

keyPoints = ceil( eps+keyTimePoints*sampleFreq );
P = length( keyPoints );

Toffset = Params.wSize_sec + Params.nFrames*Params.wStep_sec;
windowLEN = ceil( Toffset*sampleFreq );

X = zeros( P,  Params.nFrames*Params.nCoefs  );
for pp = 1:P
    cur_wav_sound = wav_sound( keyPoints(pp):keyPoints(pp)+windowLEN  );
   
    if Params.doVoicebox
        mfcc = melcepst( cur_wav_sound, sampleFreq,  'Mtaz', ...            
                   Params.nCoefs, ...
                   ceil( Params.wSize_sec*sampleFreq ), ...
                   Params.nFilters, ...
                   ceil( Params.wStep_sec*sampleFreq ), ...
                   Params.minFreq_Hz/sampleFreq, ...
                   Params.maxFreq_Hz/sampleFreq );
        mfcc = mfcc(1:Params.nFrames,:)';        
           
    else        
        mfcc = melfcc( cur_wav_sound, sampleFreq, ...
            'maxfreq', Params.maxFreq_Hz, ...
            'numcep', Params.nCoefs, ...
            'wintime', Params.wSize_sec, ...
            'hoptime', Params.wStep_sec ...
            );
        mfcc = mfcc(:,1:Params.nFrames);        
    end
    
    X(pp,:) = mfcc(:);
end