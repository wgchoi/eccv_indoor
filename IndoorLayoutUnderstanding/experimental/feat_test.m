function phi = feat_test(pg, x, iclusters, model)

featlen =   1 + ... % layout confidence : no bias required, selection problem    
            1 + ... % overlap ratio between object and wall
            1;      % smaller floor area

phi = zeros(featlen, 1);
ibase = 1;

objidx = getObjIndices(pg, iclusters);

assert(isfield(pg, 'objscale'));
%% scene layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;

btm_idx = [1 2 6 5 1];
if(isempty(x.lpolys{pg.layoutidx, 1}))
    xfloor = [0];
    yfloor = [0];
else
    [xfloor, yfloor] = poly2cw(x.lpolys{pg.layoutidx, 1}(:, 1), x.lpolys{pg.layoutidx, 1}(:, 2));
end

% imshow(x.imfile)
% hold on
% plot(xfloor, yfloor, 'r')
for i = 1:length(objidx)
    rt1 = x.projs(objidx(i)).poly(:, btm_idx);
    [xobj, yobj] = poly2cw(rt1(1, :), rt1(2, :));
    [xi, yi] = polybool('intersection', xobj, yobj, xfloor, yfloor);
                    
	a1 = polyarea(xobj, yobj);
    a2 = polyarea(xi, yi);
    
    phi(ibase) = phi(ibase) + (a1 - a2) / a1;
    % phi(ibase) = x.lconf(pg.layoutidx);
    
%     plot(xobj, yobj, 'k.-'); 
%     plot(xi, yi, 'y:'); 
end
ibase = ibase + 1;

phi(ibase) = polyarea(xfloor, yfloor) / prod(x.imsz);
ibase = ibase + 1;

assert(featlen == ibase - 1);
assert(~(any(isnan(phi)) || any(isinf(phi))));

end