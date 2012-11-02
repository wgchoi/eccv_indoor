function [] = train_dpm_for_itms(trainset, name, allimlists)
curpwd = pwd();
cache_dir = fullfile(curpwd, 'cache/dpm/');
if ~exist(cache_dir, 'dir')
    mkdir(cache_dir);
end

cd ../Detector/dpm_detector/
% model = pascal_train(cls, n, note)
% Train a model with 2*n components using the PASCAL dataset.
% note allows you to save a note with the trained model
% example: note = 'testing FRHOG (FRobnicated HOG)
% At every "checkpoint" in the training process we reset the 
% RNG's seed to a fixed value so that experimental results are 
% reproducible.
initrand();

note = '';

globals; 
[pos, neg, spos, index_pose] = itm_data(trainset, name, cache_dir, allimlists);
% globals; 
if(isempty(index_pose))
    cd(curpwd);
    return;
end

cachesize = 10*numel(pos);
maxneg = min(1500, numel(pos));

% train root filters using warped positives & random negatives
try
  load([cache_dir '/' name '_root']);
catch
  initrand();
  for i = 1:numel(index_pose)
    % split data into two groups: left vs. right facing instances
    models{i} = initmodel(name, spos{i}, note, 'N');
    models{i} = train(name, models{i}, spos{i}, neg(1:maxneg), i, 1, ...
						1, ... % iter
						5, ... % negiter
                      cachesize, true, 0.7, false, ['root_' num2str(i)]);
  end
  save([cache_dir '/' name '_root'], 'models', 'index_pose');
end

% merge models and train using hard negatives
try 
  load([cache_dir '/' name '_mix']);
catch
  initrand();
  model = mergemodels(models);
  model = train(name, model, pos, neg(1:maxneg), 0, 0, ...
                1, ...
                5, ...
                cachesize, true, 0.7, false, 'mix');
            
  model = train(name, model, pos, neg, 0, 0, ...
                1, ...
                5, ...
                cachesize, true, 0.7, true, 'mix_2');
            
  save([cache_dir '/' name '_mix'], 'model', 'index_pose');
end
% % add parts and update models using hard negatives.
% try 
%   load([cache_dir cls '_parts']);
% catch
%   initrand();
%   for i = 1:numel(index_pose)
%     model = model_addparts(model, model.start, i, i, 8, [6 6]);
%   end
%   model = train(cls, model, pos, neg(1:maxneg), 0, 0, ...
%                 5, ...
%                 5, ...
%                 cachesize, true, 0.7, false, 'parts_1');
%   model = train(cls, model, pos, neg, 0, 0, ...
%                 1, ...
%                 5, ...
%                 cachesize, true, 0.7, true, 'parts_2');
%   save([cache_dir cls '_parts'], 'model');
% end
% 
% model.view_num = n;
% model.index_pose = index_pose;
% save([cache_dir cls '_final'], 'model');
% 
% 
% keyboard;

cd(curpwd);

end


function [pos, neg, spos, index_pose] = itm_data(set, name, cache_dir, allimlist)
% Get training data from the PASCAL dataset.
globals;
VOC2006 = false;
pascal_init;

try
  load([cache_dir '/' name '_train_pos_set']);
catch
  % positive examples from train+val
  pos = parse_data(set.pos);
  
  views = unique(set.pos.clusters);
  
  spos = cell(length(views), 1);
  index_pose = cell(length(views), 1);
  
  for v = 1:length(views);
      spos{v} = pos(views(v) == set.pos.clusters);
      index_pose{v} = set.pos.viewset{views(v)};
  end
  
  remove_idx = [];
  for v = 1:length(views);
      if(length(spos{v}) < 20)
          remove_idx(end+1) = v;
      end
  end
  spos(remove_idx) = [];
  index_pose(remove_idx) = [];
  
  save([cache_dir '/' name '_train_pos_set'], 'pos', 'spos', 'index_pose');
end

try
  load([cache_dir '/' name '_train_neg_set']);
catch
  % negative examples from train (this seems enough!)
  neg = [];
  numneg = 0;
  
  removelist = [];
  for i = 1:length(set.pos.itm_examples)
      [bin, idx] = inlist(allimlist, set.pos.itm_examples(i).imfile);
      if bin
          removelist(end+1) = idx;
      end
  end
  
  removelist = unique(removelist);
  allimlist(removelist) = [];
  
  for i = 1:length(allimlist)
      numneg = numneg+1;
      neg(numneg).im = allimlist{i};
      neg(numneg).flip = false;
  end
  
  ids = textread(sprintf(VOCopts.imgsetpath, 'train'), '%s');
  for i = 1:length(ids);
    if(mod(i, 50) == 0)
        fprintf('%s: parsing negatives: %d/%d\n', name, i, length(ids));
    end
    rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
    
    % be careful about person...
    clsinds = strmatch('person', {rec.objects(:).class}, 'exact');
    if isempty(clsinds)
      numneg = numneg+1;
      neg(numneg).im = [VOCopts.datadir rec.imgname];
      neg(numneg).flip = false;
    end
  end
  save([cache_dir '/' name '_train_neg_set'], 'neg');
end

end


% read positive training images
function pos = parse_data(set)
itm_examples = set.itm_examples;
if isfield(set, 'clusters')
    clusters = set.clusters;
else
    clusters = zeros(1, length(itm_examples));
end

assert(length(itm_examples) == length(clusters));

