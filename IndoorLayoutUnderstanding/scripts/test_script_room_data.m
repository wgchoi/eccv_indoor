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

%%
% %% add scene classification
% parfor i = 1:length(data)
%     data(i).x = sceneClassify(data(i).x);
%     [~, dataset] = fileparts(fileparts(data(i).x.imfile));
%     if(strcmp(dataset, 'bedroom'))
%         data(i).anno.scenetype = 1;
%         data(i).gpg.scenetype = 1;
%     elseif(strcmp(dataset, 'livingroom'))
%         data(i).anno.scenetype = 2;
%         data(i).gpg.scenetype = 2;
%     elseif(strcmp(dataset, 'diningroom'))
%         data(i).anno.scenetype = 3;
%         data(i).gpg.scenetype = 3;
%     else
%         disp(dataset);
%         assert(0);
%     end
%     disp(['done ' num2str(i)]);
% end
assert(exist('paramfile', 'var') > 0);
assert(exist('loadfile', 'var') > 0);

disp(['run testing experiment for ' paramfile]);

try
    matlabpool open
end

if(loadfile)
    %% load test data
    % clear
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
end
%% testing
load(paramfile); % './cache/itm_noobs_test/iter3/params.mat')
%%
% res = struct('spg', cell(length(data), 1), 'maxidx', [], 'h', []);
paramsout.numsamples = 1000;
paramsout.pmove = [0 0.4 0 0.3 0.3 0 0 0];
paramsout.accconst = 3;

res = cell(1, length(data));
annos = cell(1, length(data));
xs = cell(1, length(data));
conf1 = cell(1, length(data));
conf2 = cell(1, length(data));

erroridx = false(1, length(data));
csize = 16;

tdata = data(1);
for idx = 1:csize:length(data)
    setsize = min(length(data) - idx + 1, csize);
    fprintf(['processing ' num2str(idx) ' - ' num2str(idx + setsize)]);
    
    tdata(:) = [];
    for i = 1:setsize
        tdata(i) = data(idx+i-1);
    end    
    tempres = cell(1, setsize);
    tconf1 = cell(1, setsize);
    tconf2 = cell(1, setsize);
    
    terroridx = false(1, setsize);
    parfor i = 1:setsize
        try
            params = paramsout;
            pg = findConsistent3DObjects(tdata(i).gpg, tdata(i).x, tdata(i).iclusters, true);
            pg.layoutidx = 1; % initialization
            
            
            [tdata(i).iclusters] = clusterInteractionTemplates(tdata(i).x, params.model);
            [tempres{i}.spg, tempres{i}.maxidx, tempres{i}.h, tempres{i}.clusters] = infer_top(tdata(i).x, tdata(i).iclusters, params, pg);

            params.objconftype = 'odd';
            [tconf1{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            params.objconftype = 'orgdet';
            [tconf2{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);

            fprintf('+');
        catch
            fprintf('-');
            terroridx(i) = true;
        end
    end
    erroridx(idx:idx+setsize-1) = terroridx;
    
    for i = 1:setsize
        res{idx+i-1} = tempres{i};
        annos{idx+i-1} = tdata(i).anno;
        xs{idx+i-1} = tdata(i).x;
        conf1{idx+i-1} = tconf1{i};
        conf2{idx+i-1} = tconf2{i};
    end
    fprintf(' => done\n')
end
summary = evalAllResults(xs, annos, conf2, conf1, res);

resdir = filepart(paramfile);
save(fullfile(resdir, 'testres'), '-v7.3', 'res', 'conf1', 'conf2', 'summary'); 