function [recall, fppi, pr] = evalOneDetector(imdir, resdir, annodir, thlist, gtids, detids, dname, names)
%%
% 1. sofa, 2. sofa, 3. table, 4. table, 5. bed, 6. bed, 7. chair, 8. chair
if(strcmp(dname, 'DPM'))
    dets = readAllDPMDetections(imdir, resdir, {'jpg' 'JPEG'});
elseif(strcmp(dname, 'YU'))
    dets = readAllYuDetections(imdir,resdir, names);
%     dets = readAllDPMDetections(imdir, resdir, {'jpg'});
else
end
gts = readGTbboxes(imdir, annodir, {'jpg' 'JPEG'});

assert(length(gtids) == length(detids));
%%
recall = zeros(length(gtids), length(thlist));
fppi = zeros(length(gtids), length(thlist));
pr = zeros(length(gtids), length(thlist));

matlabpool open 4
parfor i = 1:length(gtids)
    [recall(i, :), fppi(i, :), pr(i, :)] = evalDetection(gts, dets, gtids(i), detids(i), thlist);
end
matlabpool close
