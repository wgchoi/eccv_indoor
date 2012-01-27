clear;
% Add local code directories to Matlab path
addpaths;
% imdir='../Images_resized/'; % directory with original images
% imdir = '../../../UIUC_data/Images/';
imdir = '~/eccv_layout/wongun_layout/Data_Collection/livingroom/';

workspcdir='~/eccv_layout/wongun_layout/Results/temp/layout/'; % '../tempworkspace/'; % directory to save intermediate results
if ~exist(workspcdir,'dir')
    mkdir(workspcdir);
end

resdir = '~/eccv_layout/wongun_layout/Results/layout/livingroom/'; % '../tempworkspace/'; % directory to save intermediate results
if ~exist(resdir,'dir')
    mkdir(resdir);
end
% You can run it on a single image as follows
% imagename='indoor_0268.jpg';
% imagename='1-deer-valley-living-room6.jpg';
% [ boxlayout,surface_labels ] = getspatiallayout(imdir,imagename,workspcdir);
% files = {'0000000041.jpg'}; % '2335_0.jpg' '487368900_e0b90a72fa_m.jpg' 'IMG_2339.jpg' 'IMG_4087.jpg' 'IMG_7743.jpg' 'IMG_9548.jpg'};

matlabpool open 8
%%
files = dir([imdir '*.jpg']);

fcnt = length(files);
boxlayout = cell(fcnt, 1);
surface_labels = cell(fcnt, 1);
resizefactor = cell(fcnt, 1);
fnames = cell(fcnt, 1);

parfor i = 1:length(files)
    [ boxlayout{i}, surface_labels{i}, resizefactor{i}] = getspatiallayout(imdir, files(i).name, workspcdir, 0);
    fnames{i} = fullfile(imdir, files(i).name);
%   close all;
% 	save(fullfile(resdir, files(i).name(1:end-4)), 'boxlayout', 'surface_labels', 'resizefactor');
end
save(fullfile(resdir, 'res_set1.mat'), 'boxlayout', 'surface_labels', 'resizefactor', 'fnames');
%%
files = dir([imdir '*.JPEG']);

fcnt = length(files);
boxlayout = cell(fcnt, 1);
surface_labels = cell(fcnt, 1);
resizefactor = cell(fcnt, 1);
fnames = cell(fcnt, 1);

parfor i = 1:length(files)
    [ boxlayout{i}, surface_labels{i}, resizefactor{i}] = getspatiallayout(imdir, files(i).name, workspcdir, 0);
    fnames{i} = fullfile(imdir, files(i).name);
%     close all;
% 	save(fullfile(resdir, files(i).name(1:end-5)), 'boxlayout', 'surface_labels', 'resizefactor');
end
save(fullfile(resdir, 'res_set2.mat'), 'boxlayout', 'surface_labels', 'resizefactor', 'fnames');

matlabpool close