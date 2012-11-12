%% train
if(1)
    clear

    addPaths
    addVarshaPaths
    % 
%     try
%         matlabpool open
%     catch em
%         disp(em);
%     end

    params = initparam(3, 7);
    params.quicklearn = true;

    dataroot = 'filtereddata'; 
    datadir = fullfile(dataroot, 'data');

    datafiles = dir(fullfile(datadir, '*.mat'));

    expinfo = load(fullfile(dataroot, 'info'));

    testidx = setdiff(1:length(datafiles), expinfo.trainsplit);
    parfor i = 1:length(testidx) % min(200, length(datafiles))
        data(i) = load(fullfile(datadir, datafiles(testidx(i)).name));
%         data(i).x = sceneClassify(data(i).x);
%         data(i).anno.scenetype = data(i).gpg.scenetype;
        disp(['reading ' num2str(i) 'th done'])
    end
end
%%
expname = 'experiments/finalall';
cachefile = 'napoli9/cache/itmv1_scene/iter3/params';
noitmtype = 'type6';
%
load(cachefile);

paramsout.numsamples = 1000;
paramsout.pmove = [0 0.4 0 0.3 0.3 0 0 0];
paramsout.accconst = 3;
% testing

ntest = length(data);
res = struct('spg', cell(ntest, 1), 'maxidx', [], 'h', [], 'iclusters', []);
res2 = struct('spg', cell(ntest, 1), 'maxidx', [], 'h', [], 'iclusters', []);

mcmccorrection = false(1, length(res));
tic();
parfor i = 1:length(res)
    fprintf(['processing ' num2str(i)])
    try
        params = paramsout;
        pg = findConsistent3DObjects(data(i).gpg, data(i).x, data(i).iclusters);
        pg.layoutidx = 1; % initialization
        
        [res(i).spg, res(i).maxidx, res(i).h, res(i).iclusters] = infer_top(data(i).x, data(i).iclusters, params, pg);
        if(res(i).spg(1).lkhood ~= res(i).spg(2).lkhood)
            fprintf(' ++ ');
            mcmccorrection(i) = true;
        end
        params2 = params;
        params2.model.feattype = noitmtype;
        [res2(i).spg, res2(i).maxidx, res2(i).h, res2(i).iclusters] = infer_top(data(i).x, data(i).iclusters, params2, pg);
        
        % no semantic
        params2 = params;
        params2.model.feattype = noitmtype;
        params2.model.w_iso(:) = 0;
        [res3(i).spg, res3(i).maxidx, res3(i).h, res3(i).iclusters] = infer_top(data(i).x, data(i).iclusters, params2, pg);
        
        % no geometric inclusion
        params2 = params;
        params2.model.feattype = noitmtype;
        params2.model.w_ior(:) = 0;
        [res4(i).spg, res4(i).maxidx, res4(i).h, res4(i).iclusters] = infer_top(data(i).x, data(i).iclusters, params2, pg);
        
        % no pairwise ovelap
        params2 = params;
        params2.model.feattype = noitmtype;
        params2.model.w_ioo(:) = 0;
        [res5(i).spg, res5(i).maxidx, res5(i).h, res5(i).iclusters] = infer_top(data(i).x, data(i).iclusters, params2, pg);
        
        % no deformation
        params2 = params;
        params2.model.feattype = noitmtype;
        params2.model.w_iod(:) = 0;
        [res6(i).spg, res6(i).maxidx, res6(i).h, res6(i).iclusters] = infer_top(data(i).x, data(i).iclusters, params2, pg);
        
        fprintf(' => done\n')
    catch em
        disp(em);
        disp([ num2str(i) 'th error'])
    end
end
sum(mcmccorrection) / length(mcmccorrection)
toc();
%% evaluation
mkdir(expname);

save(fullfile(expname, 'params'), 'params', 'paramsout', 'info');
for i = 1:length(res)
    temp = res(i);
    save(fullfile(expname, ['results' num2str(i, '%03d')]), '-struct', 'temp');
    temp = res2(i);
    save(fullfile(expname, ['noitm_results' num2str(i, '%03d')]), '-struct', 'temp');
end

