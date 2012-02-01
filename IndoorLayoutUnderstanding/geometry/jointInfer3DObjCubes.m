function [camh, cubes] = jointInfer3DObjCubes(K, R, objs, models)
%%% get max overlapping hypotehsis
hs = 0.1:0.2:3.0;
for i = 1:length(hs)
    ret(i) = allObjsCost(hs(i), K, R, objs, models);
end
[dummy, idx] = min(ret);
camh = hs(idx);
% fine tuning
[camh, fval] = fminsearch(@(x) allObjsCost(x, K, R, objs, models), camh);
% cube = get3DObjectCube(loc, model.width(1), model.height(1), model.depth(1), angle);
%%% keyboard
if(nargout >= 2)
    % temp!!!1
    mid = 1;
    
    cubes = cell(length(objs), 1);
    for i = 1:length(objs)
        if(length(models) < i)
            continue;
        end
        if(models(i).grounded == 0)
            continue;
        end
        for j = 1:length(objs{i})
            obj = objs{i}(j);
            
            [fval, loc] = optimizeOneObject(camh, K, R, obj, models(i), mid);
            angle = get3DAngle(K, R, obj.pose, loc(2));
            
            cubes{i}{j} = get3DObjectCube(loc, models(i).width(mid), models(i).height(mid), models(i).depth(mid), angle);
        end
    end
end
end

%%% compute 
function ret = allObjsCost(camh, K, R, objs, models)
ret = 0;
for i = 1:length(objs)
    if(length(models) < i)
        continue;
    end
    if(models(i).grounded == 0)
        continue;
    end
    
    for j = 1:length(objs{i})
        obj = objs{i}(j);
        if(1)
            [fval, loc] = optimizeOneObject(camh, K, R, obj, models(i), 1);
        else
            %%% find the best fitting object hypothesis given a camera height
            iloc = getInitialGuess(obj, models(i), 1, K, R, camh);
            %%% avoid unnecessary computation.
            [pbbox] = loc2bbox(iloc, obj.pose, K, R, models(i), 1);
            if(boxoverlap(pbbox, obj.bbs) < 0.1)
                ret = ret + 1e10;
                continue;
            end
            xz = iloc([1 3]);
            %%% optimize over x-z dimension given camera height
            [dummy, fval] = fminsearch(@(x)objFitnessCost(x, camh, K, R, obj, models(i), 1), xz);
        end
        ret = ret + fval;
    end
end

end

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
