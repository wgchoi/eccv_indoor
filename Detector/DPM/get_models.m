function [models, names, poses, idx] = get_models()

pose8 = {'f' 'fr' 'r' 'br' 'b' 'bl' 'l' 'fl'};
pose24 = {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' ...
		 '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24'};
     
basedir = 'YuModel';

idx = 1;
load(fullfile(basedir, 'sofa_view8'));
models{idx}  = model;
names{idx} = 'sofa8';
poses{idx} = pose8;

idx = idx + 1;
load(fullfile(basedir, 'sofa_view24'));
models{idx}  = model;
names{idx} = 'sofa24';
poses{idx} = pose24;

idx = idx + 1;
load(fullfile(basedir, 'table_view8'));
models{idx}  = model;
names{idx} = 'table8';
poses{idx} = pose8;

idx = idx + 1;
load(fullfile(basedir, 'table_view24'));
models{idx}  = model;
names{idx} = 'table24';
poses{idx} = pose24;

idx = idx + 1;
load(fullfile(basedir, 'bed_view8'));
models{idx}  = model;
names{idx} = 'bed8';
poses{idx} = pose8;

idx = idx + 1;
load(fullfile(basedir, 'bed_view24'));
models{idx}  = model;
names{idx} = 'bed24';
poses{idx} = pose24;

idx = idx + 1;
load(fullfile(basedir, 'chair_view8'));
models{idx}  = model;
names{idx} = 'chair8';
poses{idx} = pose8;

idx = idx + 1;
load(fullfile(basedir, 'chair_view24'));
models{idx}  = model;
names{idx} = 'chair24';
poses{idx} = pose24;

end