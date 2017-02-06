function [Results] = ClassifierDriver( DatasetName, Preproc, Classifier, ValidOpts, Eval)
% USAGE:
%  ClassifierDriver( dataName, Preproc, Classifier, ValidOpts, Eval )
addpath( genpath( '~/git/liv-video/code/matlab/classify/') );
addpath( genpath( '.') );
% ----------------------------------------------------------- data params
DATA_DIR = fullfile( '/data/liv/mhughes/KeyboardAcoustics/data/', DatasetName );

% -------------------------------------------- Validation params
if ~exist( 'ValidOpts', 'var' ) || isempty( ValidOpts )
    ValidOpts.type = 'cross';
end
if ~isfield( ValidOpts, 'nFold' );
    ValidOpts.nFold = 5;
end
% -------------------------------------  Options for param grid search
ValidOpts.foldSummaryFcn = @mean;
if ~isfield( ValidOpts, 'PreprocParamGrids' )
    ValidOpts.PreprocParamGrids = struct();
end
if ~isfield( ValidOpts, 'ClassifierParamGrids' )
    ValidOpts.ClassifierParamGrids = struct();
    switch lower( Classifier.Name )
        case 'knn'
            ValidOpts.ClassifierParamGrids.K = [1 5 10 20];
        case {'svm', 'libsvm'}
            ValidOpts.ClassifierParamGrids.cost = logspace(0,5,6);
    end
end

% ------------------------------------- EVAL params
if ~exist( 'Eval', 'var') || ( isstruct(Eval) && ~isfield( Eval, 'Name' ) )    
    Eval.Name = 'Accuracy';
elseif ischar( Eval )
    tmpName = Eval;
    clear Eval; Eval = struct();
    Eval.Name = tmpName;
end
Eval.PreferredRank = 'max';
Eval.PerfField = 'Mean';
if ~isfield( Eval, 'splitName' )
    Eval.splitName = 'test';
end

% ---------------------------------------------  Default Classifier params
if exist( 'Classifier', 'var' ) && ~isempty( Classifier )
    if ischar( Classifier )
        Classifier.Name = Classifier;
    end    
else
    Classifier = struct();
    Classifier.Name = 'svm';
    Classifier.kernel = 'linear';
    Classifier.cost    = 1;
end


% ====================================== PRINT SUMMARY
fprintf( 'Dataset Name:  %s\n', DatasetName );
%fprintf( '%s validation\n', ValidOpts.type );
fprintf( 'Classifier:  %s %s \n', Classifier.Name, getClassifierString( Classifier ) );
fprintf( 'Evaluation Metric: %s \n', Eval.Name );

% ====================================== RUN w/ PARAM SEARCH ON VALID DATA
if isfield( ValidOpts, 'type' ) && ~strcmp( ValidOpts.type, 'none' )
    fprintf( 'Running search for best Classifier and Preproc params \n' );
    nFoldStr = '';
    if strcmp( ValidOpts.type, 'cross' );
        nFoldStr = sprintf( 'with %d folds', ValidOpts.nFold );
    end
    fprintf( '   validation type: %s %s\n', ValidOpts.type , nFoldStr);

    [Best, VPerf] = runGridSearchForBestParams(  DATA_DIR, Preproc, Classifier, ValidOpts, Eval );
else
    Best.Preproc    = Preproc;
    Best.Classifier = Classifier;
end

% ====================================== RUN w/ BEST PARAMS ON TEST DATA
Train = load( fullfile( DATA_DIR, getPreprocString( Best.Preproc ), 'TrainData.mat' ) );
if strcmp( Eval.splitName, 'test' )
    Test = load( fullfile( DATA_DIR, getPreprocString( Best.Preproc ), 'TestData.mat' ) );
end
GT.doExclusive = 1;
GT.nCategories = max( Train.yTrue ); 

fprintf( 'Running classifier on held out %s set\n', Eval.splitName  );
[yHat, classRank] = runClassifier(  Train.X, Train.yTrue, Test.X, GT, Best.Classifier, 0);
Perf = evalClassifierResults( Test.yTrue, yHat, classRank, GT, Eval );

fprintf( '\t%s = %.3f\n', Perf.MetricName, Perf.Mean );

% -----------------------------------------------  Save
Results.DatasetName = DatasetName;
Results.Perf = Perf;
Results.Eval = Eval;
Results.Classifier = Classifier;
Results.ValidOpts = ValidOpts;
Results.BestParams = Best;
if exist( 'VPerf', 'var' )
    Results.ValidationPerf = VPerf;
end
saveDir = fullfile( DATA_DIR, getPreprocString( Best.Preproc ), 'ClassifierResults/' );
[warn, msg] = mkdir( saveDir );
savefile =  sprintf(  'results_%s_%s.mat',   getClassifierString( Classifier ), ValidOpts.type );
savefilepath = fullfile( saveDir, savefile );
save( savefilepath, '-struct', 'Results');

printablepath = fullfile( getPreprocString( Best.Preproc ), 'ClassifierResults/', savefile );
disp( [' .......................   saved Results to MAT file  ' printablepath] );

