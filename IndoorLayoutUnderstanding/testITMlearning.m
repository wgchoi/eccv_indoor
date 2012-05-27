%% read data
clear

addPaths
addVarshaPaths

params = initparam(3, 6);
cnt = 1;
rooms = {'bedroom' 'livingroom' 'diningroom'};
% rooms = {'livingroom'};
for i = 1:length(rooms)
    datadir = fullfile('finaldata', rooms{i});
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
%%
cand_data = true(1, length(data));
numobjs = zeros(1, length(data));
for i = 1:length(data)
    cand_data(i) = length(data(i).gpg.childs) > 1;
    numobjs(i) = length(data(i).gpg.childs);
end
%
allrules = ITMrule(1);
allrules(:) = [];
all_composites = {};
all_didx = {};

% lets ignore..... way to expensive....
cand_data(numobjs > 6) = false;
% %% reduce set for quick experiment
% for i = 1:length(data)
%     if(data(i).gpg.scenetype ~= 2)
%         cand_data(i) = false;
%     end
% end
rid = 100;
%%
while(any(cand_data))
    idx = find(cand_data);
    [~, maxid] = sort(-numobjs(cand_data));
    idx = idx(maxid(1));
    
    rules = proposeITM(data(idx).gpg, data(idx).x, data(idx).iclusters);
    for i = 1:length(rules)
        rules(i).type = rid;
        % check if it is in set already..
        rid = rid + 1;
    end
    cand_data(idx) = false;

    tic();
    for j = length(rules):-1:1
        composite = graphnodes(0);
        didx = [];
        tidx = find(cand_data);
        cset = cell(1, length(tidx));
        dset = cell(1, length(tidx));
        
        ptn = rules(j);
        %%% redundancy check
        redundant = 0;
        for k = 1:length(allrules)
            if(compareITM(ptn, allrules(k)) < 9)
                redundant = 1;
                break;
            end
        end
        if(redundant), continue;  end
        %%% match examples
        for tt = 1:length(tidx)
            k = tidx(tt);
            temp = findITMCandidates(data(k).x, data(k).iclusters, params, ptn, data(k).gpg.childs);
            cset{tt} = temp;
            dset{tt} = k .* ones(1, length(temp));
        end
        
        for tt = 1:length(tidx)
            composite(end+1:end+length(dset{tt})) = cset{tt};
            didx(end+1:end+length(dset{tt})) = dset{tt};
        end
        
        %%% match threshold
        if(length(composite) > 15)
            ptn = reestimateITM(ptn, composite);
            allrules(end+1) = ptn;
            all_composites{end+1} = composite;
            all_didx{end+1} = didx;
            
            for k = 1:length(didx)
                did = didx(k);
                if(length(data(did).gpg.childs) == length(composite(k).chindices))
                    cand_data(did) = false;
                end
            end
            fprintf('+');
        else
            fprintf('.');
        end
    end    
    fprintf([num2str(idx) ' is done (remain : ' num2str(sum(cand_data)) ' patterns : ' num2str(length(allrules)) '). ']); toc();    
    save('itmpatterns2', 'allrules', 'all_composites', 'all_didx');
end
disp('proposal done!!');
%% regroup candidates
allcomposites = {};
alldidx = {};
for i = 1:length(allrules)
    composite = graphnodes(0);
    didx = [];
    cset = cell(1, length(data));
    dset = cell(1, length(data));

    ptn = allrules(i);
    %%% match examples
    for j = 1:length(data)
        temp = findITMCandidates(data(j).x, data(j).iclusters, params, ptn, data(j).gpg.childs);
        cset{j} = temp;
        dset{j} = j .* ones(1, length(temp));
    end

    for j = 1:length(data)
        composite(end+1:end+length(dset{j})) = cset{j};
        didx(end+1:end+length(dset{j})) = dset{j};
    end
    
    allcomposites{i} = composite;
    alldidx{i} = didx;
end

%% check
% for i = 1:length(allrules)
%     visualizeITM(allrules(i));
%     title(['total ' num2str(length(all_didx{i})) ' => ' num2str(length(alldidx{i}))]);
%     pause
% end
%% agglomorotive clustering
ptns = allrules;
comps = allcomposites;
indsets = alldidx;

disp(['initially ' num2str(length(ptns)) ' number of patterns'])
while(1)
    [clustered, ptns, comps, indsets] = clusterITMpatterns(data, ptns, comps, indsets, params);
    if(~clustered)
        break;
    end
end
disp([num2str(length(ptns)) ' number of patterns after clustering'])

% reorder and assign itm id
for i = 1:length(ptns)
    ptns(i).type = (params.model.nobjs + i);
end
save('itmpatterns2', '-append', 'ptns', 'comps', 'indsets');
%% check
for i = 31:length(ptns)
    visualizeITM(ptns(i));
    title(['total ' num2str(length(indsets{i}))]);
    pause
end
return;
%%
params = initparam(3, 6);
params = appendITMtoParams(params, ptns);
params.model.feattype = 'itm_v0';
try
    matlabpool open 8
end

parfor i = 1:length(data)
    icl = data(i).iclusters;
    for j = 1:length(params.model.itmptns)
        [composites, data(i).x] = findITMCandidates(data(i).x, data(i).iclusters, params, params.model.itmptns(j));
        icl = [icl; composites];
    end
    data(i).iclusters = icl;
    lpg(i) = latentITMcompletion(data(i).gpg, data(i).x, data(i).iclusters, params);
    disp([ num2str(i) ' latent completion done!']);
end


