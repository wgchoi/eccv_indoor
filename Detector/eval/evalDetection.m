function [recall, fppi, pr] = evalDetection(gtboxes, dets, gtid, detid, thlist, maxperim)
if(nargin < 6)
	maxperim = 10000;
end

recall = nan(1, length(thlist));
fppi = nan(1, length(thlist));
pr = nan(1, length(thlist));

for t = 1:length(thlist)
    TP = zeros(1, length(gtboxes));
    FP = zeros(1, length(gtboxes));
    R = zeros(1, length(gtboxes));
    NP = zeros(1, length(gtboxes));
    
    th = thlist(t);
    for i = 1:length(gtboxes)
        gtbbs = gtboxes{i}.dets{gtid};

        idx = find_det(dets, gtboxes{i}.name);
        assert(length(idx) == 1);
        
        det = dets{idx}.dets{detid}(dets{idx}.tops{detid}, :);
%         det = dets{idx}.dets{detid};
        
        det = det(det(:, end) > th, :);
        rescale = dets{idx}.resizefactor;
        det(:, 1:4) = det(:, 1:4) ./ rescale;
        
		%%%
		[dummy, idx] = sort(det(:, 6), 'descend');
		if(length(idx) > maxperim)
			det(idx(maxperim+1:end), :) = [];
		end
		%%%%%%%
        [TP(i), R(i), FP(i), NP(i)] = oneimageeval(gtbbs, det);
    end
    
    recall(t) = sum(R) ./ sum(NP);
    fppi(t) = sum(FP) ./ length(gtboxes);
    pr(t) = sum(TP) ./ (sum(TP) + sum(FP));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TP count all true positives
% R count number of gt positive matched with a detection.
function [TP, R, FP, NP] = oneimageeval(gts, dets)

map = zeros(size(gts, 1), size(dets, 1));
for i = 1:size(gts, 1)
    for j = 1:size(dets, 1)
        map(i, j) = boxoverlap(gts(i, 1:4), dets(j, 1:4)) > 0.5;
    end
end

TP = sum(sum(map, 1) > 0);
FP = sum(sum(map, 1) == 0);

R = sum(sum(map, 2) > 0);
NP = size(gts, 1);

end

function idx = find_det(dets, name)
idx = [];
for i = 1:length(dets)
    if(strcmp(dets{i}.name, name))
        idx = i;
        return;
    end
end

end
