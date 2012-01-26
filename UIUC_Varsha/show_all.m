clear

addpath ./SpatialLayout/spatiallayoutcode/Visualize/
imdir = '../UIUC_data/Images';
gtdir = '../UIUC_data';

labelpostfix = '_labels.mat';
imfiles = dir(fullfile(imdir, '*.jpg'));
% gtfiles = dir(fullfile(gtdir, '*.mat'));
% assert(length(imfiles) == length(gtfiles));
for i = 1:length(imfiles)
    img = imread(fullfile(imdir, imfiles(i).name));
    
    load(fullfile(gtdir, [imfiles(i).name(1:end-4) labelpostfix]));
    ShowGTPolyg(img, gtPolyg, 1);
    
    col = {'r','g','b','k','w'};
    for j = 1:length(gtPolyg)
        hold on;
        poly = gtPolyg{j};
        if(isempty(poly))
            continue;
        end
        scatter(poly(:, 1), poly(:, 2), col{j}, '*');
        hold off;
    end
    
    pause;
end