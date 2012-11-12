function process_detector_v5(imdir, resdir, exts)
if nargin < 3
    exts = {'jpg'};
end
startup
cd ./voc-release5/;
load ./VOC2010/sofa_final.mat
process_onedir( imdir, ...
                fullfile(resdir, 'sofa/'), ...
                model, 'sofa', exts);
            
load ./VOC2010/chair_final.mat
process_onedir( imdir, ...
                fullfile(resdir, 'chair/'), ...
                model, 'chair', exts)
            
           
load ./VOC2010/diningtable_final.mat
process_onedir( imdir, ...
                fullfile(resdir, 'diningtable/'), ...
                model, 'diningtable', exts)

cd ..;
% [ds, bs] = process(im, model, thresh);
end

function process_onedir(imdir, resdir, model, name, exts)
if ~exist(imdir, 'dir')
    return;
end

if ~exist(resdir, 'dir')
    mkdir(resdir);
end

threshold = -1.5;
% try
%     matlabpool open 4
% end

for i = 1:length(exts)
    files = dir(fullfile(imdir, ['*.' exts{i}]));
    % par
    for j = 1:length(files)
        imfile = fullfile(imdir, files(j).name);
		disp(['process ' files(j).name]);
        
        [ds, bs] = process(imread(imfile), model, threshold);
        [~, fname] = fileparts(imfile);
        
        save(fullfile(resdir, fname), 'name', 'ds', 'bs', 'imfile');
    end    
end

% matlabpool close;

end
