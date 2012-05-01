function show2DGraph(pg, x, icluster)

imshow(x.imfile);
for i = 1:length(pg.childs)
    idx = pg.childs(i);
    rectangle('position', bbox2rect(x.dets(idx, 4:7)), 'linewidth', 2, 'edgecolor', 'm');
end

end