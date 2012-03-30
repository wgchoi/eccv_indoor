function form_object_dataset(objname, annobase, targetbase)
annodir = fullfile(annobase, objname);
annofiles = dir(fullfile(annodir, '*.mat'));
out_imdir = fullfile(targetbase, 'images');
out_annodir = fullfile(fullfile(targetbase, 'annotation'), objname);
if ~exist(out_imdir, 'dir')
	mkdir(out_imdir);
end
if ~exist(out_annodir, 'dir')
	mkdir(out_annodir);
end
for i = 1:length(annofiles)
	annofile = fullfile(annodir, annofiles(i).name);
	destfile = fullfile(out_annodir, annofiles(i).name);
	load(annofile);

	imfilename = anno.im;
	anno.im = imfilename(find(imfilename == '/', 1, 'last') + 1:end);

	if(~exist(fullfile(out_imdir, anno.im), 'file'))
		copyfile(imfilename, fullfile(out_imdir, anno.im));
	end
	save(destfile, 'anno');
end

end
