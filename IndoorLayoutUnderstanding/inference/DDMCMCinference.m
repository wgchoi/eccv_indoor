function [spg, maxidx, cache, history] = DDMCMCinference(x, iclusters, params, init, anno)
% x :   1. scene type, [confidence value]
%       2. layout proposals, [poly, confidence value]
%       3. detections, [x, y, w, h, p, confidence]
%		4. R, T
%		5. image name
% y :   parse graph samples

if nargin < 5
    includeloss = false;
    anno = [];
else
    includeloss = true;
end
%% consider upto 50 layouts
x.lconf(51:end) = [];
x.lpolys(51:end, :) = [];
x.faces(51:end) = [];
%%
params.model.w = getweights(params.model);
%% prepare buffer
spg = parsegraph(params.numsamples);
count = 1;
%% initialize the sample
if (nargin < 4) || (isempty(init))
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
if(~isfield(params, 'accconst'))
    params.accconst = 1.0;
end

maxidx = 1;
maxval = spg(1).lkhood;
if(includeloss)
    spg(1).loss = lossall(anno, x, spg(1));
    maxval = maxval + spg(1).loss;
end

while(count < params.numsamples)
    %% sample a new tree
    info = MCMCproposal(spg(count), x, moves, cache, params);
    if(info.move == 0), continue; end % error in sample
	%% compute the acceptance ratio
	[lkhood, newgraph] = computeAcceptanceRatio(spg(count), info, cache, x, iclusters, params);
    lar = lkhood;
    %% loss value
    if(includeloss)
        newgraph.loss = lossall(anno, x, newgraph);
        lar = lar + params.accconst * (newgraph.loss - spg(count).loss);
    end
    %% accept or reject
    count = count + 1;
	if(lar > log(rand()))
        spg(count) = newgraph;
        history(info.move, 1) = history(info.move, 1) + 1;
        % update cache
        cache = updateCache(cache, info);
        
        % assertion check
        assert(isempty(setdiff(find(cache.inset), spg(count).childs)));
        assert(length(union(find(cache.inset), spg(count).childs)) == length(spg(count).childs));
    else
        spg(count) = spg(count - 1);
        history(info.move, 2) = history(info.move, 2) + 1;
    end
    % show2DGraph(spg(count), x, iclusters);
    % drawnow;
    % pause(0.2);
    if(includeloss)
        if(spg(count).lkhood + spg(count).loss > maxval)
            maxval = spg(count).lkhood + spg(count).loss;
            maxidx = count;
        end
    else
        if(spg(count).lkhood > maxval)
            maxval = spg(count).lkhood;
            maxidx = count;
        end
    end
end

if(~includeloss)
    disp(['max sample at ' num2str(maxidx) ' with lk : ' num2str(maxval)])
    spg(maxidx)
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
    if(isnan(iclusters(i).angle))
        continue;
    end
    % if no conflict with existing clusters
    % if confidence is larger than 0
    oid = x.dets(iclusters(i).chindices, 1);
    
    lk = [x.dets(iclusters(i).chindices, 8), 1] * model.w_oo((oid-1)*2+1:(2*oid));
    lk = lk + [sum(x.intvol(i, cache.inset)), sum(x.orarea(i, cache.inset))] * model.w_ioo;
    if(lk > 0)
        graph.childs(end+1) = i;
        cache.inset(i) = true;
        obts = [obts, min(x.cubes{i}(2, :))];
    end
end
if(~isempty(obts))
    graph.camheight = -mean(obts);
else
    graph.camheight  = 1.0;
end

phi = features(graph, x, iclusters, model);
graph.lkhood = dot(phi, model.w);
%% init cache
cache.playout = exp(x.lconf .* model.w_or);
cache.playout = cache.playout ./ sum(cache.playout);
cache.clayout = cumsum(cache.playout);

cache.padd = exp(x.dets(:, end) .* model.w_oo(1));
end