%% eval
parfor i = 1:length(res)
    params = paramsout;
    
    if(isempty(res(i).iclusters))
        iclusters  = data(i).iclusters;
    else
        iclusters  = res(i).iclusters;
    end
    params.objconftype = 'odd';
    [conf1{i}] = reestimateObjectConfidences(res(i).spg, 2, data(i).x, iclusters, params);
    [conf2{i}] = reestimateObjectConfidences(res(i).spg, 1, data(i).x, iclusters, params);
    
    params2 = params;
    params2.model.feattype = noitmtype;
    params2.objconftype = 'odd';
    % no itm
    [conf3{i}] = reestimateObjectConfidences(res2(i).spg, res2(i).maxidx, data(i).x, res2(i).iclusters, params2);
    % no itm/sem
    [conf4{i}] = reestimateObjectConfidences(res3(i).spg, res3(i).maxidx, data(i).x, res3(i).iclusters, params2);
    % no itm/geo
    [conf5{i}] = reestimateObjectConfidences(res4(i).spg, res4(i).maxidx, data(i).x, res4(i).iclusters, params2);
    % no itm/overlap
    [conf6{i}] = reestimateObjectConfidences(res5(i).spg, res5(i).maxidx, data(i).x, res5(i).iclusters, params2);
    % no itm/deform
    [conf7{i}] = reestimateObjectConfidences(res6(i).spg, res6(i).maxidx, data(i).x, res6(i).iclusters, params2);
    params.objconftype = 'orgdet';
    [conf8{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, iclusters, params);
    
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
end
%%
names = {'sofa', 'table', 'chair', 'bed', 'dtable', 'stable'};
for i = 1:length(names)
    [rec{i}, prec{i}, ap{i}] = evalDetection(annos, xs, conf1, i, false);
end
[rec{length(names)+1}, prec{length(names)+1}, ap{length(names)+1}] = evalDetection(annos, xs, conf1, 0, false, true);

for i = 1:length(names)
    [rec_gr{i}, prec_gr{i}, ap_gr{i}] = evalDetection(annos, xs, conf2, i, false);
end
[rec_gr{length(names)+1}, prec_gr{length(names)+1}, ap_gr{length(names)+1}] = evalDetection(annos, xs, conf2, 0, false, true);

for i = 1:length(names)
    [rec_noitm{i}, prec_noitm{i}, ap_noitm{i}] = evalDetection(annos, xs, conf3, i, false);
end
[rec_noitm{length(names)+1}, prec_noitm{length(names)+1}, ap_noitm{length(names)+1}] = evalDetection(annos, xs, conf3, 0, false, true);

for i = 1:length(names)
    [rec_nosem{i}, prec_nosem{i}, ap_nosem{i}] = evalDetection(annos, xs, conf4, i, false);
end
[rec_nosem{length(names)+1}, prec_nosem{length(names)+1}, ap_nosem{length(names)+1}] = evalDetection(annos, xs, conf4, 0, false, true);

for i = 1:length(names)
    [rec_nogeo{i}, prec_nogeo{i}, ap_nogeo{i}] = evalDetection(annos, xs, conf5, i, false);
end
[rec_nogeo{length(names)+1}, prec_nogeo{length(names)+1}, ap_nogeo{length(names)+1}] = evalDetection(annos, xs, conf5, 0, false, true);

for i = 1:length(names)
    [rec_nool{i}, prec_nool{i}, ap_nool{i}] = evalDetection(annos, xs, conf6, i, false);
end
[rec_nool{length(names)+1}, prec_nool{length(names)+1}, ap_nool{length(names)+1}] = evalDetection(annos, xs, conf6, 0, false, true);

for i = 1:length(names)
    [rec_nodef{i}, prec_nodef{i}, ap_nodef{i}] = evalDetection(annos, xs, conf7, i, false);
end
[rec_nodef{length(names)+1}, prec_nodef{length(names)+1}, ap_nodef{length(names)+1}] = evalDetection(annos, xs, conf7, 0, false, true);

for i = 1:length(names)
    [recbase{i}, precbase{i}, apbase{i}] = evalDetection(annos, xs, conf8, i, false);
end
[recbase{length(names)+1}, precbase{length(names)+1}, apbase{length(names)+1}] = evalDetection(annos, xs, conf8, 0, false, true);
%%
fontsize = 16;
i = length(names) + 1;
plot(rec{i}, prec{i}, 'b-', 'linewidth', 2)
hold on;
plot(rec_noitm{i}, prec_noitm{i}, 'k-', 'linewidth', 2)
plot(rec_nosem{i}, prec_nosem{i}, 'g-', 'linewidth', 2)
% plot(rec_nogeo{i}, prec_nogeo{i}, 'r-', 'linewidth', 2)
% plot(rec_nool{i}, prec_nool{i}, 'y-', 'linewidth', 2)
% plot(rec_nodef{i}, prec_nodef{i}, 'c-', 'linewidth', 2)
plot(recbase{i}, precbase{i}, 'm-', 'linewidth', 2)
grid on
axis([0 1 0 1])

set(gca, 'fontsize', fontsize); 
h = xlabel('recall');
set(h, 'fontsize', fontsize); 
h = ylabel('precision');
set(h, 'fontsize', fontsize); 
h = legend({['W ITM AP=' num2str(ap{i}, '%.03f')], ...
        ['W/O ITM AP=' num2str(ap_noitm{i}, '%.03f')], ...
        ['W/O ITM+SEM AP=' num2str(ap_nosem{i}, '%.03f')], ...
        ['DPM [6] AP=' num2str(apbase{i}, '%.03f')]}, 'location', 'SouthWest');

set(h, 'fontsize', fontsize); 
h = title('Overall');
set(h, 'fontsize', fontsize); 
saveas(gcf, fullfile(expname, ['pr_Overall']), 'fig');
%%
fontsize = 25;
names = {'Sofa', 'Table', 'Chair', 'Bed', 'DiningTable', 'SideTable'};
for i = 1:length(names)
    figure(i);
    plot(recbase{i}, precbase{i}, 'm-', 'linewidth', 2)
    
    hold on;
    plot(rec_nosem{i}, prec_nosem{i}, 'g-', 'linewidth', 2)
    plot(rec_noitm{i}, prec_noitm{i}, 'k-', 'linewidth', 2)
    plot(rec{i}, prec{i}, 'b-', 'linewidth', 2)
%    plot(rec_nogeo{i}, prec_nogeo{i}, 'r-', 'linewidth', 2)
%     plot(rec_nool{i}, prec_nool{i}, 'y-', 'linewidth', 2)
%     plot(rec_nodef{i}, prec_nodef{i}, 'c-', 'linewidth', 2)
    grid on
    axis([0 1 0 1])
    
    set(gca, 'fontsize', fontsize); 
    h = xlabel('recall');
    set(h, 'fontsize', fontsize); 
    h = ylabel('precision');
    set(h, 'fontsize', fontsize); 
%     h = legend({['W ITM AP=' num2str(ap{i}, '%.03f')], ...
%             ['W/O ITM AP=' num2str(ap_noitm{i}, '%.03f')], ...
%             ['W/O ITM+SEM AP=' num2str(ap_nosem{i}, '%.03f')], ...
%             ['DPM [6] AP=' num2str(apbase{i}, '%.03f')]}, 'location', 'SouthWest');
    set(h, 'fontsize', fontsize); 
    h = title(names{i});
    set(h, 'fontsize', fontsize); 
    saveas(gcf, fullfile(expname, ['pr_' names{i}]), 'fig');
end
close all
%% layout evaluation
clear temp;

baseline = zeros(1, length(data));
noitm = zeros(1, length(data));
nosem = zeros(1, length(data));
nogeo = zeros(1, length(data));
greedy =  zeros(1, length(data));
ours = zeros(1, length(data));
for i = 1:length(data)
    baseline(i) = data(i).x.lerr(1);
    
    rid = res(i).spg(1).layoutidx;
    greedy(i) = data(i).x.lerr(rid);
    
    rid = res(i).spg(res(i).maxidx).layoutidx;
    ours(i) = data(i).x.lerr(rid);
    
    rid = res2(i).spg(res2(i).maxidx).layoutidx;
    noitm(i) = data(i).x.lerr(rid);
    
    rid = res3(i).spg(res3(i).maxidx).layoutidx;
    nosem(i) = data(i).x.lerr(rid);
    
    rid = res4(i).spg(res4(i).maxidx).layoutidx;
    nogeo(i) = data(i).x.lerr(rid);
    % temp(i) = res(i).maxidx;
end
evallayout.final = ours;
evallayout.greedy = greedy;
evallayout.baseline = baseline;
evallayout.noitm = noitm;
evallayout.nosem = nosem;
evallayout.nogeo = nogeo;

save(fullfile(expname, 'summary'), 'evallayout');
%%
ctable = zeros(3);
ctable_ours = zeros(3);
ctable_noitm = zeros(3);
ctable_nosem = zeros(3);
ctable_nogeo = zeros(3);
for i = 1:length(data)
    g = data(i).anno.scenetype;
    [~, e] = max(data(i).x.sconf);
    ea = res(i).spg(res(i).maxidx).scenetype;
    ei = res2(i).spg(res2(i).maxidx).scenetype;
    es = res3(i).spg(res2(i).maxidx).scenetype;
    eg = res4(i).spg(res2(i).maxidx).scenetype;
    
    ctable(g, e) = ctable(g, e) + 1;
    ctable_noitm(g, ei) = ctable_noitm(g, ei) + 1;
    ctable_nosem(g, es) = ctable_nosem(g, es) + 1;
    ctable_nogeo(g, eg) = ctable_nogeo(g, eg) + 1;
    ctable_ours(g, ea) = ctable_ours(g, ea) + 1;
end

sclass.baseline = ctable;
sclass.noitm = ctable_noitm;
sclass.nosem = ctable_nosem;
sclass.nogeo= ctable_nogeo;
sclass.ours = ctable_ours;
save(fullfile(expname, 'summary'), '-append', 'sclass');
%%
addpath ~/codes/plottingTools/savefig/
fontsize = 12;
for i = 1:length(names)
    obj = names{i}; 
    uiopen(fullfile(expname, ['pr_' obj '.fig']),1)
    try
        savefig(fullfile(expname, ['pr_' obj]), 'pdf'); 
        saveas(gcf, fullfile(expname, ['pr_' obj '2.pdf']), 'pdf'); 
    end
    close;
end
%%
fbaseline = zeros(5, length(data));
fnoitm = zeros(5, length(data));
fours = zeros(5, length(data));
fnosem = zeros(5, length(data));

cbaseline  = zeros(1, length(data));
cours  = zeros(1, length(data));
cnoitm  = zeros(1, length(data));
cnosem  = zeros(1, length(data));
parfor i = 1:length(data)
    im = imread(data(i).x.imfile);
    imsz = size(im);
    
    fbaseline(:, i) = getWallerr_interun(data(i).anno.gtPolyg, data(i).x.lpolys(1, :));
    cbaseline(i) = getCornerr(data(i).anno.gtPolyg, data(i).x.lpolys(1, :), imsz(1:2));
    
    rid = res(i).spg(res(i).maxidx).layoutidx;
    fours(:, i) = getWallerr_interun(data(i).anno.gtPolyg, data(i).x.lpolys(rid, :));
    cours(i) = getCornerr(data(i).anno.gtPolyg, data(i).x.lpolys(rid, :), imsz(1:2));
    
    rid = res2(i).spg(res2(i).maxidx).layoutidx;
    fnoitm(:, i) = getWallerr_interun(data(i).anno.gtPolyg, data(i).x.lpolys(rid, :));
    cnoitm(i) = getCornerr(data(i).anno.gtPolyg, data(i).x.lpolys(rid, :), imsz(1:2));
    
    rid = res3(i).spg(res3(i).maxidx).layoutidx;
    fnosem(:, i) = getWallerr_interun(data(i).anno.gtPolyg, data(i).x.lpolys(rid, :));
    cnosem(i) = getCornerr(data(i).anno.gtPolyg, data(i).x.lpolys(rid, :), imsz(1:2));
end

1-mean(fbaseline(:, ~any(isnan(fours), 1)), 2)
1-mean(fnosem(:, ~any(isnan(fours), 1)), 2)
1-mean(fnoitm(:, ~any(isnan(fours), 1)), 2)
1-mean(fours(:, ~any(isnan(fours), 1)), 2)

evallayout.ffinal = fours;
evallayout.fbaseline = fbaseline;
evallayout.fnoitm = fnoitm;
evallayout.fnosem = fnosem;
%%
resimg = fullfile(expname, 'resimg');
mkdir(resimg);

for i = 1:length(res)
    show2DGraph(res(i).spg(2), data(i).x, res(i).iclusters);
    drawnow;
    savefig(fullfile(resimg, ['ITM' num2str(i, '%03d')]), 'png');
    close;
    
    show2DGraph(res(i).spg(2), data(i).x, res(i).iclusters, 100, true, conf1{i});
    drawnow;
    savefig(fullfile(resimg, ['ITM_NMS' num2str(i, '%03d')]), 'png');
    close;
    
    show2DGraph(res2(i).spg(2), data(i).x, res2(i).iclusters);
    drawnow;
    savefig(fullfile(resimg, ['ITM_NO' num2str(i, '%03d')]), 'png');
    close;
    
    
    show2DGraph(res2(i).spg(2), data(i).x, res2(i).iclusters, 100, true, conf2{i});
    drawnow;
    savefig(fullfile(resimg, ['ITM_NO_NMS' num2str(i, '%03d')]), 'png');
    close;
end

%%
resimg = fullfile(expname, 'resimg');
mkdir(resimg);
for i = 1:length(res)
    clf
    show3DGraph(res(i).spg(2), data(i).x, res(i).iclusters);
    view([175 68])
    drawnow;
    savefig(fullfile(resimg, ['3D_ITM' num2str(i, '%03d')]), 'png');
end