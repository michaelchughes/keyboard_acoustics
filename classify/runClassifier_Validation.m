function Perf = runClassifier_Validation( DATA_DIR, Preproc, Classifier, ValidOpts, Eval )
% Trains classifier on specified data, then measures performance on
%    held-out validation data (as specified in ValidOpts)
% Performance measure specified by the Eval input struct.


myRandStream = RandStream('mt19937ar','Seed',0);

switch lower( ValidOpts.type )
    case 'cross'
        assert( isfield( ValidOpts, 'nFold' ), 'ERROR: Number of folds not specified' );
        
        Train = load( fullfile( DATA_DIR, getPreprocString(Preproc), 'TrainData.mat' ) );
        Xcv = Train.X;
        Ycv = Train.yTrue;
                
        GT.doExclusive = 1;
        GT.nCategories = max( Ycv );
        
        assert( size( Xcv, 1) == size( Ycv, 1), 'ERROR: X and y need same dimensions' );
        nCV = size( Xcv, 1);
        
        permIDs = randperm(myRandStream, nCV );
        Xcv = Xcv( permIDs, : );
        Ycv = Ycv( permIDs, : );
        
        nFold = min( ValidOpts.nFold, nCV-1  );
        if nFold ~= ValidOpts.nFold
            fprintf('Alert: requested nFolds exceeds number of available data items.');
        end

        matchIDs = 0==zeros( GT.nCategories, nCV );
        for cc = 1:GT.nCategories
           matchIDs(cc,:) = (Ycv == cc ); 
           assert( sum( matchIDs(cc,:) ) >= nFold, ['Error: Not enough examples of category ' num2str(cc)]);
        end
        
        %fprintf( 'running %d', nFold );
        for fold = 1:nFold
            
            validIDs = [];
            trainIDs = [];
            for cc = 1:GT.nCategories
                catIDs = find( matchIDs(cc,:) );
                nCat =  length( catIDs );
                nHeldout = floor(nCat/nFold );

                start = nHeldout*(fold-1);
                if fold == nFold
                    stop  = length(catIDs);
                else
                    stop  = start+nHeldout;
                end
                
                validIDs = [validIDs  catIDs(start+1:stop)];
                trainIDs = [trainIDs  setdiff( catIDs, validIDs )];                
            end
            
            nV = length(validIDs);
            nT = length(trainIDs);
            %assert( nV + nT == nCV, 'Uh oh, missing some data item' );

            Xtrain = Xcv( trainIDs, :);
            Xvalid = Xcv( validIDs, :);
            
            Ytrain  = Ycv(  trainIDs, :);
            Yvalid  = Ycv(  validIDs, :);
            
            [yHat, classRank] = runClassifier( Xtrain, Ytrain, Xvalid, GT, Classifier, 0 );
            curPerf = evalClassifierResults( Yvalid, yHat, classRank, GT, Eval );
            FPerf(fold) = curPerf;
            %fprintf( 'fold %d: %.2f\n', fold, curPerf.Mean );
        end
        
        % Summarize Performance across folds
        %  by applying given function as operator
        %     to each of the fields in the FPerf struct array
        Perf = summarizePerfAcrossFolds( FPerf, ValidOpts.foldSummaryFcn );
        
    case 'predef'
        error( 'ToDo' );
end % switch over Validation type


end % main function




function Perf = summarizePerfAcrossFolds( Fperf, summaryFcn )
    Perf = struct();
    fNames = fieldnames( Fperf);
    for f = 1:length( fNames )
        fName = fNames{f};
        if ~isnumeric( Fperf(1).( fName ) )
            % just pass along fields that aren't numerical
            %   e.g. CategoryNames
            Perf.( fName ) = Fperf(1).( fName );
            continue;
        end
        [R,C] = size( Fperf(1).(fName) );
        X  = [  Fperf(:).(fName)   ];
        X  = reshape( X, numel(X)/C , C );
        Perf.(fName) = summaryFcn( X, 1 );
    end
end % function

