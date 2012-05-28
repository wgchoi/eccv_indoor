function [patterns, labels, hit] = latent_completion(patterns, labels, params, updateITM, VERBOSE)

model = params.model;

if(VERBOSE > 0)
    fprintf('starting latent completion [%d] ... ', length(patterns)); tic();
end

parfor i = 1:length(patterns)
    if(updateITM)
        composites = graphnodes(1);
        composites(:) = [];

        x = patterns(i).x;
        isolated = patterns(i).isolated;

        for j = 1:length(model.itmptns)
            % get valid candidates
            [temp, x] = findITMCandidates(x, isolated, params, model.itmptns(j));
            % get random candidates as negative sets!
            [randset] = findRandomITMCandidates(x, isolated, params, model.itmptns(j), 30);
            composites = [composites; temp; randset];
        end
        patterns(i).composite = composites;
        patterns(i).iclusters = [patterns(i).isolated; patterns(i).composite];
    end
    
    labels(i).lcpg = latentITMcompletion(labels(i).pg, patterns(i).x, patterns(i).iclusters, params);
    if(VERBOSE > 1)
        disp(['pattern ' num2str(i) ' processed'])
    end
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
