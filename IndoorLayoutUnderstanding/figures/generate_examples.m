clear
addPaths
addVarshaPaths
addpath ../3rdParty/ssvmqp_uci/
addpath experimental/

resdir = 'cvpr13data/test';
cnt = 1; 
files = dir(fullfile(resdir, '*.mat'));
trainfiles = [];
for i = 1:length(files)
    data(cnt) = load(fullfile(resdir, files(i).name));
    if(isempty(data(cnt).x))
        i
    else
        cnt = cnt + 1;
    end
end
noitm = load('./finalresults/room/res_noitm.mat');
itmres = load('./finalresults/room/res_itm.mat');

[~, idx] = sort(itmres.summary.layout.reest - itmres.summary.layout.baseline);
%%
addpath ~/codes/plottingTools/savefig/;
figbase = 'figures/room/';
mkdir(figbase);
mkdir(fullfile(figbase, 'baseline'));
mkdir(fullfile(figbase, 'full'));
mkdir(fullfile(figbase, 'partial'));

fontsize = 15;

count = 0;
for i = idx
    count = count +1;
%     if(count > 100)
%         break;
%     end
    pg = itmres.res{i}.spg(1);
    pg.childs = [];
    pg.layoutidx = 1;
    [~, pg.scenetype] = max(data(i).x.sconf);
    show2DGraph(pg, data(i).x, itmres.res{i}.clusters);
    str = ['Layout Accuracy: ' num2str(1-data(i).x.lerr(1), '%.02f')];
    text(10, 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);
    
    saveas(gcf, fullfile(fullfile(figbase, 'baseline'), ['ranked' num2str(count, '%03d')]), 'fig');
    saveas(gcf, fullfile(fullfile(figbase, 'baseline'), ['a_ranked' num2str(count, '%03d')]), 'png');
    savefig(fullfile(fullfile(figbase, 'baseline'), ['ranked' num2str(count, '%03d')]), 'pdf');
            
    show2DGraph( itmres.res{i}.spg(2), data(i).x, itmres.res{i}.clusters, -1, true, itmres.conf2{i});
    str = ['Layout Accuracy: ' num2str(1- data(i).x.lerr(itmres.res{i}.spg(2).layoutidx), '%.02f')];
    text(10, 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);
    
    saveas(gcf, fullfile(fullfile(figbase, 'full'), ['ranked' num2str(count, '%03d')]), 'fig');
    saveas(gcf, fullfile(fullfile(figbase, 'full'), ['a_ranked' num2str(count, '%03d')]), 'png');
    savefig(fullfile(fullfile(figbase, 'full'), ['ranked' num2str(count, '%03d')]), 'pdf');
    
    show2DGraph(noitm.res{i}.spg(2), data(i).x, noitm.res{i}.clusters, -1, true, noitm.conf2{i});
    str = ['Layout Accuracy: ' num2str(1-data(i).x.lerr(noitm.res{i}.spg(2).layoutidx), '%.02f')];
    text(10, 20, str, 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);
    
    saveas(gcf, fullfile(fullfile(figbase, 'partial'), ['ranked' num2str(count, '%03d')]), 'fig');
    saveas(gcf, fullfile(fullfile(figbase, 'partial'), ['a_ranked' num2str(count, '%03d')]), 'png');
    savefig(fullfile(fullfile(figbase, 'partial'), ['ranked' num2str(count, '%03d')]), 'pdf');
    
    pause(1);
end