function [] = plotQWERTYwav( testID, startTime, stopTime )

fname = sprintf( '/data/liv/mhughes/KeyboardAcoustics/QWERTY_test%02d_headset.wav', testID );

[wav_sound, FREQ_SAMP] = wavread( fname );

wav_time = ( 1:length( wav_sound ) )/FREQ_SAMP;

keepINDS = wav_time >= startTime & wav_time < stopTime;

plot( wav_time(keepINDS), wav_sound( keepINDS ) );

end

% START TIMES
%   3 :  3.68
%   4 :  5.21
%   5 :  8.36