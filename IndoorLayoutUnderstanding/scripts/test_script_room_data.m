% %% 
% addPaths
% addVarshaPaths
% addpath ../3rdParty/ssvmqp_uci/
% addpath experimental/
% 
% resdir = 'cvpr13data/data.v2.bk';
% 
% expinfo = load(fullfile('cvpr13data/', 'info'));
% 
% cnt = 1; 
% files = dir(fullfile(resdir, '*.mat'));
% 
% valididx = [];
% for i = expinfo.testfiles % 1:length(files)
%     data(cnt) = load(fullfile(resdir, files(i).name));
%     if(isempty(data(cnt).x))
%         i
%     else
%         valididx(end+1) = i;
%         cnt = cnt + 1;
%     end
% end
% %% regenerate testing data
% params = initparam(3, 7);
% resdir = 'cvpr13data/test';
% try
%     matlabpool open 8
% end
% csize = 16;
% for idx = 1:csize:length(data)
%     setsize = min(length(data) - idx + 1, csize);
%     
%     for i = 1:setsize
%         tdata(i) = data(idx+i-1);
%     end    
%     
%     parfor i = 1:setsize
%         disp([num2str(i) ' proc'])
%         [hobjs, inv_list] = generate_object_hypotheses(tdata(i).x.imfile, tdata(i).x.K, tdata(i).x.R, tdata(i).x.yaw, objmodels(), tdata(i).x.dets, 0);
%         assert(isempty(inv_list));
%         tdata(i).x.hobjs = hobjs;
%         tdata(i).x = precomputeOverlapArea(tdata(i).x);
%         tdata(i).iclusters = clusterInteractionTemplates(tdata(i).x, params.model);
%         tdata(i).gpg = getGTparsegraph(tdata(i).x, tdata(i).iclusters, tdata(i).anno, params.model);
%         disp([num2str(i) ' done'])
%     end
%     
%     for i = 1:setsize
%         temp = tdata(i);
%         save(fullfile(resdir, ['data' num2str(idx+i-1, '%03d')]), '-struct', 'temp');
%     end
% end
% matlabpool close
%% load test data
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
%% append ITM detections
load('cache/room_itm_fixed.mat')

expinfo = load(fullfile('cvpr13data/', 'info'));
data = append_ITM_detections(data, ptns, 'cache/itm/room/', expinfo.testfiles);

%% testing
load('cache/tempexp/iter2/params.mat')
%%
res = struct('spg', cell(length(data), 1), 'maxidx', [], 'h', []);

paramsout.numsamples = 1000;
paramsout.pmove = [0 0.4 0 0.3 0.3 0 0 0];
paramsout.accconst = 3;

erroridx = false(1, length(data));
parfor i = 1:length(data)
    fprintf(['processing ' num2str(i)])
    try
        params = paramsout;

        pg = findConsistent3DObjects(data(i).gpg, data(i).x, data(i).iclusters, true);
        pg.layoutidx = 1; % initialization

        [res(i).spg, res(i).maxidx, res(i).h, res(i).clusters] = infer_top(data(i).x, data(i).iclusters, params, pg);

        params.objconftype = 'odd';
        [conf1{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, res(i).clusters, params);
        params.objconftype = 'orgdet';
        [conf2{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, res(i).clusters, params);

        annos{i} = data(i).anno;
        xs{i} = data(i).x;
    catch
        erroridx(i) = true;
    end
    fprintf(' => done\n')
end