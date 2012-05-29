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

if(strcmp(params.inference, 'mcmc'))
    init.pg = y;
    [spg, maxidx, ~, h] = DDMCMCinference(x, iclusters, params, init);
elseif(strcmp(params.inference, 'greedy'))
    initpg = y;
    [spg] = GreedyInference(x, iclusters, params, initpg);
    maxidx = 1;
elseif(strcmp(params.inference, 'combined'))
    init.pg = y;
    [init.pg] = GreedyInference(x, iclusters, params, init.pg);
    [spg, maxidx, ~, h] = DDMCMCinference(x, iclusters, params, init);
else
    assert(0);
end

if(strncmp(params.model.feattype, 'itm_v', 5))
    pgi = spg(1);
    itmidx = find(pgi.childs > length(isolated));
    if(~isempty(itmidx))
        idx = pgi.childs(itmidx);

        allclusters = [isolated; iclusters(idx)];
        pgi.childs(itmidx) = length(isolated) + (1:length(idx));
    else
        allclusters = isolated;
    end
    
    pgmax = spg(maxidx);
    itmidx = find(pgmax.childs > length(isolated));
    if(~isempty(itmidx))
        idx = pgmax.childs(itmidx);

        pgmax.childs(itmidx) = length(allclusters) + (1:length(idx));
        allclusters = [allclusters; iclusters(idx)];
    end
    
    spg = [pgi; pgmax];
    maxidx = 2;
else
    allclusters = isolated;
end
end
