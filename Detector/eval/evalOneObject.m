clear; clc;
%%
model = 3;
%%
if model == 1
    dname = 'DPM';
    thlist = -2:0.1:2;
    expname = 'DPM Yu Model';
    imdir = '../Data_Collection/livingroom/';
    resdir = './results/DPM_YUXIANG/livingroom/';
    annodir = '../Annotation/livingroom/'; 
    evaldir = 'results/DPM_YUXIANG/eval';
    gtids = [1 1 2 2 5 5 4 4];
    detids = 1:8;
    
    temp = load('../Annotation/livingroom/0000000004_labels.mat');
    objtypes = temp.objtypes;
    for i = 1:length(gtids)
        names{i} = objtypes{gtids(i)};
    end
elseif model == 2
    dname = 'DPM';
    thlist = -2:0.1:2;
    expname = 'DPM PASCAL';
    imdir = '../Data_Collection/livingroom/';
    resdir = './results/DPM_PASCAL/livingroom/';
    annodir = '../Annotation/livingroom/'; 
    evaldir = 'results/DPM_PASCAL/eval';
    gtids = [1 4];
    detids = [1 3];
    
    temp = load('../Annotation/livingroom/0000000004_labels.mat');
    objtypes = temp.objtypes;
    for i = 1:length(gtids)
        names{i} = objtypes{gtids(i)};
    end
elseif model == 3
    dname = 'YU';
    thlist = -1000:100:200;
    expname = 'Yu Method';
    imdir = '../Data_Collection/livingroom/resized';
    resdir = './results/YuMethod/livingroom/';
    annodir = '../Annotation/livingroom/'; 
    evaldir = 'results/YuMethod/eval';
    gtids = [1 2 4 5];
    detids = [1 2 3 4];
    names = {'sofa' 'table' 'chair' 'bed'};
end
%% 
if ~exist(evaldir, 'dir')
    mkdir(evaldir);
end
evalfile = fullfile(evaldir, 'detection.mat');
%%
[recall, fppi, pr] = evalOneDetector(imdir, resdir, annodir, thlist, gtids, detids, dname, names);
save(evalfile, 'recall', 'fppi', 'pr', 'names', 'dname', 'expname');

return;
%%
figure;
plot(fppi', recall', '.-');
grid on;
xlabel('fppi'); ylabel('recall');
legend(names);
title([expname ' fppi-recall curve'])
axis([0 1.5 0 1])

figure;
plot(pr', recall', '.-');
grid on;
xlabel('precision'); ylabel('recall');
legend(names);
title([expname ' PR curve'])
axis([0 1 0 1])