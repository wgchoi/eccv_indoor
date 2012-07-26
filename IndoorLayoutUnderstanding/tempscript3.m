%% train
clear

addPaths
addVarshaPaths

try
    matlabpool open 8
catch em
    disp(em);
end

cnt = 1;
rooms = {'bedroom' 'livingroom' 'diningroom'};
for i = 1:length(rooms)
    datadir = fullfile('traindata4', rooms{i});
    datafiles = dir(fullfile(datadir, '*.mat'));
    for j = 1:length(datafiles) % min(200, length(datafiles))
        data(cnt) = load(fullfile(datadir, datafiles(j).name));
        data(cnt).gpg.scenetype = i;
        cnt = cnt + 1;
    end
end

for i = 1:length(data)
    temp(i) = isempty(data(i).x);
end
data(temp) = [];

load params_layoutest_1st

%% testing
res = struct('spg', cell(length(data), 1), 'maxidx', [], 'h', []);
parfor i = 1:length(data)
    fprintf(['processing ' num2str(i)])
    params = paramsout;
    
	pg = findConsistent3DObjects(data(i).gpg, data(i).x);
	pg.layoutidx = 1; % initialization

    [res(i).spg, res(i).maxidx, res(i).h] = infer_top(data(i).x, data(i).iclusters, params, pg);
    params.objconftype = 'odd';
    [conf1{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params);
    params.objconftype = 'orgdet';
    [conf2{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params);
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
    fprintf(' => done\n')
end
