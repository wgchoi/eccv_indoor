function info = MCMCproposal(graph, x, moves, cache, params)
info = mcmcmoveinfo(1);
rval = rand();
cum_pmove = cumsum(params.pmove);
assert(cum_pmove(end) == 1.0);

if(rval < cum_pmove(1)) % scene
    info.move = 1;
elseif(rval < cum_pmove(2)) % layout
    info.move = 2;
    info.idx = sum(cache.clayout < rand()) + 1;
elseif(rval < cum_pmove(3)) % camheight
    info.move = 3;
	info.dval = graph.camheight + randn() * params.camsigma;
elseif(rval < cum_pmove(4)) % add
    %%% too much waste of time... select among existing ones.
    idx = find(cache.inset == false);
    temp = cumsum(cache.padd(idx));
    i = sum(temp < rand() * temp(end)) + 1;
    info = moves{4}(idx(i));
    assert(~cache.inset(info.did));
elseif(rval < cum_pmove(5)) % delete
    idx = find(cache.inset);
    if(isempty(idx))
        info.move = 0;
        return;
    end
    temp = cumsum(1 ./ cache.padd(idx));
    i = sum(temp < rand() * temp(end)) + 1;
    info = moves{5}(idx(i));
    assert(cache.inset(info.sid));
elseif(rval < cum_pmove(6)) % switch
    idx = find(cache.inset);
    if(sum(cache.szswset(idx)) == 0)
        info.move = 0;
        return;
    end
    temp = cumsum(cache.szswset(idx));
    rval = randi(temp(end), 1);
    idx1 = sum(temp < rval) + 1;
    
    temp = [0; temp];
    idx2 = cache.swset{idx(idx1)}(rval - temp(idx1));
    info = moves{6}(idx2);
    
    assert(cache.inset(info.sid));
elseif(rval < cum_pmove(7)) % combine
    rval = randi(length(moves{7}), 1);
    info = moves{7}(rval);
else                        % break
    rval = randi(length(moves{8}), 1);
    info = moves{8}(rval);
end
    
end