function [spg, maxidx, h, allclusters] = infer_top(x, iclusters, params, y)

h = [];
allclusters = [];
isolated = iclusters;

if(strncmp(params.model.feattype, 'itm_v', 5))
    composites = graphnodes(1);
    composites(:) = [];
    for j = 1:length(params.model.itmptns)
        % get valid candidates
        [temp, x] = findITMCandidates(x, isolated, params, params.model.itmptns(j));
        composites = [composites; temp;];
    end
    iclusters = [isolated; composites];
end
        
assert(length(iclusters) < 10000);

maxipg = y;
maxipg.lkhood = -inf;
maxpg = y;
maxpg.lkhood = -inf;

for i = 1:params.model.nscene
    pg = y;
    pg.scenetype = i;
    
    if(strcmp(params.inference, 'mcmc'))
        init.pg = pg;
        [spg, maxidx, ~, h] = DDMCMCinference(x, iclusters, params, init);
    elseif(strcmp(params.inference, 'greedy'))
        initpg = pg;
        [spg] = GreedyInference(x, iclusters, params, initpg);
        maxidx = 1;
    elseif(strcmp(params.inference, 'combined'))
        init.pg = pg;
        [init.pg] = GreedyInference(x, iclusters, params, init.pg);
        [spg, maxidx, ~, h] = DDMCMCinference(x, iclusters, params, init);
    else
        assert(0);
    end
    
    if(maxipg.lkhood < spg(1).lkhood)
        maxipg = spg(1);
    end
    
    if(maxpg.lkhood  < spg(maxidx).lkhood)
        maxpg = spg(maxidx);
    end
end

if(strncmp(params.model.feattype, 'itm_v', 5))
    pgi = maxipg;
    itmidx = find(pgi.childs > length(isolated));
    if(~isempty(itmidx))
        idx = pgi.childs(itmidx);

        allclusters = [isolated; iclusters(idx)];
        pgi.childs(itmidx) = length(isolated) + (1:length(idx));
    else
        allclusters = isolated;
    end
    
    pgmax = maxpg;
    itmidx = find(pgmax.childs > length(isolated));
    if(~isempty(itmidx))
        idx = pgmax.childs(itmidx);

        pgmax.childs(itmidx) = length(allclusters) + (1:length(idx));
        allclusters = [allclusters; iclusters(idx)];
    end
    
    spg = [pgi; pgmax];
    maxidx = 2;
else
    spg = [maxipg; maxpg]; 
    maxidx = 2;
    allclusters = isolated;
end
end
