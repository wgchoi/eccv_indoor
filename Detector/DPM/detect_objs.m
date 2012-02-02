function [bbox, top, dets, boxes, resizefactor] = detect_objs(imfile, models, threshold, maxwidth, resfile)
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
    save(resfile, 'dets', 'boxes', 'top', 'bbox', 'resizefactor');
end