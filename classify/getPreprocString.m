function [ppStr] = getPreprocString( Preproc )
% Preproc.Detector  has .Name, .Params
% Preproc.Descriptor has .Name, .Params

Preproc = fillDefaultFields( Preproc );

P = Preproc.Detector.Params;
paramString = '';
switch Preproc.Detector.Name
    case 'Auto'
        paramString = '';
    case 'True'
        paramString = '';
end
if ~isempty( paramString )
    paramString = ['_' paramString];
end
detectStr = sprintf( 'detect%s%s', Preproc.Detector.Name, paramString );


P = Preproc.Descriptor.Params;
switch Preproc.Descriptor.Name
    case 'FFT'
        paramString = sprintf( 'wSize%03d-minFreqHz%d-maxFreqHz%d', P.wSize_sec*1000, P.minFreq_Hz, P.maxFreq_Hz );
    case 'MFCC'
        paramString = sprintf( 'wSize%03d-minFreqHz%d-maxFreqHz%d', P.wSize_sec*1000, P.minFreq_Hz, P.maxFreq_Hz );
end
descrStr = sprintf( 'descr%s_%s', Preproc.Descriptor.Name,  paramString);

ppStr = fullfile( detectStr, descrStr );