N = numel(itm_examples);
pos = struct('im', cell(N, 1), 'x1', 0, 'y1', 0, 'x2', 0, 'y2', 0, 'flip', 0, ...
            'trunc', 0, 'azimuth', 0, 'clusterid', 0, 'subid', 0);
        
for i = 1:N
    pos(i).im = itm_examples(i).imfile;
    pos(i).x1 = itm_examples(i).bbox(1);
    pos(i).y1 = itm_examples(i).bbox(2);
    pos(i).x2 = itm_examples(i).bbox(3);
    pos(i).y2 = itm_examples(i).bbox(4);
    pos(i).flip = itm_examples(i).flip;
    pos(i).trunc = 0;
    pos(i).azimuth = itm_examples(i).azimuth;
    pos(i).clusterid = clusters(i);
    pos(i).subid = 1;
end

end
% 
% function [pos, neg] = itm_data(itm_examples, name, cache_dir, allimlist)
% % Get training data from the PASCAL dataset.
% 
% globals;
% VOC2006 = false;
% pascal_init;
% 
% try
%   load([cache_dir '/' name '_train_pos_set']);
% catch
%   % positive examples from train+val
%   pos = parse_positives(itm_examples);
%   
%   save([cache_dir '/' name '_train_pos_set'], 'pos');
% end
% 
% try
%   load([cache_dir '/' name '_train_neg_set']);
% catch
%   % negative examples from train (this seems enough!)
%   neg = [];
%   numneg = 0;
%   
%   removelist = [];
%   for i = 1:length(itm_examples)
%       [bin, idx] = inlist(allimlist, itm_examples(i).imfile);
%       if bin
%           removelist(end+1) = idx;
%       end
%   end
%   
%   removelist = unique(removelist);
%   allimlist(removelist) = [];
%   
%   for i = 1:length(allimlist)
%       numneg = numneg+1;
%       neg(numneg).im = allimlist{i};
%       neg(numneg).flip = false;
%   end
%   
%   ids = textread(sprintf(VOCopts.imgsetpath, 'train'), '%s');
%   for i = 1:length(ids);
%     if(mod(i, 50) == 0)
%         fprintf('%s: parsing negatives: %d/%d\n', name, i, length(ids));
%     end
%     rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
%     
%     % be careful about person...
%     clsinds = strmatch('person', {rec.objects(:).class}, 'exact');
%     if isempty(clsinds)
%       numneg = numneg+1;
%       neg(numneg).im = [VOCopts.datadir rec.imgname];
%       neg(numneg).flip = false;
%     end
%   end
%   save([cache_dir '/' name '_train_neg_set'], 'neg');
% end
% 
% end
% 
% % read positive training images
% function pos = parse_positives(itm_examples)
% N = numel(itm_examples);
% pos = struct('im', {}, 'x1', {}, 'y1', {}, 'x2', {}, 'y2', {}, 'flip', {}, 'trunc', {}, 'azimuth', {}, 'mirrored', {}, 'subid', {});
% count = 0;
% for i = 1:N
%     count = count + 1;
%     pos(count).im = itm_examples(i).imfile;
%     pos(count).x1 = itm_examples(i).bbox(1);
%     pos(count).y1 = itm_examples(i).bbox(2);
%     pos(count).x2 = itm_examples(i).bbox(3);
%     pos(count).y2 = itm_examples(i).bbox(4);
%     pos(count).flip = false;
%     pos(count).trunc = 0;
%     pos(count).azimuth = itm_examples(i).azimuth;
%     pos(count).mirrored = false;
%     pos(count).subid = 1;
%     
%     continue;
%     % not working!!!!
%     
%     %%% mirrored example
%     count = count + 1;
%     pos(count).im = itm_examples(i).imfile;
%     pos(count).x1 = itm_examples(i).bbox(1);
%     pos(count).y1 = itm_examples(i).bbox(2);
%     pos(count).x2 = itm_examples(i).bbox(3);
%     pos(count).y2 = itm_examples(i).bbox(4);
%     pos(count).flip = false;
%     pos(count).trunc = 0;
%     pos(count).azimuth = 2 * pi - itm_examples(i).azimuth;
%     %%% wongun added
%     pos(count).mirrored = true;
%     pos(count).subid = 1;
%     %%% wongun added %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end
% end

% 
% % split positive training samples according to viewpoints
% function [spos, index_pose, removeidx] = view_split(pos, n)
% N = numel(pos);
% view = zeros(N, 1);
% for i = 1:N
%     az = pos(i).azimuth / pi * 180;
%     view(i) = find_interval(az, n);
% end
% 
% spos = cell(n, 1);
% index_pose = [];
% 
% removeidx = [];
% maxperview = 150;
% for i = 1:n
%     idx = i;
%     sets = find(view == i);
%     
%     if(length(sets) > maxperview)
%         temp = randperm(length(sets));
%         spos{idx} = pos(sets(temp(1:maxperview)));
%         removeidx = [removeidx; sets(temp(maxperview+1:end))];
%     else
%         spos{idx} = pos(sets);
%     end
%     
%     if numel(spos{idx}) >= 10
%         index_pose = [index_pose idx];
%     end
% end
% 
% end

function [in, idx] = inlist(list, string)
idx = -1;
for i = 1:length(list)
    if(strcmp(list{i}, string))
        in = true;
        idx = i;
        return
    end
end
in = false;
end