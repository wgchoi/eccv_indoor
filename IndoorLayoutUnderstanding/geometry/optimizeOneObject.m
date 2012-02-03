function [fval, loc] = optimizeOneObject(camh, K, R, obj, model, mid)
%%% find the best fitting object hypothesis given a camera height
iloc = getInitialGuess(obj, model, mid, K, R, camh);
%%% avoid unnecessary computation.
[pbbox] = loc2bbox(iloc, obj.pose, K, R, model, mid);
if(boxoverlap(pbbox, obj.bbs) < 0.1)
    loc = nan(3, 1);
    fval = 1e10;
    return;
end
xz = iloc([1 3]);
%%% optimize over x-z dimension given camera height
[xz, fval] = fminsearch(@(x)objFitnessCost(x, camh, K, R, obj, model, mid), xz);
loc = [xz(1); -(camh - model.height(mid) / 2); xz(2)];

end
