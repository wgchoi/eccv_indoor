function [models, idx] = get_models()

idx = 1;
load('sofa_view8');
models{idx}  = model;

idx = idx + 1;
load('sofa_view24');
models{idx}  = model;

idx = idx + 1;
load('table_view8');
models{idx}  = model;

idx = idx + 1;
load('table_view24');
models{idx}  = model;

idx = idx + 1;
load('bed_view8');
models{idx}  = model;

idx = idx + 1;
load('bed_view24');
models{idx}  = model;

idx = idx + 1;
load('chair_view8');
models{idx}  = model;

idx = idx + 1;
load('chair_view24');
models{idx}  = model;

end