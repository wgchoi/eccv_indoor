function rets = readGTbboxes(imdir, annodir, exts)
rets = cell(1000, 1);

if ~exist(imdir, 'dir')
    return;
end
if ~exist(annodir, 'dir')
    return;
end

postfix = '_labels.mat';
cnt = 1;
for i = 1:length(exts)
    files = dir(fullfile(imdir, ['*.' exts{i}]));
	for j = 1:length(files)
        idx = find(files(j).name == '.', 1, 'last');
        
        annofile = fullfile(annodir, [files(j).name(1:idx-1) postfix]);
        if(~exist(annofile, 'file'))
            disp([annofile ' does not exist']);
            continue;
        end
        
		anno = load(annofile, 'objs');      
        if(~isfield(anno, 'objs'))
            disp([annofile ' does not exist']);
            continue;
        end
        
        rets{cnt}.name = files(j).name;
        for k = 1:length(anno.objs)
            rets{cnt}.dets{k} = objs2dets(anno.objs{k});
            rets{cnt}.tops{k} = 1:size(rets{cnt}.dets{k}, 1);
        end
        rets{cnt}.resizefactor = 1;
        
        cnt = cnt + 1;
	end
end
rets(cnt:end) = [];

end

function dets = objs2dets(objs)

dets = zeros(length(objs), 6);
for i = 1:length(objs)
    dets(i, 1:4) = objs(i).bbs;
    
    dets(i, 3:4) = dets(i, 3:4) + dets(i, 1:2) - 1;
    
    dets(i, 5) = 1; % objs(i).pose;
    dets(i, 6) = inf;
end

end

