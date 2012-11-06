%% detector statistics in training sets
clear

% load ./cvpr13data/human/fulltrainfiles.mat
load ./cvpr13data/fulltrainset.mat

pos_scores = cell(1, 7);
neg_scores = cell(1, 7);

for i = 1:length(patterns)
    pg = labels(i).pg;
    posidx = pg.childs;
    
    for j = 1:length(posidx)
        oid = patterns(i).x.dets(posidx(j), 1);
        score = patterns(i).x.dets(posidx(j), end);
        pos_scores{oid} = [pos_scores{oid}; score];
    end
    
    negidx = setdiff(1:size(patterns(i).x.dets, 1), pg.childs);
    
    for j = 1:length(negidx)
        oid = patterns(i).x.dets(negidx(j), 1);
        score = patterns(i).x.dets(negidx(j), end);
        neg_scores{oid} = [neg_scores{oid}; score];
    end
end

%%
figure;

cnt = 1;
objs = objmodels();

for i = 1:7
    subplot(2,7,cnt);
    hist(pos_scores{i}, -3:0.1:3);
    title([objs(i).name ' : pos'] )
    
    subplot(2,7,7+cnt);
    
    % cut out for visualization!
    
    neg_scores{i}(neg_scores{i} < -3) = []; 
    
    hist(neg_scores{i}, -3:0.1:3);
    title([objs(i).name ' : neg'] )
    
    cnt = cnt + 1;
end