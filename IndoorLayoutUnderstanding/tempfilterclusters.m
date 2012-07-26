function [patterns, labels] = tempfilterclusters(patterns, labels, params)

for i = 1:length(patterns)
    patterns(i) = filterDuplicateClusters(patterns(i));
    labels(i).lcpg = latentITMcompletion(labels(i).pg, patterns(i).x, patterns(i).iclusters, params);
end

end

function pattern = filterDuplicateClusters(pattern)
removeidx = [];
for i = 1:length(pattern.composite)
    c = pattern.composite(i);
    if(length(unique(c.chindices)) ~= length(c.chindices))
        removeidx(end+1) = i;
    end
end
pattern.composite(removeidx) = [];
pattern.iclusters = [pattern.isolated; pattern.composite];
% disp(['remove ' num2str(length(removeidx)) ' from data ' num2str(pattern.idx)]);
end