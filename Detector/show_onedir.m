function show_onedir(imdir, resdir, names, exts, th)

if ~exist(imdir, 'dir')
    return;
end

if ~exist(resdir, 'dir')
    return;
end

cols = 'rgbcmkywrgbcmkywrgbcmkywrgbcmkywrgbcmkywrgbcmkyw';
poses = {cell(100, 1)};
for i = 1:length(poses{1})
    poses{1}{i} = num2str(i);
end

for i = 1:length(exts)
    files = dir(fullfile(imdir, ['*.' exts{i}]));
    for j = 1:length(files)
        idx = find(files(j).name == '.', 1, 'last');
        res = load(fullfile(resdir, files(j).name(1:idx-1)));
        
        dets = res.dets;
        for k = 1:length(dets)
            dets{k}(:, 1:4) = dets{k}(:, 1:4) ./ res.resizefactor;
        end
        
        draw_detections(imread(fullfile(imdir, files(j).name)), ...
                        dets, res.top, th, names, poses, cols)
        pause;
    end
%     parfor j = 1:length(files)
%         imfile = fullfile(imdir, files(j).name);
%         idx = find(files(j).name == '.', 1, 'last');
% 		disp(['process ' files(j).name]);
%         detect_objs(imfile, models, names, threshold, 640, fullfile(resdir, files(j).name(1:idx-1)));
%     end
end


end
