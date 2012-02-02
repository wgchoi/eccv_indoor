function [bbox, top, dets, boxes] = detect_voc(im, model, threshold, show)
if nargin < 3
    threshold = -0.3;
    show = 0;
elseif nargin < 4
    show = 0;
end

cls = model.class;
% load and display image
% im = imread(name);

if(show)
	clf;
	image(im);
	axis equal; 
	axis on;
	disp('input image');
	disp('press any key to continue'); pause;
	disp('continuing...');

	% load and display model
	visualizemodel(model, 1:2:length(model.rules{model.start}));
	disp([cls ' model visualization']);
	disp('press any key to continue'); pause;
	disp('continuing...');
end

% detect objects
[dets, boxes] = imgdetect(im, model,threshold);
top = nms(dets, 0.5);
if(show)
	clf;
	showboxes(im, reduceboxes(model, boxes(top,:)));
	disp('detections');
	disp('press any key to continue'); pause;
	disp('continuing...');
end

% get bounding boxes
if(isfield(model, 'bboxpred'))
    bbox = bboxpred_get(model.bboxpred, dets, reduceboxes(model, boxes));
else
    bbox = dets;
end
bbox = clipboxes(im, bbox);
top = nms(bbox, 0.5);
if(show)
	clf;
	showboxes(im, bbox(top,:));
	disp('bounding boxes');
	disp('press any key to continue'); pause;
end
