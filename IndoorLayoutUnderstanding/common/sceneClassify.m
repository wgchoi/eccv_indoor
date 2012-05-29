function [x] = sceneClassify(x)

curpath = pwd();
cd('../SPMclassifer_Johnny/');

imfile = x.imfile;
idx = find(imfile =='/', 1, 'last');
imfile = fullfile(fullfile(imfile(1:idx-1), 'resized'), imfile(idx+1:end));

[~, prob] = SingleImageSPM(imfile);
x.sconf = prob;

cd(curpath);

end