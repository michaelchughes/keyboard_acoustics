DatasetName = 'ENRON_micMacbook';
Preproc.Descriptor = struct('Name', 'FFT');
Preproc.Descriptor.Params.wSize_sec = 0.050;

Classifier = struct( 'Name', 'svm', 'kernel', 'linear', 'cost', 1000 );
Eval.Name = 'accuracy';

ValidOpts = struct(); % do not erase or comment out!

%ValidOpts.type = 'none';
ValidOpts.type = 'none';
%ValidOpts.Preproc.Names{1} = 'Descriptor.Params.wSize_sec';
%ValidOpts.Preproc.ParamGrids{1} = [0.100 0.125 0.150];

Results = ClassifierDriver( DatasetName, Preproc, Classifier, ValidOpts, Eval);

% addpath( genpath( '~/git/liv-video/code/matlab/' ) );
% Classifier = struct();
% %Classifier.Name = 'knn';
% %Classifier.K = 5;
% %Classifier.distMetric = 'euclidean';
%  Classifier.Name = 'svm';
%  Classifier.kernel = 'linear';
%  Classifier.cost = 100;
% 
% DATA = load( 'QWERTY_descrFFT_a_true' );
% %DATA = load( 'ABCscience_descrFFT_a_true' );
% 
% GT.doExclusive = 1;
% GT.nCategories = max( DATA.Train.yTrue ); 
% 
% [yHat, classRank] = runClassifier(  DATA.Train.X, DATA.Train.yTrue, DATA.Test.X, GT, Classifier, 0 );
% 
% Eval.Name = 'accuracy';
% AccPerf = evalClassifierResults( DATA.Test.yTrue, yHat, classRank, GT, Eval );
% 
% Eval.Name = 'average precision';
% APPerf = evalClassifierResults( DATA.Test.yTrue, yHat, classRank, GT, Eval );
