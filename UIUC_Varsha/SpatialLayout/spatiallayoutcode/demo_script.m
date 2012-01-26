
% Add local code directories to Matlab path
addpaths;


% imdir='../Images_resized/'; % directory with original images

imdir = '../../../UIUC_data/Images/';

workspcdir='../tempworkspace/'; % directory to save intermediate results
if ~exist(workspcdir,'dir')
    mkdir(workspcdir);
end

resdir='../Results/'; % This is where we will save final results using this demo script.
if ~exist(resdir,'dir')
    mkdir(resdir);
end



% You can run it on a single image as follows
% imagename='indoor_0268.jpg';
% imagename='1-deer-valley-living-room6.jpg';
% [ boxlayout,surface_labels ] = getspatiallayout(imdir,imagename,workspcdir);
%%
% files = {'0000000041.jpg'}; % '2335_0.jpg' '487368900_e0b90a72fa_m.jpg' 'IMG_2339.jpg' 'IMG_4087.jpg' 'IMG_7743.jpg' 'IMG_9548.jpg'};
files = dir([imdir '*.jpg']);
for i = 1:length(files)
    [ boxlayout,surface_labels ] = getspatiallayout(imdir, files(i).name, workspcdir);
    close all;
end