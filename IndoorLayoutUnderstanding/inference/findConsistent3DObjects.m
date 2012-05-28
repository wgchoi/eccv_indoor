function pg = findConsistent3DObjects(pg, x, iclusters, quickcomp)

if nargin < 4
    quickcomp = false;
end

if(isempty(pg.childs))
    pg.camheight = 1.5;
    pg.objscale = [];
    return;
end
objidx = getObjIndices(pg, iclusters);
bottoms = zeros(1, length(objidx));
for i = 1:length(objidx)
    cube = x.cubes{objidx(i)};
    bottoms(i) = -min(cube(2, :));
end

if(quickcomp)
    camh = mean(bottoms(bottoms > 0));
    if(isnan(camh))
        camh = mean(bottoms(bottoms < 0));
        alpha = camh ./ bottoms;
    else
        alpha = camh ./ bottoms;
    end
else
    [ camh, alpha ] = optimizeObjectScales( bottoms );
end

pg.camheight = camh;
pg.objscale = alpha; 
% for i = 1:length(objidx)
%     pg.objscale(i) = alpha(i) .* x.cubes{objidx(i)};
% end

end