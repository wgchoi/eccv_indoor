function [ camh, alpha ] = optimizeObjectScales( bottoms )

ret = fminsearch(@(x) objfunc(x, bottoms), [ones(1, length(bottoms)), mean(bottoms)]);
camh = ret(end);
alpha = ret(1:end-1);

end

function fval = objfunc(x, d)

k = x(1:end-1) .* d;
fval = 10 * sum( ( k - x(end) ) .^ 2);
fval = fval + sum( log( x(1:end-1) ) .^ 2);

end