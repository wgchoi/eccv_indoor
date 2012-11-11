clear

database = 'cache/itmobs/iter3';
files = dir(fullfile(database, 'train*'));

disp(['reading data']);
for i = 1:length(files)
    temp = load(fullfile(database, files(i).name));
    
    patterns(i) = temp.pattern;
    lables(i) = temp.label;
    annos(i) = temp.anno;
    
    for j = 1:length(patterns(i).iclusters)
        patterns(i).iclusters(j).robs = 0;
    end
end

load('/home/wgchoi/codes/eccv_indoor/IndoorLayoutUnderstanding/cache/itmobs/iter3/params.mat')

params = iparams;
params.model.itmptns
params.pmove = [0 1.0 0 0 0 0 0 0];
params.numsamples = 100;
params.quicklearn = true;
params.max_ssvm_iter = 6 + 3;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.model.feattype = 'itm_v3';
params.model.w_ior = zeros(8, 1);
params.model.w_iso = zeros(24, 1);
paramfile = 'cache/itmobs/reproduced_v3';
resfile = 'cache/itmobs/reproduced_testres_v3';
patterns = append_ITM_detections(patterns, params.model.itmptns, 'cache/itmdets', 'cache/dpm_parts');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


params2 = appendITMtoParams(params, params.model.itmptns);
try
	matlabpool open 8;
end
disp(['run training experiment for ' paramfile]);
[paramsout, info] = train_ssvm_uci2(patterns, lables, annos, params2, 0); 


loadfile = 1;
save(paramfile, 'paramsout', 'info');
%%
assert(exist('paramfile', 'var') > 0);
assert(exist('loadfile', 'var') > 0);

disp(['run testing experiment for ' paramfile]);
if(loadfile)
    % clear
    addPaths
    addVarshaPaths
    addpath ../3rdParty/ssvmqp_uci/
    addpath experimental/

    resdir = 'cvpr13data/room/test';
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
end
%% testing
load(paramfile); % './cache/itm_noobs_test/iter3/params.mat')
if(strcmp(paramsout.model.feattype, 'itm_v3'))
    data = append_ITM_detections(data, paramsout.model.itmptns, 'cache/itmdets', 'cache/dpm_parts');
end
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
csize = 32;

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

resdir = fileparts(paramfile);
save(resfile, '-v7.3', 'res', 'conf1', 'conf2', 'summary'); 

