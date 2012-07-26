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
expname = 'itmv1_scene';
[paramsout, info] = trainLITM_ssvm(data(expinfo.trainsplit), params, expname);