addPaths

load('/home/wgchoi/codes/eccv_indoor/IndoorLayoutUnderstanding/cache/dpm/itm029_mix.mat');
%%
dataset = 'livingroom';
imdir = fullfile('/home/wgchoi/codes/eccv_indoor/Data_Collection/', dataset);
resdir = fullfile('./itm_temp/', dataset);
files = dir(fullfile(imdir, '*.jpg'));
%%
if ~exist(resdir, 'dir')
    mkdir(resdir);
end
process_onedir(imdir, resdir, {model}, {'itm029_sst'}, {'jpg'});
%%
th1 = -0.5;
th2 = -0.8;
th3 = -1.0;

for i = 1:length(files)
    load(fullfile(resdir, files(i).name(1:end-4)));
    bbox = bbox{1};
    top = top{1};
    im=imread(fullfile(imdir, files(i).name));
    im = imresize(im, resizefactor);
    imshow(im);
    for j = 1:length(top)
        bb = bbox(top(j), :);
        if(bb(end) > th1)
            rectangle('position', [bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2)], 'edgecolor', 'r', 'linewidth', 3, 'linestyle', '-');
        elseif(bb(end) > th2)
            rectangle('position', [bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2)], 'edgecolor', 'm', 'linewidth', 2, 'linestyle', '--');
        elseif(bb(end) > th3)
            rectangle('position', [bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2)], 'edgecolor', 'g', 'linewidth', 1, 'linestyle', '--');
        end
    end
    print('-djpeg', fullfile(resdir, files(i).name));
end
%%
scores = [];
for i = 1:length(files)
    load(fullfile(resdir, files(i).name(1:end-4)));
    bbox = bbox{1};
    top = top{1};
    scores = [scores; bbox(top, end)];
end