function preprocess_detector(imdir, resdir, exts)

if nargin < 3
    exts = {'jpg'};
end

if(~exist(resdir, 'dir'))
    mkdir(resdir);
end

addpath ./3rdParty/dpm_detector

load ./model/dpm/sofa_final.mat
detect_onedir( imdir, ...
                fullfile(resdir, 'sofa/'), ...
                {model}, {'sofa'}, exts, -1.2);

load ./model/dpm/table_final.mat
detect_onedir( imdir, ...
                fullfile(resdir, 'table/'), ...
                {model}, {'table'}, exts, -1.2)
            
load ./model/dpm/chair_final.mat
detect_onedir( imdir, ...
                fullfile(resdir, 'chair/'), ...
                {model}, {'chair'}, exts, -1.2)
            
load ./model/dpm/bed_final.mat
detect_onedir( imdir, ...
                fullfile(resdir, 'bed/'), ...
                {model}, {'bed'}, exts, -1.2)
            
load ./model/dpm/diningtable_final.mat
detect_onedir( imdir, ...
                fullfile(resdir, 'diningtable/'), ...
                {model}, {'diningtable'}, exts, -1.2)
            
load ./model/dpm/sidetable_final.mat
detect_onedir( imdir, ...
                fullfile(resdir, 'sidetable/'), ...
                {model}, {'sidetable'}, exts, -1.2)
            
end

function detect_onedir(imdir, resdir, models, names, exts, threshold)

if ~exist(imdir, 'dir')
    return;
end

if ~exist(resdir, 'dir')
    mkdir(resdir);
end

matlabpool open 4
for i = 1:length(exts)
    files = dir(fullfile(imdir, ['*.' exts{i}]));
    parfor j = 1:length(files)
        imfile = fullfile(imdir, files(j).name);
        idx = find(files(j).name == '.', 1, 'last');
		disp(['process ' files(j).name]);
        detect_objs(imfile, models, names, threshold, 640, fullfile(resdir, files(j).name(1:idx-1)));
    end
end
matlabpool close;

end

function [bbox, top, dets, boxes, resizefactor] = detect_objs(imfile, models, names, threshold, maxwidth, resfile)
if nargin < 3
    threshold = -0.3;
    resfile = [];
elseif nargin < 4
    resfile = [];
end

% we assume color images
im = imread(imfile);
resizefactor = 1;
if(size(im, 2) > maxwidth)
    resizefactor = maxwidth  / size(im, 2);
    im = imresize(im, resizefactor);
end
im = color(im);
% get the feature pyramid
% NOTE : assuming all the same feature pyramid
pyra = featpyramid(im, models{1});

bbox = cell(length(models), 1);
top = cell(length(models), 1);
dets = cell(length(models), 1);
boxes = cell(length(models), 1);

for i = 1:length(models)
    [dets{i}, boxes{i}, info] = gdetect(pyra, models{i}, threshold, [], 0);
    
    top{i} = nms(dets{i}, 0.5);
    % get bounding boxes
    if(isfield(models{i}, 'bboxpred'))
        bbox{i} = bboxpred_get(models{i}.bboxpred, dets{i}, reduceboxes(models{i}, boxes{i}));
    else
        bbox{i} = dets{i};
    end
    bbox{i} = clipboxes(im, bbox{i});
    top{i} = nms(bbox{i}, 0.5);
end

if(~isempty(resfile))
    save(resfile, 'names', 'dets', 'boxes', 'top', 'bbox', 'resizefactor');
end

end