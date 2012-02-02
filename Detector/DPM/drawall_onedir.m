function drawall_onedir(imdir, resdir, outdir, exts, th, names, poses, cols)
if ~exist(imdir, 'dir')
    return;
end
if ~exist(resdir, 'dir')
    return;
end
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

for i = 1:length(exts)
    files = dir(fullfile(imdir, ['*.' exts{i}]));
	for j = 1:length(files)
		im = imread(fullfile(imdir, files(j).name));

        idx = find(files(j).name == '.', 1, 'last');
		res = load(fullfile(resdir, files(j).name(1:idx-1)), 'top', 'dets');

		draw_detections(im, res.dets, res.top, th, names, poses, 'rrggbbmmcckkyy');
		drawnow;

		print('-djpeg', fullfile(outdir, [files(j).name(1:idx-1) '.jpg']));
	end
end

end
