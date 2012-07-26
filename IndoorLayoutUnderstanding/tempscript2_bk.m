if (0)
    %% train
    clear

    addPaths
    addVarshaPaths
    % 
    try
        matlabpool open 8
    catch em
        disp(em);
    end

    params = initparam(3, 6);
    params.quicklearn = true;

    dataroot = 'filtereddata'; 
    datadir = fullfile(dataroot, 'data');
    %%
    datafiles = dir(fullfile(datadir, '*.mat'));
    parfor i = 1:length(datafiles) % min(200, length(datafiles))
        data(i) = load(fullfile(datadir, datafiles(i).name));
        data(i).x = sceneClassify(data(i).x);
        data(i).anno.scenetype = data(i).gpg.scenetype;
        disp(['reading ' num2str(i) 'th done'])
    end
    expinfo = load(fullfile(dataroot, 'info'));
    %%
    [paramsout, info] = train_ssvm_uci(data(expinfo.trainsplit), params);
    %% remove train data
    testidx = setdiff(1:length(data), expinfo.trainsplit);
    data = data(testidx);
end
%% testing
res = struct('spg', cell(length(data), 1), 'maxidx', [], 'h', []);
parfor i = 1:length(data)
    fprintf(['processing ' num2str(i)])
    params = paramsout;
    
	pg = findConsistent3DObjects(data(i).gpg, data(i).x, data(i).iclusters);
	pg.layoutidx = 1; % initialization
    [res(i).spg, res(i).maxidx, res(i).h] = infer_top(data(i).x, data(i).iclusters, params, pg);
    fprintf(' => done\n')
end
%% evaluation
expname = 'experiments/type6_sclass';
mkdir(expname);

save(fullfile(expname, 'params'), 'params', 'paramsout', 'info');
for i = 1:length(res)
    temp = res(i);
    save(fullfile(expname, ['results' num2str(i, '%03d')]), '-struct', 'temp');
end

%% eval
parfor i = 1:length(data)
    params = paramsout;
    
    params.objconftype = 'odd';
    [conf1{i}] = reestimateObjectConfidences(res(i).spg, 2, data(i).x, data(i).iclusters, params);
    
    params.objconftype = 'odd';
    [conf2{i}] = reestimateObjectConfidences(res(i).spg, 1, data(i).x, data(i).iclusters, params);
    
    params.objconftype = 'orgdet';
    [conf3{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params);
    
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
end
%
names = {'sofa', 'table', 'chair', 'bed', 'dtable', 'stable'};
for i = 1:length(names)
    [rec{i}, prec{i}, ap{i}] = evalDetection(annos, xs, conf1, i, false);
end

for i = 1:length(names)
    [rec_gr{i}, prec_gr{i}, ap_gr{i}] = evalDetection(annos, xs, conf2, i, false);
end

for i = 1:length(names)
    [recbase{i}, precbase{i}, apbase{i}] = evalDetection(annos, xs, conf3, i, false);
end
%
fontsize = 12;
for i = 1:length(names)
    figure(i);
    plot(rec{i}, prec{i}, 'b-', 'linewidth', 2)
    hold on;
    plot(rec_gr{i}, prec_gr{i}, 'k-', 'linewidth', 2)
    plot(recbase{i}, precbase{i}, 'm-', 'linewidth', 2)
    grid on
    axis([0 1 0 1])
    
    set(gca, 'fontsize', fontsize); 
    h = xlabel('recall');
    set(h, 'fontsize', fontsize); 
    h = ylabel('precision');
    set(h, 'fontsize', fontsize); 
    legend({['ours AP=' num2str(ap{i}, '%.03f')], ['greedy AP=' num2str(ap_gr{i}, '%.03f')], ['dets AP=' num2str(apbase{i}, '%.03f')]}, 'location', 'SouthWest');
    h = title(names{i});
    set(h, 'fontsize', fontsize); 
    saveas(gcf, fullfile(expname, ['pr_' names{i}]), 'fig');
end

dets.ap_mcmc = ap;
dets.ap_greedy = ap_gr;
dets.ap_greedy = apbase;

save(fullfile(expname, 'summary'), '-append', 'dets');
close all
% layout evaluation
clear temp;

baseline = zeros(1, length(data));
greedy =  zeros(1, length(data));
ours = zeros(1, length(data));
for i = 1:length(data)
    baseline(i) = data(i).x.lerr(1);
    
    rid = res(i).spg(1).layoutidx;
    greedy(i) = data(i).x.lerr(rid);
    rid = res(i).spg(res(i).maxidx).layoutidx;
    ours(i) = data(i).x.lerr(rid);
    temp(i) = res(i).maxidx;
end
evallayout.final = ours;
evallayout.greedy = greedy;
evallayout.baseline = baseline;

save(fullfile(expname, 'summary'), '-append', 'evallayout');
%
addpath ~/codes/plottingTools/savefig/
fontsize = 12;
for i = 1:length(names)
    obj = names{i}; 
    uiopen(fullfile(expname, ['pr_' obj '.fig']),1)
    savefig(fullfile(expname, ['pr_' obj]), 'pdf'); 
    close;
end
%% 
ctable = zeros(3);
ctable_g = zeros(3);
ctable_mcmc = zeros(3);

for i = 1:length(data)
    g = data(i).anno.scenetype;
    [~, e] = max(data(i).x.sconf);
    
    eg = res(i).spg(res(i).maxidx).scenetype;
    em = res(i).spg(res(i).maxidx).scenetype;
    
    ctable(g, e) = ctable(g, e) + 1;
    
    ctable_g(g, eg) = ctable_g(g, eg) + 1;
    ctable_mcmc(g, em) = ctable_mcmc(g, em) + 1;
end

sclass.baseline = ctable;
sclass.greedy = ctable_g;
sclass.mcmc = ctable_mcmc;
save(fullfile(expname, 'summary'), '-append', 'sclass');