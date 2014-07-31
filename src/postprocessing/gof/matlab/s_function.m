
function S = s_function(p1,p2)

S = 10 * exp( -( ( (p1-p2)/min([p1 p2]) )^2 ) );
