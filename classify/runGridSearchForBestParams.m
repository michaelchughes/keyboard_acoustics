function [Best, Perf] = runGridSearchForBestParams(  DATA_DIR,  Preproc, Classifier, ValidOpts, Eval )
% Determines the best Classifier and Preproc params 
%    by grid searching over param values stored in the ValidOpts structure
% Stores the best parameter settings in a .mat file in 
%  DATA_DIR/<dataName>/<dataPath>/bestParamSearch_<preprocStr>_<classifierStr>_<validType>.mat
%    MAT file fields:
%      .Best.Preproc   = best codebook object
%      .Best.Classifier = best classifier object
%      .ValidOpts       = settings used for validation
% INPUT
% OUTPUT
%   Best  struct
%       .Preproc.(someParam)   = best value found in grid search
%       .Classifier.(someParam) = best value found in grid search
%   Perf  struct array
%       contains Performance data for all param combinations analyzed
%       Perf(pgc) is the Perf object for combination pgc,
%                run updateParamGridInd pgc times to get param settings

Classifier = insertDefaultClassifierParams( Classifier );

if isfield(  ValidOpts, 'Preproc'  )
    preprocPNames = ValidOpts.Preproc.Names;
    preprocPValues = ValidOpts.Preproc.ParamGrids;
else
    preprocPNames = {};
end
if isstruct(  ValidOpts.ClassifierParamGrids  )
    classPNames = fields( ValidOpts.ClassifierParamGrids );
else
    classPNames = {};
end


L1 = length( preprocPNames );
LL = length( preprocPNames)+length(classPNames);
MAX_IND = zeros( 1, LL );
pgind   = zeros( 1, LL );

% MAX_IND
%   [  codebook_paramGrid_indices  classifier_paramGrid_indices    ]
for ll = LL:-1:1
    if ll <= L1
        pName = preprocPNames{ ll };
        MAX_IND(ll) = length( preprocPValues{ll}  );
    else
        pName = classPNames{ ll - L1 };
        MAX_IND(ll) = length( ValidOpts.ClassifierParamGrids.(pName)  );
    end
end

pgc = 0;
while ( all( pgind <= MAX_IND-1 ) )
   
    for pNum = 1:length( preprocPNames )
        pName = preprocPNames{ pNum };
        pVal  = preprocPValues{ pNum }( 1+pgind( pNum ) );   
        
        dotLocs = strfind( pName, '.' );
        if isempty( dotLocs )
            Preproc.( pName )   =   pVal;  
        else
            %fmt_string = repmat( '.(%s)',1, length(dotLocs) );
            CMD_string = 'Preproc.';
            bs = [0 dotLocs length(pName)];
            for dd = 1:length( bs )-1
                CMD_string = [CMD_string pName( bs(dd)+1:bs(dd+1)  ) ];
            end
            CMD_string = sprintf( '%s = %f;', CMD_string, pVal );
            eval( CMD_string );
        end
        
        fprintNameValPair( pName, pVal );
    end
    
    if ~isempty( preprocPNames )
        fprintf('  |  ');
    end
    
    for pNum = 1:length( classPNames )  
        pName = classPNames{ pNum };
        pVal  = ValidOpts.ClassifierParamGrids.(pName)( 1+pgind( L1+pNum ) );
        Classifier.( pName ) = pVal;
        
        fprintNameValPair( pName, pVal );
    end
    
    curPerf = runClassifier_Validation( DATA_DIR,  Preproc, Classifier, ValidOpts, Eval  );    
    curPerf.pgind = pgind;
    
    pgc = pgc + 1;
    Perf( pgc ) = curPerf;
        
    fprintf( ' | %.2f \n', curPerf.(Eval.PerfField) );

    % Can abort early if clear evidence exists we're going downhill
    if length( preprocPNames ) < 1 && length( Perf ) > 4
        curPerf = Perf( pgc ).( Eval.PerfField );
        pastPerf = median( [ Perf( pgc-2:pgc-1).(Eval.PerfField) ] );
        if  curPerf + 0.01 < pastPerf
            break;
        end
    end
    
    pgind = updateParamGridIndices( pgind, MAX_IND );
    
end  % search loop over param grid indices

% ------------------------------------ Determine best Param Settings
switch Eval.PreferredRank
    case 'max'
        [~, bestpgc] = max( [Perf(:).(Eval.PerfField) ] );
    case 'min'
        [~, bestpgc] = min( [Perf(:).(Eval.PerfField) ] );
end
best_pgind = Perf( bestpgc ).pgind;

Best = struct();

Best.Preproc = Preproc;
for pNum = 1:length( preprocPNames )
    pName = preprocPNames{ pNum };
    pVal = preprocPValues{ pNum }( 1+best_pgind( pNum ) );   %ValidOpts.PreprocParamGrids.(pName)( 1+best_pgind( pNum ) );
    %Best.Preproc.( pName )   = pVal;
    dotLocs = strfind( pName, '.' );
    if isempty( dotLocs )
        Best.Preproc.( pName )   =   pVal;
    else
        %fmt_string = repmat( '.(%s)',1, length(dotLocs) );
        CMD_string = 'Best.Preproc.';
        bs = [0 dotLocs length(pName)];
        for dd = 1:length( bs )-1
            CMD_string = [CMD_string pName( bs(dd)+1:bs(dd+1)  ) ];
        end
        CMD_string = sprintf( '%s = %f;', CMD_string, pVal );
        eval( CMD_string );
    end
    fprintNameValPair( ['Best.Preproc.' pName], pVal ); 
    fprintf('\n');
end

Best.Classifier = Classifier;
for pNum = 1:length( classPNames )
    pName = classPNames{ pNum };
    pVal =  ValidOpts.ClassifierParamGrids.(pName)( 1+best_pgind( L1+pNum ) );
    Best.Classifier.( pName ) = pVal;
    fprintNameValPair( ['Best.Classifier.' pName], pVal ); 
    fprintf('\n');
end

% saveDir = fullfile( DATA_DIR, 'Results', 'Valid', dataPath);
% [warn, msg] = mkdir( saveDir );
% savefile =  sprintf(  'bestParamSearch_%s_%s_%s.mat',   getPreprocString(Preproc), Classifier.Name, ValidOpts.type );
% savefilepath = fullfile( saveDir, savefile );
% save( savefilepath, 'Best', 'Perf', 'ValidOpts');
% disp( [' .......................   saved ParamSearch info to MAT file  ' savefilepath] );

end % main function


function [] = fprintNameValPair( name, val )

if ischar(val)
    fprintf( '%s=%s', name, val );
elseif int32(val) == val && val <= 1000
    fprintf( '%s=% 9.0f', name, val );
elseif val >= .001 && val <= 1000
    fprintf( '%s=   % 3.3f', name, val );
else
    fprintf( '%s=% 1.2e', name, val );
end

end %  function