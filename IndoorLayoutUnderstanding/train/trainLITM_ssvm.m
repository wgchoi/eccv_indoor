function [params, info] = trainLITM_ssvm(data, params, expname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('../3rdParty/ssvmqp_uci/');
VERBOSE = 1;
maxiter = 5;

% preprocess
[patterns, labels, annos] = preprocess_data(data, params, VERBOSE);
%% ITM mining
% find ITM patterns
try
    temp = load('cache/itmpatterns');
    itmptns = temp.ptns;
    for i = 1:length(itmptns)
        hit1(i) = length(temp.indsets{i});
    end
catch ee
    disp(ee);
    params.minITMmatch = 15;
    [itmptns, hit1] = learn_itm_patterns(patterns, labels, params, VERBOSE);
end
% append the discovered patterns into the model
params = appendITMtoParams(params, itmptns);
params.model.feattype = 'itm_v1';
% make it more generous
for  i = 1:length(params.model.itmptns)
    params.model.itmptns(i).biases(:) = params.model.itmptns(i).numparts * 4;
end

%% LSVM learning
iter = 0;
%%
while(iter < maxiter)
    cachedir = ['cache/' expname '/iter' num2str(iter)];
    
    if ~exist(cachedir, 'dir')
        mkdir(cachedir);
    end
    
    [~, ~, hit, ptnsets] = latent_completion(patterns, labels, params, true, VERBOSE);
    % remove those ITM that is hit less than 5 times
    params = filterITMpatterns(params, hit, ptnsets, 5);
    
    disp(['There are ' num2str(length(params.model.itmptns)) ' number of patterns']);
    
    % re-run latent completion for SVM train!
    [patterns, labels, hit] = latent_completion(patterns, labels, params, true, VERBOSE);
    for i = 1:length(patterns)
        temp.pattern = patterns(i);
        temp.label = labels(i);
        temp.anno = annos(i);
        save(fullfile(cachedir, ['traindata' num2str(i, '%03d')]), '-struct', 'temp');
    end
    iparams = params;
    save(fullfile(cachedir, 'params'), 'iparams', 'hit');
    
    %%% DDMCMC not ready yet! rely on Greedy + MCMC for layout only
    params.pmove(:) = 0; 
    params.pmove(2) = 1; 
    params.numsamples = 200;
    params.quicklearn = true;
    
    [paramsout, info] = train_ssvm_uci2(patterns, labels, annos, params, 0);
    save(fullfile(cachedir, 'params'), '-append', 'paramsout', 'info');
    
    params = paramsout;
    iter = iter + 1;    
end

end

function [patterns, labels, annos] = preprocess_data(data, params, VERBOSE)

patterns = struct(  'idx', cell(length(data), 1), ...
                    'x', cell(length(data), 1), ...
                    'isolated', cell(length(data), 1), ...
                    'composite', cell(length(data), 1), ...
                    'iclusters', cell(length(data), 1));   % idx, x, iclusters 

labels = struct(  'idx', cell(length(data), 1), ...
                    'pg', cell(length(data), 1), ...
                    'lcpg', cell(length(data), 1));   % idx, pg, lcpg
                
annos = struct('oloss', cell(length(data), 1));

removecnt = 0;
totalfp = 0;

for i = 1:length(data)
    %%% start from gt labels..
    %%% it would help making over-generated violating consts
    %%% also make it iterate less as it goes through iterations.
    if(VERBOSE > 2)
        disp(['prepare data ' num2str(i)])
    end
    patterns(i).idx = i;
    patterns(i).x = data(i).x;
    patterns(i).isolated = data(i).iclusters;
    
    labels(i).idx = i;
    labels(i).pg = data(i).gpg;
    if(strcmp(params.losstype, 'exclusive'))
        if(isfield(params.model, 'commonground') && params.model.commonground)
            labels(i).pg = findConsistent3DObjects(labels(i).pg, data(i).x);
        else
            mh = getAverageObjectsBottom(labels(i).pg, data(i).x);
            if(~isnan(mh))
                labels(i).pg.camheight = -mh;
            else
                labels(i).pg.camheight = 1.5;
            end
            assert(~isnan(labels(i).pg.camheight));
            assert(~isinf(labels(i).pg.camheight));
        end
        
        labels(i).feat = features(labels(i).pg, patterns(i).x, patterns(i).isolated, params.model);
        labels(i).loss = lossall(data(i).anno, patterns(i).x, labels(i).pg, params);
        annos(i) = data(i).anno;
    elseif(strcmp(params.losstype, 'isolation'))
        GT = [];
        Det = data(i).x.dets(:, [4:7 1]);
        for j = 1:length(data(i).anno.obj_annos)
            anno = data(i).anno.obj_annos(j);
            GT(j, :) = [anno.x1 anno.y1 anno.x2 anno.y2 anno.objtype];
        end
        % GT(GT(:, end) > 2, :) = [];
        annos(i).oloss = computeloss(Det, GT);
        
        numtp(i) = sum(annos(i).oloss(:, 2));
        nump(i) = size(GT, 1);
        
        ambids = find((annos(i).oloss(:, 1) == 0) & (annos(i).oloss(:, 2) == 0));
        %% remove too many flase positives
        filterids = falsepositiveNMSFilter(patterns(i).x, find((annos(i).oloss(:, 1) == 1)), 35);
        ambids = unique(union(ambids, filterids));
        
        removecnt = removecnt + length(filterids);
        totalfp = totalfp + sum(annos(i).oloss(:, 1) == 1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        annos(i).oloss(ambids, :) = [];
        
        patterns(i).isolated(ambids) = [];
        
        patterns(i).x.dets(ambids, :) = [];
        patterns(i).x.locs(ambids, :) = [];
        patterns(i).x.cubes(ambids) = [];
        patterns(i).x.projs(ambids) = [];
        
        patterns(i).x.orpolys(ambids, :) = [];
        patterns(i).x.orpolys(:, ambids) = [];
        patterns(i).x.orarea(ambids, :) = [];
        patterns(i).x.orarea(:, ambids) = [];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%% find the ground truth solution
        labels(i).pg = data(i).gpg;
        labels(i).pg.childs = find(annos(i).oloss(:, 2));
        if(isfield(params.model, 'commonground') && params.model.commonground)
            labels(i).pg = findConsistent3DObjects(labels(i).pg, patterns(i).x, patterns(i).isolated);
        else
            mh = getAverageObjectsBottom(labels(i).pg, patterns(i).x);
            if(~isnan(mh))
                labels(i).pg.camheight = -mh;
            else
                labels(i).pg.camheight = 1.5;
            end
            assert(~isnan(labels(i).pg.camheight));
            assert(~isinf(labels(i).pg.camheight));
        end
        
        labels(i).feat = features(labels(i).pg, patterns(i).x, patterns(i).isolated, params.model);
        labels(i).loss = lossall(annos(i), patterns(i).x, labels(i).pg, params);
        
        gtfeats(:, i) = labels(i).feat;
    else
        assert(0, 'not defined loss type');
    end
end
if(VERBOSE > 0)
    disp(['prepare data done, removed ' num2str(removecnt) '/' num2str(totalfp) ' for faster training'])
end
end

function [itmptns, hit] = learn_itm_patterns(patterns, labels, params, VERBOSE)
%%
if ~exist('cache', 'dir')
    mkdir('cache');
end

cand_data = true(1, length(patterns));
numobjs = zeros(1, length(patterns));
for i = 1:length(patterns)
    numobjs(i) = length(labels(i).pg.childs);
    cand_data(i) = numobjs(i) > 1;
end

allptns = ITMrule(1);
allptns(:) = [];
allcomposites = {};
alldidx = {};
% lets ignore..... way to expensive....
cand_data(numobjs > 6) = false;
rid = 100;

%% ITM proposal
if(VERBOSE > 0)
    disp('ITM proposal begin!!');
end
while(any(cand_data))
    idx = find(cand_data);
    [~, maxid] = sort(-numobjs(cand_data));
    idx = idx(maxid(1));
    
    ptns = proposeITM(labels(idx).pg, patterns(idx).x, patterns(idx).isolated);
    for i = 1:length(ptns)
        ptns(i).type = rid;
        rid = rid + 1;
    end
    if(VERBOSE > 1), tic(); end
    % large one first
    for j = length(ptns):-1:1
        composite = graphnodes(0);
        didx = [];
        tidx = find(cand_data);
        
        ptn = ptns(j);
        %%% redundancy check
        redundant = 0;
        for k = 1:length(allptns)
            if(compareITM(ptn, allptns(k)) < 9)
                redundant = 1;
                break;
            end
        end
        if(redundant), continue;  end
        
        %%% match examples
        for tt = 1:length(tidx)
            k = tidx(tt);
            temp = findITMCandidates(patterns(k).x, patterns(k).isolated, params, ptn, labels(k).pg.childs);
            composite(end+1:end+length(temp)) = temp;
            didx(end+1:end+length(temp)) = k .* ones(1, length(temp));
        end
        
        %%% match threshold
        if(length(composite) > params.minITMmatch)
            ptn = reestimateITM(ptn, composite);
            allptns(end+1) = ptn;
            allcomposites{end+1} = composite;
            alldidx{end+1} = didx;
%             for k = 1:length(didx)
%                 did = didx(k);
%                 if(length(labels(did).pg.childs) == length(composite(k).chindices))
%                     cand_data(did) = false;
%                 end
%             end
            if(VERBOSE > 1)
                fprintf('+');
            end
        else
            if(VERBOSE > 1)
                fprintf('.');
            end
        end
    end
    
    cand_data(idx) = false;
    
    if(VERBOSE > 1)
        fprintf([num2str(idx) ' is done (remain : ' num2str(sum(cand_data)) ' patterns : ' num2str(length(allptns)) '). ']); 
        toc();
    end
    save('cache/itmpatterns', 'allptns', 'allcomposites', 'alldidx');
end
if(VERBOSE > 0)
    disp('ITM proposal done!!');
end
%% regroup candidates
allcomp2 = {};
alldidx2 = {};
for i = 1:length(allptns)
    composite = graphnodes(0);
    didx = [];

    ptn = allptns(i);
    %%% match examples
    for j = 1:length(patterns)
        temp = findITMCandidates(patterns(j).x, patterns(j).isolated, params, ptn, labels(j).pg.childs);
        composite(end+1:end+length(temp)) = temp;
        didx(end+1:end+length(temp)) = j .* ones(1, length(temp));
    end
    
    allcomp2{i} = composite;
    alldidx2{i} = didx;
end
%% agglomerative clustering
ptns = allptns;
comps = allcomp2;
indsets = alldidx2;
if(VERBOSE > 1)
    disp(['initially ' num2str(length(ptns)) ' number of patterns'])
end
while(1)
    [clustered, ptns, comps, indsets] = clusterITMpatterns(patterns, ptns, comps, indsets, params);
    if(~clustered)
        break;
    end
end
if(VERBOSE > 0)
    disp([num2str(length(ptns)) ' number of patterns after clustering'])
end

% reorder and assign itm id
hit = zeros(1, length(ptns));
for i = 1:length(ptns)
    ptns(i).type = (params.model.nobjs + i);
    hit(i) = length(indsets{i});
end
save('cache/itmpatterns', '-append', 'ptns', 'comps', 'indsets');
itmptns = ptns;

end

function [params, info] = ssvm_train()

end