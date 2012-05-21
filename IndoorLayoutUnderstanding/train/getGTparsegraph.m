function gpg = getGTparsegraph(x, iclusters, anno, model)
gpg = parsegraph();
gpg.scenetype = 1; % not implemented yet

for i = 1:length(x.lconf)
    x.lloss(i) =layout_loss(anno.gtPolyg, x.lpolys(i, :)); 
end
[~, gpg.layoutidx] = min(x.lloss);

ovth = 0.5;
obts = [];
or = zeros(length(anno.obj_annos), size(x.dets, 1));
for i = 1:length(anno.obj_annos)
    for j = 1:size(x.dets, 1)
        if(x.dets(j, 1) == anno.obj_annos(i).objtype)
            if(x.dets(j, 1) == 2 ... % don't care if it is a table
                    || anglediff(x.dets(j, 3), anno.obj_annos(i).azimuth) <= pi / 6)
                gtbb = [anno.obj_annos(i).x1 anno.obj_annos(i).y1 anno.obj_annos(i).x2 anno.obj_annos(i).y2];
                or(i, j) = boxoverlap(gtbb, x.dets(j, 4:7));
            end
        end
    end
    
    [dval, midx] = max(or(i, :));
    if(dval > ovth)
        gpg.childs(end+1) = midx;
        obts = [obts, min(x.cubes{midx}(2, :))];
    end
end
assert(length(unique(gpg.childs)) == length(gpg.childs));

if(isempty(obts))
    gpg.camheight = 1.5;
else
    gpg.camheight = -mean(obts);
end

gpg.lkhood = dot(getweights(model), features(gpg, x, iclusters, model));

end