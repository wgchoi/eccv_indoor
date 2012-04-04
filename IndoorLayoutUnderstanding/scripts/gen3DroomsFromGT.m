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

%% i = 8 error!!!
exts = {'jpg'};
for e = 1:length(exts)
	imfiles = dir(fullfile(img_dir, ['*.' exts{e}]));
	for i = 1:length(imfiles)
		fname = getfname(imfiles(i).name);
		img = imread(fullfile(img_dir, imfiles(i).name));
		try
			load(fullfile(gt_dir, [fname '_labels.mat']));
            polyout = checkLayoutAnnotation(gtPolyg, img);
			[room, objs] = gen3DRoomFromGT(img, polyout, objs, poses);
%             [a, b, c] = dcm2angle(room.R, 'XYZ')
			save(fullfile(outdir, fname), 'room', 'objs', 'gtPolyg');
%             drawAll(img, polyout, room, objs(1:3), objmodels(), 1, 2);
%             pause;
        catch ee
            i
            ee
		end
	end
end
