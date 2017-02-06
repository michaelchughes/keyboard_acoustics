function KeyInfo = GetGroundTruthKeyTimeInfo( fname )

plogfile = sprintf( '/data/liv/mhughes/KeyboardAcoustics/%s.plog', fname );
rlogfile = sprintf( '/data/liv/mhughes/KeyboardAcoustics/%s.rlog', fname );
fid = fopen( plogfile );
KeyPress = textscan( fid, '%f%s', 'delimiter', '\t' );
fclose(fid);
fid = fopen( rlogfile );
KeyRelease = textscan( fid, '%f%s', 'delimiter', '\t' );
fclose(fid);

doDEBUG = 0;

releaseINDS = 1==ones( 1, length( KeyRelease{1} ) );
keyNames= {};
pTimes = [];
rTimes = [];
pp = 1;
rr = 1;
while ( pp <= length(KeyPress{1}) && rr <= length( KeyRelease{1})   )
    
    while ~releaseINDS(rr)
        rr = rr + 1;
    end
    
    curKeyPress = KeyPress{2}{pp};
    curKeyRel = KeyRelease{2}{rr};
    if strcmp( curKeyPress, curKeyRel )
        rMatch = rr;
        releaseINDS(rMatch) = 0;
        rr = rr + 1;
    else
        
        
        % Search ahead
        rMatch = [];
        for r = rr+1:length( KeyRelease{1} )
            
            if releaseINDS(r) && strcmp( curKeyPress, KeyRelease{2}{r} )
                rMatch = r;
                break;
            end
        end
        
        if doDEBUG
            fprintf( 'MISMATCH key detections: %d,%s and %d,%s\n', pp, curKeyPress, rr, curKeyRel );
            
            for r = rr-10:rr+10
                if pp == r
                    fprintf( '    ---> %4d %16s %16s %d\n', r, KeyPress{2}{r}, KeyRelease{2}{r}, releaseINDS(r) );
                else
                    fprintf( '\t %4d %16s %16s %d\n', r, KeyPress{2}{r}, KeyRelease{2}{r}, releaseINDS(r) );
                end
            end
            fprintf( '... matched at release location %d, %s \n', rMatch, KeyRelease{2}{rMatch} );
            %fprintf( '                               %.2f %.2f\n', KeyPress{1}(pp), KeyRelease{1}(rMatch) );
        end
        
        if KeyPress{1}(pp) > KeyRelease{1}(rMatch)
            fprintf( 'Release before press? \n' );
            fprintf( '  %.2f    %.2f \n', KeyPress{1}(pp), KeyRelease{1}(rMatch) );
        end
        
        % Remove that entry
        releaseINDS(rMatch) = 0;
            
    end
    
    if ~isempty( rMatch )
        keyNames{end+1} = curKeyPress(2:end-1);
        pTimes = [ pTimes KeyPress{1}(pp) ];
        rTimes = [ rTimes KeyRelease{1}(rMatch) ];
    else
        fprintf( 'No release detected for key: %s\n', curKeyPress );
    end
    
    pp = pp + 1;
end

KeyInfo = struct();
KeyInfo.keyNames = keyNames;
KeyInfo.pTimes = pTimes;
KeyInfo.rTimes = rTimes;