function show2DGraph(pg, x, icluster)
% imshow(x.imfile);
fig2d = 1000;
figure(fig2d); clf;

om = objmodels();

ShowGTPolyg(imread(x.imfile), x.lpolys(pg.layoutidx, :), fig2d)
for i = 1:length(pg.childs)
    idx = pg.childs(i);
    rectangle('position', bbox2rect(x.dets(idx, 4:7)), 'linewidth', 2, 'edgecolor', 'm');
    [poly, rt] = get2DCubeProjection(x.K, x.R, x.cubes{idx});
    draw2DCube(poly, rt, fig2d, om(x.dets(idx, 1)).name);
end
str = ['Best sample, lkhood : ' num2str(pg.lkhood, '%.03f')];
text(10, 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2);

end