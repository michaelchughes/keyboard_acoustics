DATA_DIR = fullfile( '/data/liv/mhughes/KeyboardAcoustics/data/', ['ABCscienceBetter_micMacbook'] );

%datasetName = 'QWERTY';
nTest_min = 15; 
nTrain_max = 300;
nMinTotal = 30;
doMFCC=0;
for doAutoDetectKeyEvents = [ 0]
    %for doMFCC = [ 0 1 ]
    for wSize = [ .050 .100 .150]

        FFTParams.wSize_sec = wSize;

        
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
%          if doAutoDetectKeyEvents
%             detectorName = 'auto';
%         else
%             detectorName = 'true';
%         end
%         
%         if doMFCC
%             descrName = sprintf('MFCC_v%d', MFCCParams.doVoicebox );
%         else
%             descrName = 'FFT_a';
%         end
        
        %savefilename = sprintf( '%s_descr%s_%s', datasetName, descrName, detectorName );
        %DATA = load( savefilename );
        
        loadfilename = fullfile( DATA_DIR, getPreprocString( Preproc ), 'XY.mat' );
        DATA = load( loadfilename );
        
        keyNames = unique( DATA.Y );
        Y = DATA.Y;
        X = DATA.X;
        
        Train = struct( 'objIDs', [], 'X', [], 'yTrue', [] );
        Test  = struct( 'objIDs', [], 'X', [], 'yTrue', [] );
        
        uu = 0;
        while uu < length( keyNames )
            uu = uu + 1;
            matchIDs = strmatch( keyNames{uu}, Y );
            
            if length( matchIDs ) < nMinTotal
                fprintf( '\t only %d available for %s... Skipping! \n', length( matchIDs ), keyNames{uu} );
                keyNames(uu) = [];
                uu = uu - 1;
                continue;
            end
            
            
            if length( matchIDs ) > nTrain_max + nTest_min
                nTest_uu = length(matchIDs) - nTrain_max;
            else
                nTest_uu = min( nTest_min, length(matchIDs) );                
                if nTest_uu < nTest_min
                    fprintf( '\t only %d available for %s\n', nTest_uu, keyNames{uu} );
                end
                
            end
            
            testIDs = randsample( matchIDs, nTest_uu );
            trainIDs = setdiff( matchIDs, testIDs );
            
            Train.objIDs = [Train.objIDs; trainIDs];
            Test.objIDs  = [Test.objIDs; testIDs];
            
            Train.X = [Train.X; X( trainIDs, : )];
            Test.X = [Test.X; X( testIDs, : )];
             
%             Train.Xraw = [Train.Xraw; Xraw( trainIDs, : )];
%             Test.Xraw  = [Test.Xraw; Xraw( testIDs, : )];
            
            yTrue = uu*ones( length(trainIDs), 1 );
            Train.yTrue = [Train.yTrue; yTrue];
            
            yTrue = uu*ones( length(testIDs), 1 );
            Test.yTrue = [Test.yTrue; yTrue];
        end
        
        saveSUBDIR = fullfile( DATA_DIR, getPreprocString( Preproc ) );
        save( fullfile(saveSUBDIR, 'KeyNames'), 'keyNames' );
        
        save( fullfile(saveSUBDIR, 'TrainData'), '-struct', 'Train' );
        save( fullfile(saveSUBDIR, 'TestData'), '-struct', 'Test' );
        
        %DATA.CategoryNames = keyNames;
        %DATA.Train = Train;
        %DATA.Test = Test;
        %save( savefilename, '-struct', 'DATA' );
        fprintf( '... saved Train/Test data with >=%d test examples per category to file %s\n', nTest_min, saveSUBDIR );

    end % loop over descriptor types
end

% nTest = 20;
% Train = struct( 'objIDs', [], 'X', [], 'yTrue', [] );
% Test  = struct( 'objIDs', [], 'X', [], 'yTrue', [] );
% for uu = 1:length( keyNames )
%     matchIDs = strmatch( keyNames{uu}, Y );
%     
%     testIDs = randsample( matchIDs, nTest );
%     trainIDs = setdiff( matchIDs, testIDs );
%     
%     Train.objIDs = [Train.objIDs; trainIDs];
%     Test.objIDs  = [Test.objIDs; testIDs];
%     
%     Train.X = [Train.X; X( trainIDs, : )];
%     Test.X = [Test.X; X( testIDs, : )];
% 
%     yTrue = uu*ones( length(trainIDs), 1 );
%     Train.yTrue = [Train.yTrue; yTrue];
%     
%     yTrue = uu*ones( length(testIDs), 1 ); 
%     Test.yTrue = [Test.yTrue; yTrue];
%     
% end
