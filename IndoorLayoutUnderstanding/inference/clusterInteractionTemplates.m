% x :   1. scene type, [confidence value]
%       2. layout proposals, [poly, confidence value]
%       3. detections, [obj type, subtype, pose, x, y, w, h, confidence]
%       4. aux : R, K camera projections, imfile

% model :   1. w : model weights
%           2. rules : interaction templates
function [iclusters] = clusterInteractionTemplates(x, model)
% loop for direct object instantiation (isolated interaction templates)
ndets = size(x.dets, 1);

isolated = graphnodes(1000);
numclusters = 0;
for i = 1:ndets
    % convert projection
    dets = x.dets(i, :); % otype, subtype, pose, x, y, w, h, c
    
    numclusters = numclusters + 1;
    %
    isolated(numclusters).isterminal = true;
    %
    isolated(numclusters).ittype = dets(1);             % isloated interaction template, objecttype == template type
    isolated(numclusters).angle = x.locs(i, 4);
    isolated(numclusters).loc = x.locs(i, 1:3);
    
    isolated(numclusters).chindices = i;               % detection index
end
isolated(numclusters+1:end) = [];

% loop for compositional interaction templates.
composite = graphnodes(0);
numclusters = 0;
for i = 1:length(model.itmptns)
    continue;    
    assert(0, 'not ready');
    temp = findCompositionalTemplates(isolated, model.rules(i));
    composite = [composite; temp];
end
iclusters = [isolated; composite];

end