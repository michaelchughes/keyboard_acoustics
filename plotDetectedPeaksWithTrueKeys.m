function [] = plotDetectedPeaksWithTrueKeys( KeyInfo, deltaPower, tgrid, peakTimes, POWER_THR )

MAX_PLOT_SEC = 10;

Tstart = 1;
Tstop  = round( max(peakTimes)+0.5 );

if ~isfield( KeyInfo, 'Toffset' )
    KeyInfo = alignWAVandGroundTruth( peakTimes, KeyInfo, PEAK_WIDTH_SEC );
end

if peakTimes(1) ~= 0
    peakTimes = peakTimes - KeyInfo.Toffset;
    peakTimes = peakTimes( peakTimes >= 0 );
end

tgrid = tgrid - KeyInfo.Toffset;
keepINDS = tgrid >= 0;
tgrid = tgrid( keepINDS );
deltaPower = deltaPower( keepINDS );

peaks = zeros( size( tgrid ) );
for pp = 1:length( peakTimes )
    [~,bestID] = min( abs( tgrid - peakTimes(pp) ) );
    peaks( bestID ) = 0.05;
end

pTimes = KeyInfo.pTimes - KeyInfo.pTimes(1);
rTimes = KeyInfo.rTimes - KeyInfo.pTimes(1);

curKeyID = 1;
%  ----------------------------------------------- Actually plot
for ww = 1:min(5,ceil(  (Tstop-Tstart)/MAX_PLOT_SEC ) )
    
    figure(200+ww);
    set( gcf, 'Units', 'Normalized', 'Position', [0 0.5 0.5 0.5] );
    
    wwINDS = (  tgrid >= (ww-1)*MAX_PLOT_SEC ) & ( tgrid < ww*MAX_PLOT_SEC );
    
    plot( tgrid(wwINDS), deltaPower(wwINDS), 'g-' );
    hold on;
    plot( tgrid(wwINDS), peaks(wwINDS), 'k-' );
    plot( tgrid(wwINDS), POWER_THR*ones( 1, sum(wwINDS) ), 'r--' );
    
    for kk = curKeyID:length( KeyInfo.keyNames )
        if pTimes(kk) > tgrid( find( wwINDS, 1, 'last') )
            break;
        end
        xs = [pTimes(kk) rTimes(kk)];
        ys = [0 0];
        
        figure(200+ww);
        plot( xs, ys, 'r.-', 'MarkerSize', 15, 'LineWidth', 3 );
        text( mean(xs), mean(ys), KeyInfo.keyNames{kk}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );
    end
    curKeyID = kk;
    
    xlim( [min( tgrid(wwINDS) )-0.5 max(tgrid(wwINDS))+0.5] );
    ylim( [-0.01 0.05] );
    
end