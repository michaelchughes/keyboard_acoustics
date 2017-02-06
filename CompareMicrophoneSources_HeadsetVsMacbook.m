ToffA = 3.69;  
ToffB = 10.77; 

[wavA, FsA] = wavread( '/data/liv/mhughes/KeyboardAcoustics/QWERTY_test03_headset' );
[wavB, FsB] = wavread( '/data/liv/mhughes/KeyboardAcoustics/QWERTY_test03_macbook' );

if size( wavB, 2 ) > 1
    wavB = wavB(:,1);
end

assert( FsA == FsB, 'bad sample freqs' );
Fs = FsA;

ts = 1:10:10*Fs;

subplot(2,1,1);  plot( ts/Fs, wavA(ts+ToffA*Fs) ); title( 'headset' );
subplot(2,1,2); plot( ts/Fs, wavB(ts+ToffB*Fs) ); title( 'macbook' );