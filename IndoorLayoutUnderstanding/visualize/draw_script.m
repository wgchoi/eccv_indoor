clear
close all;

ind = 3;
img_dir= '/home/wgchoi/Codes/eccv_indoor/Data_Collection/livingroom/';
gt_dir = '/home/wgchoi/Codes/eccv_indoor/Annotation/livingroom/';
datadir= '../UIUC_Varsha/SpatialLayout/tempworkspace/data/';

imfiles = dir(fullfile(img_dir, '*.jpg'));

img = imread(fullfile(img_dir, imfiles(ind).name));

load(fullfile(datadir, [imfiles(ind).name(1:end-4) '_layres.mat']));
load(fullfile(datadir, [imfiles(ind).name(1:end-4) '_vp.mat']));
load(fullfile(gt_dir, [imfiles(ind).name(1:end-4) '_labels.mat']));

ShowGTPolyg(img, gtPolyg, 10);
[K, R, F] = get3Dcube(img, vp, gtPolyg);

objmodel = objmodels();
drawCube(F, gtPolyg, K, R, objs, objmodel,1);
