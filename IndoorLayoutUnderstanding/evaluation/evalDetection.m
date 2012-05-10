function [fppi, recall, pr] = evalDetection(imdir, annodir, exts, dets, gtids, detids, thlist, maxperim)
if(nargin < 8)
	maxperim = 10000;
end

addpath('../Detector/common');
addpath('../Detector/eval');

gts = readGTbboxes(imdir, annodir, exts);

assert(length(gtids) == length(detids));
%%
recall = zeros(length(gtids), length(thlist));
fppi = zeros(length(gtids), length(thlist));
pr = zeros(length(gtids), length(thlist));

for i = 1:length(gtids)
    [recall(i, :), fppi(i, :), pr(i, :)] = evalDetection(gts, dets, gtids(i), detids(i), thlist, maxperim);
end

rmpath('../Detector/common');
rmpath('../Detector/eval');

end
