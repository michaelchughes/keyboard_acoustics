function cStr = getClassifierString( Classifier )
% Obtain string repr of Classifier object
cStr = '';

switch lower( Classifier.Name )
    case {'svm', 'libsvm'}
        cStr = [ '_' Classifier.kernel 'Kernel'];    
end