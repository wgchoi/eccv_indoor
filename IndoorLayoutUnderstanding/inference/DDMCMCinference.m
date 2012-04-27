% x :   1. scene type, [confidence value]
%       2. layout proposals, [poly, confidence value]
%       3. detections, [x, y, w, h, p, confidence]
%		4. R, T
%		5. image name

% y :   parse graph samples
function [spg, iclusters, x] = DDMCMCinference(x, iclusters, params, bshow)
count = 0;
spg = parsegraph(params.numsamples);

while(count < params.numsamples)
    count = count + 1;
	%% sample a new tree
	ar = 1.0;
	%% compute the acceptance ratio
	if(ar > rand())
	else
	end
end

end

function graph = initialize(graph, x, iclusters)

[~, graph.scenetype] = max(x.sconf);
[~, graph.layoutidx] = max(x.lconf);
for i = 1:length(iclusters)
    % if no conflict with existing clusters
    % if confidence is larger than 0
end

end
