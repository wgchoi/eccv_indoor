% %% read data
% clear
% 
% addPaths
% addVarshaPaths
% 
% try
%     matlabpool open 8
% catch em
%     disp(em);
% end
% 
% params = initparam(3, 6);
% cnt = 1;
% rooms = {'bedroom' 'livingroom' 'diningroom'};
% for i = 1:length(rooms)
%     datadir = fullfile('traindata4', rooms{i});
%     datafiles = dir(fullfile(datadir, '*.mat'));
%     for j = 1:length(datafiles) % min(200, length(datafiles))
%         data(cnt) = load(fullfile(datadir, datafiles(j).name));
%         data(cnt).gpg.scenetype = i;
%         cnt = cnt + 1;
%     end
% end
% 
% for i = 1:length(data)
%     temp(i) = isempty(data(i).x);
% end
% data(temp) = [];

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
cand_data(numobjs > 5) = false;
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
    
    removeidx = [];
    for i = 1:length(rules)
        for j = 1:length(allrules)
            if(compareITM(rules(i), allrules(j)) < 9)
                removeidx(end+1) = i;
                break;
            end
        end
    end
    fprintf('proposal before filtering : %d ', length(rules)); 
    rules(removeidx) = [];
    fprintf('after filtering %d \n', length(rules));

    tic();
    for j = length(rules):-1:1
        composite = graphnodes(0);
        didx = [];
        tidx = find(cand_data);
        
        cset = cell(1, length(tidx));
        dset = cell(1, length(tidx));
        
        ptn = rules(j);
%         parfor tt = 1:length(tidx)
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
        
%         for tt = 1:length(tidx)
%             k = tidx(tt);
%             temp = findITMCandidates(data(k).x, data(k).iclusters, params, rules(j), data(k).gpg.childs);
%             composite(end+1:end+length(temp)) = temp;
%             didx(end+1:end+length(temp)) = k .* ones(1, length(temp));
%         end
%         length(composite)
        if(length(composite) > 15)
            for k = 1:length(allrules)
                if(compareITM(rules(j), allrules(k)) < 9)
                    continue;
                end
            end
            rule = reestimateITM(rules(j), composite);
            allrules(end+1) = rules(j);
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
    
    save('temppatterns2', 'allrules', 'all_composites', 'all_didx');
end
disp('proposal done!!');
return
%% Iterative clustering
for i = 1:length(all_composites)
    hit(i) = length(all_composites{i});
end
ruleset = ITMrule(1);
ruleset(:) = [];
[~, initidx] = max(hit);

while(1)
end

%%
visualizeITM(rule)
for i = 1:length(composite)
    id = didx(i);
    pg = data(id).gpg;
    pg.childs = composite(i).chindices;
    pg = findConsistent3DObjects(pg, data(id).x);
    show2DGraph(pg, data(id).x, data(id).iclusters);
    show3DGraph(pg, data(id).x, data(id).iclusters);
    pause
end