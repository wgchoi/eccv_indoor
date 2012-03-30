function [poses] = annotate_object_poses(imfile, objs, objid, objmodel)

img = imread(imfile);
% initial
elevation = pi / 12;
figure(2);
num = length(objs);
for j = 1:num
    bbox = floor(objs(j).bbs);
    bbox(3:4) = bbox(1:2) + bbox(3:4) - 1;
    window = uint8(subarray(img, bbox(2), bbox(4), bbox(1), bbox(3), 1));

    window = imresize(window, 200 / size(window, 2));
    
    pose.subid = 1; pose.az = 0; pose.el = elevation;
    poses(j) = annotate_one_obj_pose(window, objmodel, objid, pose);
    elevation = poses(j).el;
end
close all;
end