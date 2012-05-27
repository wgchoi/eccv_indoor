function pg = findConsistent3DObjects(pg, x, iclusters)
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

[ camh, alpha ] = optimizeObjectScales( bottoms );

pg.camheight = camh;
pg.objscale = alpha; 
% for i = 1:length(objidx)
%     pg.objscale(i) = alpha(i) .* x.cubes{objidx(i)};
% end

end