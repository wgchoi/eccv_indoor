function process_onedir(imdir, resdir, models, exts)
if ~exist(imdir, 'dir')
    return;
end

if ~exist(resdir, 'dir')
    mkdir(resdir);
end

threshold = -2;

matlabpool open 8
for i = 1:length(exts)
    files = dir(fullfile(imdir, ['*.' exts{i}]));
    parfor j = 1:length(files)
        imfile = fullfile(imdir, files(j).name);
        
        idx = find(files(j).name == '.', 1, 'last');
        
        detect_objs(imfile, models, threshold, 640, fullfile(resdir, files(j).name(1:idx-1)));
    end
end
matlabpool close;

end