function [patterns, labels, hit] = latent_completion(patterns, labels, params, VERBOSE)

model = params.model;

if(VERBOSE > 0)
    fprintf('starting latent completion [%d] ... ', length(patterns)); tic();
end

parfor i = 1:length(patterns)
    composites = graphnodes(1);
    composites(:) = [];
    
    x = patterns(i).x;
    isolated = patterns(i).isolated;
    
    for j = 1:length(model.itmptns)
        [temp, x] = findITMCandidates(x, isolated, params, model.itmptns(j));
        composites = [composites; temp];
    end
%     patterns(i).x = x;
    patterns(i).composite = composites;
    patterns(i).iclusters = [patterns(i).isolated; patterns(i).composite];
    labels(i).lcpg = latentITMcompletion(labels(i).pg, patterns(i).x, patterns(i).iclusters, params);
end

if nargout >= 2
    hit = zeros(1, length(model.itmptns));
    for i = 1:length(labels)
        for j = 1:length(labels(i).lcpg.childs)
            idx = labels(i).lcpg.childs(j);
            if(~patterns(i).iclusters(idx).isterminal)
                idx = patterns(i).iclusters(idx).ittype - model.nobjs;
                hit(idx) = hit(idx) + 1;
            end
        end
    end
end

if(VERBOSE > 0)
    fprintf(' done! '); toc();
end

end
