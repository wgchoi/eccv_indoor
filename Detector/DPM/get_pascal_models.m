function [models, names, poses, idx] = get_pascal_models()

basedir = './voc-release4.01/VOC2009/';
pose24 = {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' ...
		 '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24'};
  
idx = 1;
load(fullfile(basedir, 'sofa_final'));
models{idx}  = model;
names{idx} = 'sofa';
poses{idx} = pose24;

idx = idx + 1;
load(fullfile(basedir, 'tvmonitor_final'));
models{idx}  = model;
names{idx} = 'TV';
poses{idx} = pose24;

idx = idx + 1;
load(fullfile(basedir, 'chair_final'));
models{idx}  = model;
names{idx} = 'chair';
poses{idx} = pose24;

idx = idx + 1;
load(fullfile(basedir, 'diningtable_final'));
models{idx}  = model;
names{idx} = 'diningtable';
poses{idx} = pose24;

end