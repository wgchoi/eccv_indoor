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
% params = initparam(3, 5);
% cnt = 1;
% rooms = {'bedroom' 'livingroom' 'diningroom'};
% for i = 1:length(rooms)
%     datadir = fullfile('traindata', rooms{i});
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
% 
% %% reduce set for quick experiment
% data = data(1:3:end);
% %%
% cand_data = true(1, length(data));
% numobjs = zeros(1, length(data));
% for i = 1:length(data)
%     cand_data(i) = length(data(i).gpg.childs) > 1;
%     numobjs(i) = length(data(i).gpg.childs);
% end
%%
allrules = ITMrule(1);
allrules(:) = [];
all_composites = {};
all_didx = {};

% lets ignore..... way to expensive....
cand_data(numobjs > 5) = false;

rid = 100;
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

    for j = length(rules):-1:1
        composite = graphnodes(0);
        didx = [];
        tidx = find(cand_data);
        
        tic();
        cset = {};
        dset = {};
        parfor tt = 1:length(tidx)
            k = tidx(tt);
            temp = findITMCandidates(data(k).x, data(k).iclusters, params, rules(j), data(k).gpg.childs);
            cset{tt} = temp;
            dset{tt} = k .* ones(1, length(temp));
        end
        toc();
        
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
        
        if(length(composite) > 15)
            rule = reestimateITM(rules(j), composite);
            
            allrules(end+1) = rules(j);
            fprintf('filter : ');
            
            all_composites{end+1} = composite;
            all_didx{end+1} = didx;
            
            for k = 1:length(didx)
                did = didx(k);
                
                if(length(data(did).gpg.childs) == length(composite(k).chindices))
                    cand_data(did) = false;
                    fprintf('%d, ', did);
                end
            end
            fprintf('. Total %d rules discovered\n', length(allrules));
        else
            fprintf('.');
        end
    end    
    disp(['search ' num2str(idx) ' is done']);
end
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