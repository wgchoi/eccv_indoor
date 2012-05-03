function [lar, newgraph ] = computeAcceptanceRatio(graph, info, cache, x, iclusters, params)
newgraph = graph;
lkratio = 0.0;
qratio = 0.0;

switch(info.move)
    case 1 % scene
        newgraph.scenetype = info.idx;
        % compute the features
        phi = features(newgraph, x, iclusters, params.model);
        newgraph.lkhood = dot(phi, params.model.w);
        lkratio = newgraph.lkhood - graph.lkhood;
        % balanced already, no proposal adjust required
        % lar = lar + 0.0;
    case 2 % layout index
        newgraph.layoutidx = info.idx;
        % compute the features
        phi = features(newgraph, x, iclusters, params.model);
        newgraph.lkhood = dot(phi, params.model.w);
        lkratio = newgraph.lkhood - graph.lkhood;
        % proposal
        qratio = log(cache.playout(graph.layoutidx)) - log(cache.playout(info.idx));
    case 3 % camera height
        newgraph.camheight = info.dval;
        % compute the features
        phi = features(newgraph, x, iclusters, params.model);
        newgraph.lkhood = dot(phi, params.model.w);
        lkratio = newgraph.lkhood - graph.lkhood;
        % balanced already, no proposal adjust required
        % lar = lar + 0.0;
    case 4 % add
        idx = find(graph.childs == info.did, 1);
        if(isempty(idx)) 
            newgraph.childs(end + 1) = info.did;
            phi = features(newgraph, x, iclusters, params.model);
            newgraph.lkhood = dot(phi, params.model.w);
            lkratio = newgraph.lkhood - graph.lkhood;
            
            p1 = cache.padd(info.did) / sum(cache.padd(~cache.inset));
            p2 = 1 / cache.padd(info.did) / ( sum(1 ./ cache.padd(cache.inset)) + 1 / cache.padd(info.did) );
            qratio = (log(params.pmove(5) * p2)) - (log(params.pmove(4) * p1));
        else % cannot add already existing cluster
            assert(0);
        end
    case 5 % delete
        idx = find(graph.childs == info.sid, 1);
        if(isempty(idx)) % cannot delete not existing cluster
            assert(0);
        else
            newgraph.childs(idx) = [];
            phi = features(newgraph, x, iclusters, params.model);
            newgraph.lkhood = dot(phi, params.model.w);
            lkratio = newgraph.lkhood - graph.lkhood;
            
            p1 = 1 / cache.padd(info.sid) / sum(1 ./ cache.padd(cache.inset));
            p2 = cache.padd(info.sid) / (sum(cache.padd(~cache.inset)) + cache.padd(info.sid));
            qratio = log(params.pmove(4) * p2) - log(params.pmove(5) * p1);
        end
    case 6 % switch
        idx = find(graph.childs == info.sid, 1);
        if(isempty(idx)) % cannot switch not existing cluster
            assert(0);
        else
            newgraph.childs(idx) = info.did;
            phi = features(newgraph, x, iclusters, params.model);
            newgraph.lkhood = dot(phi, params.model.w);
            lkratio = newgraph.lkhood - graph.lkhood;
            
            p11 = 1 / cache.padd(info.sid) / sum(1 ./ cache.padd(cache.inset));
            id2 = cache.swset{info.sid};
            id2 = id2(~cache.inset(id2)); % consider non-existing only
            p12 = cache.padd(info.did) / sum(cache.padd(id2));
            
            tinset = cache.inset;
            tinset(info.sid) = false;
            tinset(info.did) = true;
            p21 = 1 / cache.padd(info.did) / sum(1 ./ cache.padd(tinset));
            id2 = cache.swset{info.did};
            id2 = id2(~tinset(id2)); % consider non-existing only
            p22 = cache.padd(info.sid) / sum(cache.padd(id2));
            qratio = log((p21*p22) / (p11*p12));
        end
    case 7 % combine
    case 8 % break
    otherwise
        assert(0, ['not defined mcmc move = ' num2str(info.move)]);
end
lar = params.accconst * lkratio + qratio;
if isnan(lar)
    lar = -inf;
end
end