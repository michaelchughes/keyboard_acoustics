function [k] = multinomial_single_draw( ps )

cs = cumsum(ps);
k = find( cs > rand*cs(end), 1, 'first' );