function [spg, maxidx] = infer_top(x, iclusters, params, y)

if(strcmp(params.inference, 'mcmc'))
    init.pg = y;
    [spg, maxidx] = DDMCMCinference(x, iclusters, params, init);
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

end