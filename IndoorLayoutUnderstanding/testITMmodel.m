%% train
if(0)
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

    datafiles = dir(fullfile(datadir, '*.mat'));

    expinfo = load(fullfile(dataroot, 'info'));

    testidx = setdiff(1:length(datafiles), expinfo.trainsplit);
    for i = 1:length(testidx) % min(200, length(datafiles))
        data(i) = load(fullfile(datadir, datafiles(testidx(i)).name));
    end
end
%%
expname = 'experiments/itmv1_mcmc';
cachefile = 'cache/itmv1/iter1/params';
noitmtype = 'type6';
%
load(cachefile);

paramsout.numsamples = 5000;
paramsout.pmove = [0 0.2 0 0.3 0.2 0.3 0 0];
paramsout.accconst = 3;
% testing
res = struct('spg', cell(length(data), 1), 'maxidx', [], 'h', [], 'iclusters', []);
res2 = struct('spg', cell(length(data), 1), 'maxidx', [], 'h', [], 'iclusters', []);

mcmccorrection = false(1, length(data));
tic();
parfor i = 1:length(data)
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
parfor i = 1:length(data)
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
    [conf3{i}] = reestimateObjectConfidences(res2(i).spg, res2(i).maxidx, data(i).x, res2(i).iclusters, params2);
    params.objconftype = 'orgdet';
    [conf4{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, iclusters, params);
    
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
end
%%
names = {'sofa', 'table', 'chair', 'bed', 'dtable', 'stable'};
for i = 1:length(names)
    [rec{i}, prec{i}, ap{i}] = evalDetection(annos, xs, conf1, i, false);
end

for i = 1:length(names)
    [rec_gr{i}, prec_gr{i}, ap_gr{i}] = evalDetection(annos, xs, conf2, i, false);
end

for i = 1:length(names)
    [rec_noitm{i}, prec_noitm{i}, ap_noitm{i}] = evalDetection(annos, xs, conf3, i, false);
end

for i = 1:length(names)
    [recbase{i}, precbase{i}, apbase{i}] = evalDetection(annos, xs, conf4, i, false);
end
%%
fontsize = 12;
for i = 1:length(names)
    figure(i);
    plot(rec{i}, prec{i}, 'b-', 'linewidth', 2)
    hold on;
    plot(rec_gr{i}, prec_gr{i}, 'k-', 'linewidth', 2)
    plot(rec_noitm{i}, prec_noitm{i}, 'r-', 'linewidth', 2)
    plot(recbase{i}, precbase{i}, 'm-', 'linewidth', 2)
    grid on
    axis([0 1 0 1])
    
    set(gca, 'fontsize', fontsize); 
    h = xlabel('recall');
    set(h, 'fontsize', fontsize); 
    h = ylabel('precision');
    set(h, 'fontsize', fontsize); 
    legend({['ours (MCMC) AP=' num2str(ap{i}, '%.03f')], ...
            ['ours (greedy) AP=' num2str(ap_gr{i}, '%.03f')], ...
            ['no itm AP=' num2str(ap_noitm{i}, '%.03f')], ...
            ['dets AP=' num2str(apbase{i}, '%.03f')]}, 'location', 'SouthWest');
        
    h = title(names{i});
    set(h, 'fontsize', fontsize); 
    saveas(gcf, fullfile(expname, ['pr_' names{i}]), 'fig');
end
close all
%% layout evaluation
clear temp;

baseline = zeros(1, length(data));
noitm = zeros(1, length(data));
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
    % temp(i) = res(i).maxidx;
end
evallayout.final = ours;
evallayout.greedy = greedy;
evallayout.baseline = baseline;
evallayout.noitm = noitm;

save(fullfile(expname, 'summary'), 'evallayout');
%
addpath ~/codes/plottingTools/savefig/
fontsize = 12;
for i = 1:length(names)
    obj = names{i}; 
    uiopen(fullfile(expname, ['pr_' obj '.fig']),1)
    savefig(fullfile(expname, ['pr_' obj]), 'pdf'); 
    close;
end