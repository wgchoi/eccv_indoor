function show3DGraph(pg, x, icluster)
% imshow(x.imfile);
figid = 1001;
figure(figid); clf;

room.F = x.faces{pg.layoutidx};
room.K = x.K; room.R = x.R; room.h = pg.camheight;

drawCube(room, x.lpolys(pg.layoutidx, :), figid);

for i = 1:length(pg.childs)
     idx = pg.childs(i);
     if isfield(pg, 'objscale')
        draw3Dcube(pg.objscale(i) * x.cubes{idx}, figid);
     else
        draw3Dcube(x.cubes{idx}, figid);
     end
end

end