function [pos, neg] = pose_data(cls)

% [pos, neg] = pascal_data(cls)
% Get training data from the PASCAL dataset.

globals;
VOC2006 = false;
pascal_init;

switch cls
    case {'car'}
        index_train = 1:240;
    case {'bicycle'}
        index_train = 1:360;
    case {'chair'}
        index_train = 1:770;
    case {'bed'};
        index_train = 1:400;
    case {'sofa'}
        index_train = 1:800;
    case {'table'}
        index_train = 1:670;        
end

try
  load([cachedir cls '_train_pose']);
catch
    
  % positive examples from train+val
  fprintf('Read 3DObject samples\n');
  pos = read_positive(cls, index_train);

  % negative examples from train (this seems enough!)
  ids = textread(sprintf(VOCopts.imgsetpath, 'train'), '%s');
  neg = [];
  numneg = 0;
  for i = 1:length(ids);
    fprintf('%s: parsing negatives: %d/%d\n', cls, i, length(ids));
    rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
    clsinds = strmatch(cls, {rec.objects(:).class}, 'exact');
    if isempty(clsinds)
      numneg = numneg+1;
      neg(numneg).im = [VOCopts.datadir rec.imgname];
      neg(numneg).flip = false;
    end
  end
  
  save([cachedir cls '_train_pose'], 'pos', 'neg');
end

% read positive training images
function pos = read_positive(cls, index_train)

N = numel(index_train);
path_image = sprintf('../Images/%s', cls);
path_anno = sprintf('../Annotations/%s', cls);

count = 0;
for i = 1:N
    index = index_train(i);
    file_ann = sprintf('%s/%04d.mat', path_anno, index);
    image = load(file_ann);
    object = image.object;
    if isfield(object, 'view') == 0
        continue;
    end
    bbox = object.bbox;
    n = size(bbox, 1);
    if n ~= 1
        fprintf('Training image %d contains multiple instances.\n', i);
    end
    view = object.view;
    file_img = sprintf('%s/%s', path_image, object.image);
    for j = 1:n
        if view(j,1) == -1
            continue;
        end
        count = count + 1;
        pos(count).im = file_img;
        pos(count).x1 = bbox(j,1);
        pos(count).y1 = bbox(j,2);
        pos(count).x2 = bbox(j,1)+bbox(j,3);
        pos(count).y2 = bbox(j,2)+bbox(j,4);
        pos(count).flip = false;
        pos(count).trunc = 0;
        pos(count).azimuth = view(j,1);
    end
end