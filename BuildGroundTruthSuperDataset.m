close all;
clear variables;

addpath( '~/code/rastamat/' )


SUFFIX = 'macbook';
DATA_DIR = '/data/liv/mhughes/KeyboardAcoustics/';

MIN_FREQ = 0;
MAX_FREQ = 12000;
POWER_THR = 0.01;
FRAME_WIDTH_SEC = 0.01;
PEAK_WIDTH_SEC = 0.2;

% We only want to keep detections that
%   are within PROXIMITY_THR of a ground truth detection
PROXIMITY_THR_SEC = 0.025;

% -------------------------------------------- FFT params
FFTParams.wSize_sec = 0.100;
FFTParams.minFreq_Hz =    0;
FFTParams.maxFreq_Hz = 12000;

% -------------------------------------------- MFCC params
MFCCParams.doVoicebox = 0;
MFCCParams.wSize_sec = .024;
MFCCParams.wStep_sec = .012;
MFCCParams.nCoefs = 16;
MFCCParams.nFilters = 32;
MFCCParams.minFreq_Hz = 0;
MFCCParams.maxFreq_Hz = 12000;
MFCCParams.nFrames = 4;

datasetName = 'ENRON';
fNames = {'ENRON_test01'};
SAVE_DIR = fullfile( '/data/liv/mhughes/KeyboardAcoustics/data/', ['ENRON_micMacbook'] );

%datasetName = 'ABCscience';
%fNames = {'ABCscience_test01'};
%fNames = {'ABCscience_test01', 'ABCscience_test03'};
%SAVE_DIR = fullfile( '/data/liv/mhughes/KeyboardAcoustics/data/', ['ABCscience_micMacbook'] );

%datasetName = 'QWERTY';
%fNames = {'QWERTY_test04', 'QWERTY_test05'};
%fNames = {'QWERTY_test02', 'QWERTY_test03', 'QWERTY_test04', 'QWERTY_test05'};
%SAVE_DIR = fullfile( '/data/liv/mhughes/KeyboardAcoustics/data/', ['QWERTY_micMacbook'] );

doMFCC = 0;

for doAutoDetectKeyEvents = [ 1 ]
    for wSize = [ .050 .100 .150]
        FFTParams.wSize_sec = wSize;
        
        X = [];
        Y = [];
        for ff = 1:length( fNames )
            fprintf( 'Extracting data for %s\n', fNames{ff} );
            wavfilename = fullfile( DATA_DIR, [fNames{ff} '_' SUFFIX] );
            
            if doAutoDetectKeyEvents
                KeyInfo{ff} = GetGroundTruthKeyTimeInfo( fNames{ff} );

                [peakTimes,  deltaPower, tgrid] = detectPeaksInWAV( wavfilename, 0, MIN_FREQ, MAX_FREQ, POWER_THR, FRAME_WIDTH_SEC, PEAK_WIDTH_SEC );
                
                KeyInfo{ff} = alignWAVandGroundTruth( wavfilename, peakTimes, KeyInfo{ff}, PEAK_WIDTH_SEC );                
                peakTimes = peakTimes - KeyInfo{ff}.Toffset;
                peakTimes = peakTimes( peakTimes >= 0 );
                
                [cleanPeakTimes, cleanPeakKeyNames] = filterPeaksToMatchGroundTruth( KeyInfo{ff}, peakTimes, PROXIMITY_THR_SEC );
            else
                if ~exist( 'KeyInfo','var') || ff > length( KeyInfo )
                   KeyInfo{ff} = GetGroundTruthKeyTimeInfo( fNames{ff} );
                   beepTime = findTimeOfStartBeep( wavfilename );
                   KeyInfo{ff} = manualAlignWAVWithTrueKeys( wavfilename, KeyInfo{ff}, beepTime );
                   
                   %if isempty( beepTime )
                   %    KeyInfo{ff} = manualAlignWAVWithTrueKeys( wavfilename, KeyInfo{ff} );
                   %else
                   %    KeyInfo{ff}.Toffset = beepTime;
                   %end
                end
                
                if strcmp( KeyInfo{ff}.keyNames{1} , 'BEEP' )
                    cleanPeakTimes = KeyInfo{ff}.pTimes(2:end);
                    cleanPeakKeyNames = KeyInfo{ff}.keyNames(2:end);
                else
                    cleanPeakTimes = KeyInfo{ff}.pTimes - KeyInfo{ff}.pTimes(1);
                    cleanPeakKeyNames = KeyInfo{ff}.keyNames;
                end
            end
            
            cleanPeakTimes = cleanPeakTimes + KeyInfo{ff}.Toffset;
            %cleanPeakTimes = [cleanPeakTimes  7.5:wSize_sec:12];
            %plotWAVPeaksWithTrueKeys( wavfilename, KeyInfo{ff}, cleanPeakTimes );
            
            % ======================================= COMPUTE DESCRIPTORS OF PEAKS
            if doMFCC
                Xff = calcMFCCdescriptor( wavfilename, cleanPeakTimes, MFCCParams );        
                featInfo = [];
                keepIDs = [];
            else
                [Xff, freqs, keepIDs] = calcFFTdescriptor( wavfilename, cleanPeakTimes, FFTParams );

                bmin=max(max(abs(Xff)))/300;
                Xff = 20*log10( max(abs(Xff),bmin)/bmin );
                featInfo = struct( 'freqs', freqs, 'Params', FFTParams );
            end
            
            
            
            X = [X; Xff];
            Y = [Y; cleanPeakKeyNames(keepIDs)'];
        end
        
        %if ~doMFCC
        %   bmin=max(max(abs(X)))/300;
        %   X = 20*log10( max(abs(X),bmin)/bmin ); 
        %end
        
        keyNames = unique(Y);
       
        if doAutoDetectKeyEvents
            Preproc.Detector.Name = 'Auto';
        else
            Preproc.Detector.Name = 'True';
        end
        
        if doMFCC
            Preproc.Descriptor.Name = 'MFCC';
            Preproc.Descriptor.Params = MFCCParams;
        else
            Preproc.Descriptor.Name = 'FFT';
            Preproc.Descriptor.Params = FFTParams;
        end
        
        saveSUBDIR = fullfile( SAVE_DIR, getPreprocString( Preproc ) );
        if ~exist( saveSUBDIR, 'dir' )
            [~,~] = mkdir( saveSUBDIR );
        end
        %savefilename = fullfile( saveSUBDIR,  'XY.mat' );
        %save( savefilename, 'X', 'Y', 'featInfo' );
        %fprintf( '... saved XY.mat to %s\n' , saveSUBDIR );
        
        %savefilename = fullfile( saveSUBDIR, 'KeyInfo.mat' );
        %save( savefilename, 'KeyInfo');
        
    end
end

% ------------------------------------ DEPRECATED
%[Xff, Yff] = getGroundTruthMFCCs( fullfile( DATA_DIR, wavName ), peakTimes, KeyInfo, MAX_FREQ, MFCC_FRAME_WIDTH_SEC, MFCC_FRAME_SHIFT_SEC, MFCC_NUM_COEFS, MFCC_NUM_FRAMES);
    