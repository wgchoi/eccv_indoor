function loss = lossall(anno, x, pg)
if isfield(x, 'lloss')
    loss = x.lloss(pg.layoutidx);
else
    loss = layout_loss(anno.gtPolyg, x.lpolys(pg.layoutidx, :));
end
% assuming direct instantiation
idx = pg.childs;
%
loss = loss + object_loss(anno.obj_annos, x.dets(idx, [1 4:7 3]));
end