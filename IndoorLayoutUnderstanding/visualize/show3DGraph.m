function show3DGraph(pg, x, icluster)
% imshow(x.imfile);
figid = 1001;
figure(figid); clf;

room.F = x.faces{pg.layoutidx};
room.K = x.K; room.R = x.R; room.h = pg.camheight;

drawCube(room, x.lpolys(pg.layoutidx, :), figid);

if isfield(pg, 'cubes')
    for i = 1:length(pg.cubes)
         draw3Dcube(pg.cubes{i}, figid);
    end
else
    for i = 1:length(pg.childs)
         idx = pg.childs(i);
         draw3Dcube(x.cubes{idx}, figid);
    end
end

end