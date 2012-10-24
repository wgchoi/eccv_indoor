% for i = 1:length(labels)
% labels(i).pg.childs = 1:length(patterns(i).x.hobjs);
% labels(i).pg.subidx = 14 * ones(1, length(patterns(i).x.hobjs));
% end
%%
clc

i = 16;
indices = indsets{i};
composites = comps{i};

ptns(i).parts(1)
ptns(i).parts(2)

for j = 1:length(indices)
    pg = parsegraph(1);
    pg.scenetype = 1;
    
    pg.layoutidx = 1;
    pg.childs = composites(j).chindices;
    pg.subidx = 14 .* ones(1, length(composites(j).chindices));
    pg = findConsistent3DObjects(pg, patterns(indices(j)).x, patterns(indices(j)).isolated, true);
    
    show2DGraph(pg,patterns(indices(j)).x, patterns(indices(j)).isolated);
    show3DGraph(pg,patterns(indices(j)).x, patterns(indices(j)).isolated);
    title([num2str(composites(j).angle / pi * 180) ' degree'])
    
    view([0 180])
    
    pause;
end

keyboard;
%%
i = 16; 

[itm_examples] = get_itm_examples(patterns, indsets{i}, comps{i});
[clusters] = cluster_itm_examples(itm_examples);



idx = find(clusters == 1);
show_itm_examples(itm_examples(idx))


a = allcomposites{20}(idx);
b = alldidx