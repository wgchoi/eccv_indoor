% x :   1. scene type, [confidence value]
%       2. layout proposals, [poly, confidence value]
%       3. detections, [x, y, w, h, p, confidence]
%		4. R, T
%		5. image name
% y :   parse graph samples
function [spg, cache, history] = DDMCMCinference(x, iclusters, params, init)
params.model.w = getweights(params.model);
%% prepare buffer
spg = parsegraph(params.numsamples);
count = 1;
%% initialize the sample
if nargin < 4
    [spg(count), cache] = initialize(spg(1), x, iclusters, params.model);
else
    spg(count) = init.pg;
    cache = init.cache;
end
%% initialize cache
[moves, cache] = preprocessJumpMoves(x, iclusters, cache);
%%
history = zeros(8, 2);
%% weighting the acceptance constant
if(isfield(params, 'accconst'))
    accconst = params.accconst;
else
    accconst = 10.0;
end

while(count < params.numsamples)
    %% sample a new tree
    info = MCMCproposal(spg(count), x, moves, cache, params);
    if(info.move == 0), continue; end % error in sample
	%% compute the acceptance ratio
	[lar, newgraph] = computeAcceptanceRatio(spg(count), info, cache, x, iclusters, params.model);
    %% accept or reject
    count = count + 1;	
	if(lar * accconst > log(rand()))
        spg(count) = newgraph;
        history(info.move, 1) = history(info.move, 1) + 1;
        % update cache
        cache = updateCache(cache, info);
    else
        spg(count) = spg(count - 1);
        history(info.move, 2) = history(info.move, 2) + 1;
	end
end

end

function cache = updateCache(cache, info)
switch(info.move)
    case 4 % add
        cache.inset(info.did) = true;
    case 5 % delete
        cache.inset(info.sid) = false;
    case 6 % switch
        cache.inset(info.sid) = false;
        cache.inset(info.did) = true;
end
end

function [graph, cache] = initialize(graph, x, iclusters, model)
[~, graph.scenetype] = max(x.sconf);
[~, graph.layoutidx] = max(x.lconf);

cache = mcmccache(length(iclusters), length(x.lconf));
obts = [];
for i = 1:length(iclusters)
    assert(iclusters(i).isterminal);
    % if no conflict with existing clusters
    % if confidence is larger than 0
    lk = [x.dets(iclusters(i).chindices, 8), 1] * model.w_oo;
    lk = lk + [sum(x.intvol(i, cache.inset)), sum(x.orarea(i, cache.inset))] * model.w_ioo;
    if(lk > 0)
        graph.childs(end+1) = i;
        cache.inset(i) = true;
        obts = [obts, min(x.cubes{i}(2, :))];
    end
end
graph.camheight = -mean(obts);

phi = features(graph, x, iclusters, model);
graph.lkhood = dot(phi, model.w);
%% init cache
cache.playout = exp(x.lconf);
cache.playout = cache.playout ./ sum(cache.playout);
cache.clayout = cumsum(cache.playout);

cache.padd = exp(x.dets(:, end));
end
