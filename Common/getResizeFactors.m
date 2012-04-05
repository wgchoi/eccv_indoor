%%%% temporary!!!
function [factors, fnames] = getResizeFactors(imdir, imresized, exts)

cnt = 1;
factors = zeros(10000, 1);
fnames = cell(10000, 1);

for i = 1:length(exts)
    imfiles = dir(fullfile(imdir, ['*.' exts{i}]));
    
    for j = 1:length(imfiles)
        im = imread(fullfile(imdir, imfiles(j).name));
        idx = find(imfiles(j).name == '.', 1, 'last');
        
        fnames{cnt} = [imfiles(j).name(1:idx) 'jpg'];
        im2 = imread(fullfile(imresized, fnames{cnt}));
        factors(cnt) = size(im2, 1) / size(im, 1);
        
        cnt = cnt + 1;
    end
end

fnames(cnt:end) = [];
factors(cnt:end) = [];

end