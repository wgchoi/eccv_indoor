%% load cached data
clear
addPaths;
addVarshaPaths;

files = dir('./cache/itmobs/iter3/traindata*.mat');  
datadir = './cache/itmobs/iter3';              

load('./cache/itmobs/iter3/params.mat');
params = iparams;

for i = 1:length(files)                      
    temp = load(fullfile(datadir, files(i).name));
    patterns(i) = temp.pattern;
    [patterns(i).isolated] = clusterInteractionTemplates(patterns(i).x, params.model);
    labels(i) = temp.label;
    annos(i) = temp.anno;
end
%% training
try 
    matlabpool open
end

iter = 5;
params.C = 1;

expname = 'itmobs_test1_v1';
params.model.feattype = 'itm_v1';
% expname = 'itmobs_test1_v2';
% params.model.feattype = 'itm_v2';
cachedir = ['cache/' expname '/iter' num2str(iter)];
if ~exist(cachedir, 'dir')
    mkdir(cachedir);
end

params.model.itmhogs = true;
% learn itm hog model ... 
params = append_hog2itm(params, 'cache/dpm2/itm');
% append observation confidence.
fprintf('appending itm hog observarions ... '); tic();
patterns = itm_observation_response(patterns, params.model);
fprintf('done'); toc();

save(fullfile(cachedir, 'params'), 'iparams', 'hit');

%%% DDMCMC not ready yet! rely on Greedy + MCMC for layout only
params.pmove = [0 1.0 0 0 0 0 0 0];
params.numsamples = 100;
params.quicklearn = true;
params.max_ssvm_iter = 6 + iter;

[paramsout, info] = train_ssvm_uci2(patterns, labels, annos, params, 0);
save(fullfile(cachedir, 'params'), '-append', 'paramsout', 'info');