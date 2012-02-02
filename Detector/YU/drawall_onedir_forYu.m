function drawall_onedir_forYu(imdir, resdir, outdir, th, names, poses)
if ~exist(imdir, 'dir')
    return;
end
if ~exist(resdir, 'dir')
    return;
end
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

load(fullfile(resdir, 'filenames.mat'));
for i = 1:length(names)
    [ dets{i} ] = readYuDeteion(['./results/YuMethod/livingroom/' names{i} '.pre'], length(filenames));
end

for i = 1:length(filenames)
    im = imread(fullfile(imdir, filenames{i}));
    idx = find(filenames{i} == '.', 1, 'last');
%     res = load(fullfile(resdir, files(j).name(1:idx-1)), 'top', 'dets');

    for j = 1:length(names)
        det = dets{j}{i};
        
        res.dets{j} = det(:, [3:6 1:2]);
        res.top{j} = 1:size(res.dets{j}, 1);
    end
    draw_detections(im, res.dets, res.top, th, names, poses, 'rgbmcky');
    drawnow;
    print('-djpeg', fullfile(outdir, [filenames{i}(1:idx-1) '.jpg']));
%     pause;
end

end
