function process_detector(imdir, resdir, exts)
if nargin < 3
    exts = {'jpg'};
end
addPaths;

load ./Models/dpm_mine/sofa_final.mat
% load ./Models/only_human/sofa_final.mat
process_onedir( imdir, ...
                fullfile(resdir, 'sofa/'), ...
                {model}, {'sofa'}, exts, -1.2);
% return;

load ./Models/dpm_mine/table_final.mat
% load ./Models/dpm_mine_mix/table_mix.mat
process_onedir( imdir, ...
                fullfile(resdir, 'table/'), ...
                {model}, {'table'}, exts, -1.2)
            
load ./Models/dpm_mine/chair_final.mat
% load ./Models/dpm_mine_mix/chair_mix.mat
process_onedir( imdir, ...
                fullfile(resdir, 'chair/'), ...
                {model}, {'chair'}, exts, -1.2)
            
% load ./Models/dpm_mine/bed_final.mat
% process_onedir( imdir, ...
%                 fullfile(resdir, 'bed/'), ...
%                 {model}, {'bed'}, exts)
            
load ./Models/dpm_mine/diningtable_final.mat
% load ./Models/dpm_mine_mix/diningtable_mix.mat
process_onedir( imdir, ...
                fullfile(resdir, 'diningtable/'), ...
                {model}, {'diningtable'}, exts, -1.2)
            
% load ./Models/dpm_mine/sidetable_final.mat
% process_onedir( imdir, ...
%                 fullfile(resdir, 'sidetable/'), ...
%                 {model}, {'sidetable'}, exts)
            
end