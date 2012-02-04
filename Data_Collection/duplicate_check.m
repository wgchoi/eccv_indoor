function [dist] = duplicate_check( imdir, exts )
%DUPLICATE_CHECK Summary of this function goes here
%   Detailed explanation goes here
for i = 1:length(exts)
    if exist('imall', 'var')
        imfiles = dir(fullfile(imdir, ['*.' exts{i}]));
        imall = [imall, imfiles];
    else
        imall = dir(fullfile(imdir, ['*.' exts{i}]));
    end
end

images = cell(length(imall), 1);
for i = 1:length(imall)
    im = imread(fullfile(imdir, imall(i).name));
    im = rgb2gray(imresize(im, [100 100]));
    images{i} = im;
end

dist = zeros(length(images), length(images));
duplicate_list = [];
for i = 1:length(images)
    for j = i+1:length(images)
        dist(i, j) = norm(double(images{i}) - double(images{j}));
%         if(dist(i, j) == 0)
%             duplicate_list(end+1, :) = [i, j];
%         end
    end
end

[a, b] = find(dist < 3000);
idx = find(a < b);

for i = 1:length(idx)
    subplot(211); imshow(fullfile(imdir, imall(a(idx(i))).name))
    try
        subplot(212); imshow(fullfile(imdir, imall(b(idx(i))).name))
    catch
        subplot(212); imshow(zeros(200, 200));
    end
    key = input('erase one file? [y/n]', 's');
    if(key == 'y')
        delete(fullfile(imdir, imall(b(idx(i))).name))
    end
end

end

