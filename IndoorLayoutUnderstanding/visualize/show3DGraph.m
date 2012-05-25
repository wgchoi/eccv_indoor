function show3DGraph(pg, x, iclusters, figid)
% imshow(x.imfile);
if nargin < 4
    figid = 1001;
end
figure(figid); clf;

room.F = x.faces{pg.layoutidx};
room.K = x.K; room.R = x.R; room.h = pg.camheight;

drawCube(room, x.lpolys(pg.layoutidx, :), figid);

col = 'rgbykmcrgbykmcrgbykmcrgbykmc';

for i = 1:length(pg.childs)
     idx = pg.childs(i);
     oid = iclusters(idx).ittype;
     
     if isfield(pg, 'objscale')
        draw3Dcube(pg.objscale(i) * x.cubes{idx}, figid, col(oid));
     else
        draw3Dcube(x.cubes{idx}, figid, col(oid));
     end
end

end
