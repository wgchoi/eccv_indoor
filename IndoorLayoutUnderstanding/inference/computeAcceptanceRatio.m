function [lar, newgraph ] = computeAcceptanceRatio(graph, info, cache, x, iclusters, model)
newgraph = graph;
lar = 0.0;

switch(info.move)
    case 1 % scene
        newgraph.scenetype = info.idx;
        % compute the features
        phi = features(newgraph, x, iclusters, model);
        newgraph.lkhood = dot(phi, model.w);
        lar = newgraph.lkhood - graph.lkhood;
        % balanced already, no proposal adjust required
    case 2 % layout index
        newgraph.layoutidx = info.idx;
        % compute the features
        phi = features(newgraph, x, iclusters, model);
        newgraph.lkhood = dot(phi, model.w);
        lar = newgraph.lkhood - graph.lkhood;
        % balanced already, no proposal adjust required
        lar = lar + 0.0;
    case 3 % camera height
        newgraph.camheight = info.dval;
        % compute the features
        phi = features(newgraph, x, iclusters, model);
        newgraph.lkhood = dot(phi, model.w);
        lar = newgraph.lkhood - graph.lkhood;
        % balanced already, no proposal adjust required
        lar = lar + 0.0;
    case 4 % add
        idx = find(graph.childs == info.did, 1);
        if(isempty(idx)) 
            newgraph.childs(end + 1) = info.did;
            phi = features(newgraph, x, iclusters, model);
            newgraph.lkhood = dot(phi, model.w);
            lar = newgraph.lkhood - graph.lkhood;
            
            lar = lar + 0.0;
        else % cannot add already existing cluster
            lar = -inf;
            assert(0);
        end
    case 5 % delete
        idx = find(graph.childs == info.sid, 1);
        if(isempty(idx)) % cannot delete not existing cluster
            lar = -inf;
            assert(0);
        else
            newgraph.childs(idx) = [];
            phi = features(newgraph, x, iclusters, model);
            newgraph.lkhood = dot(phi, model.w);
            lar = newgraph.lkhood - graph.lkhood;
            
            lar = lar + 0.0;
        end
    case 6 % switch
        idx = find(graph.childs == info.sid, 1);
        if(isempty(idx)) % cannot switch not existing cluster
            lar = -inf;
            assert(0);
        else
            newgraph.childs(idx) = info.did;
            phi = features(newgraph, x, iclusters, model);
            newgraph.lkhood = dot(phi, model.w);
            lar = newgraph.lkhood - graph.lkhood;
            
            lar = lar + 0.0;
        end
    case 7 % combine
    case 8 % break
    otherwise
        assert(0, ['not defined mcmc move = ' num2str(info.move)]);
end

if isnan(lar)
%     disp(['nan detected!!']);
    lar = -inf;
end

end