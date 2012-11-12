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
%%
om = objmodels();
for i = 1:length(itmres.summary.objdet)
    plot(itmres.summary.baseline_objdet(i).rec, itmres.summary.baseline_objdet(i).prec, 'r--', 'linewidth', 2);
    hold on;
    plot(noitm.summary.objdet(i).rec, noitm.summary.objdet(i).prec, 'k-.', 'linewidth', 2);
    plot(itmres.summary.objdet(i).rec, itmres.summary.objdet(i).prec, 'b', 'linewidth', 2);
    hold off;
    h = title(om(i).name);
    set(h, 'fontsize', 15);
    grid on;
    axis([0 1 0 1]);
    h = gca;
    set(h, 'fontsize', 15);
    
    h = xlabel('recall');
    set(h, 'fontsize', 15);
    h = ylabel('precision');
    set(h, 'fontsize', 15);
    
    h = legend({['DPM AP = ' num2str(itmres.summary.baseline_objdet(i).ap, '%.03f')], ...
            ['NO-3DGP AP = ' num2str(noitm.summary.objdet(i).ap, '%.03f')], ...
            ['3DGP AP = ' num2str(itmres.summary.objdet(i).ap, '%.03f')]}, ...
            'Location', 'SouthWest');
    set(h, 'fontsize', 15);
    
    savefig(fullfile(figbase, om(i).name), 'pdf')
    savefig(fullfile(figbase, om(i).name), 'png')
    pause(1)
end
%%
base_err  = zeros(5, length(data));
nogp_err  = zeros(5, length(data));
gp_err  = zeros(5, length(data));
for i = 1:length(data)
    gpoly = data(i).anno.gtPolyg;
    baseline_poly = data(i).x.lpolys(1, :);
    base_err(:, i) = getWallerr_interun(gpoly,baseline_poly);
    
    nogp_poly = data(i).x.lpolys(noitm.res{i}.spg(2).layoutidx, :);
    nogp_err(:, i) = getWallerr_interun(gpoly,nogp_poly);
    gp_poly = data(i).x.lpolys(itmres.res{i}.spg(2).layoutidx, :);
    gp_err(:, i) = getWallerr_interun(gpoly,gp_poly);
end
