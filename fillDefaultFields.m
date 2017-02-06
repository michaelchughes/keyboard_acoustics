function Preproc = fillDefaultFields( Preproc )

if ~isfield( Preproc, 'Detector' );
    Preproc.Detector = struct( 'Name', 'True');
end
if ~isfield( Preproc.Detector, 'Params' )
        Preproc.Detector.Params = [];
end
if ~isfield( Preproc.Descriptor, 'Params' )
        Preproc.Descriptor.Params = [];
end

if ~isfield( Preproc.Descriptor.Params, 'minFreq_Hz' )
    Preproc.Descriptor.Params.minFreq_Hz = 0;
end

if ~isfield( Preproc.Descriptor.Params, 'maxFreq_Hz' )
    Preproc.Descriptor.Params.maxFreq_Hz = 12000;
end

switch Preproc.Descriptor.Name
    case 'FFT'
        if ~isfield( Preproc.Descriptor.Params, 'wSize_sec' )
            Preproc.Descriptor.Params.wSize_sec = 0.100;
        end
    case 'MFCC'
        if ~isfield( Preproc.Descriptor.Params, 'wSize_sec' )
            Preproc.Descriptor.Params.wSize_sec = 0.050;
        end
end