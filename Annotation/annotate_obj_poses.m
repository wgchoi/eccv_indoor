function [poses] = annotate_obj_poses(imfile, anno_file, objmodel)

img = imread(imfile);

figure(1);
imshow(img);

load(anno_file, 'objs');
try
    load(anno_file, 'poses');
catch
    poses = cell(1, length(objs));
end

% initial
elevation = pi / 12;
figure(2);
for i = 1:length(objs)
    num = length(objs{i});
    for j = 1:num
        bbox = floor(objs{i}(j).bbs);
        bbox(3:4) = bbox(1:2) + bbox(3:4) - 1;
        window = uint8(subarray(img, bbox(2), bbox(4), bbox(1), bbox(3), 1));
        
        window = imresize(window, 200 / size(window, 2));
        try
            pose = poses{i}(j);
        catch
            pose.subid = 1; pose.az = 0; pose.el = pi / 12;
        end
        poses{i}(j) = annotate_one_obj_pose(window, objmodel, i, pose);
        elevation = poses{i}(j).el;
    end
end

save(anno_file, '-append', 'poses', 'objmodel');
close all;
end