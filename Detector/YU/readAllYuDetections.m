function detout = readAllYuDetections(resizeddir, resdir, names)
detout = cell(1000, 1);
if ~exist(resdir, 'dir')
    return;
end

cnt = 1;
load(fullfile(resdir, 'filenames.mat'));
for i = 1:length(names)
    [ dets{i} ] = readYuDeteion(fullfile(resdir, [names{i} '.pre']), length(filenames));
end
factor = load(fullfile(resizeddir, 'resize_factors.mat'));

for i = 1:length(filenames)
%     idx = find(filenames{i} == '.', 1, 'last');
%     
    for j = 1:length(names)
        det = dets{j}{i};
        res.dets{j} = det(:, [3:6 1:2]);
        res.top{j} = 1:size(res.dets{j}, 1);
    end
    
    detout{cnt}.name = filenames{i};
    detout{cnt}.dets = res.dets;
    detout{cnt}.tops = res.top;
    detout{cnt}.resizefactor = findResizeFactor(factor.fnames, factor.factors, filenames{i});

    assert(~isnan(detout{cnt}.resizefactor));
    
    cnt = cnt + 1;
end
detout(cnt:end) = [];

end
