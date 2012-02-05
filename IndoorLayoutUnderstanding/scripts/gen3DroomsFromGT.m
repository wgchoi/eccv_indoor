clear
close all;

addPaths();
addVarshaPaths();

set = 'livingroom';
img_dir= fullfile('../Data_Collection', set);
gt_dir = fullfile('../Annotation', set);
outdir = fullfile('./data/rooms', set);

if(~exist(outdir, 'dir'))
    mkdir(outdir);
end

exts = {'jpg' 'JPEG'};
for e = 1:length(exts)
	imfiles = dir(fullfile(img_dir, ['*.' exts{e}]));
	for i = 1:length(imfiles)
		fname = getfname(imfiles(i).name);
		img = imread(fullfile(img_dir, imfiles(i).name));
		try
			load(fullfile(gt_dir, [fname '_labels.mat']));
			[room, objs] = gen3DRoomFromGT(img, gtPolyg, objs);
			save(fullfile(outdir, fname), 'room', 'objs', 'gtPolyg');
		catch
		end
	end
end
