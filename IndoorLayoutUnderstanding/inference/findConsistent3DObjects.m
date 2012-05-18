function pg = findConsistent3DObjects(pg, x)
if(isempty(pg.childs))
    pg.camheight = 1.5;
    return;
end

bottoms = zeros(1, length(pg.childs));
for i = 1:length(pg.childs)
    cube = x.cubes{pg.childs(i)};
    bottoms(i) = -min(cube(2, :));
end

[ camh, alpha ] = optimizeObjectScales( bottoms );

pg.camheight = camh;

for i = 1:length(pg.childs)
    pg.cubes{i} = alpha(i) .* x.cubes{pg.childs(i)};
end

end