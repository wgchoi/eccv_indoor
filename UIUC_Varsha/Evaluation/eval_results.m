clear;

show = false;

gtpath = '../../UIUC_data';
imgpath = '../../UIUC_data/Images/';
respath = '../SpatialLayout/tempworkspace/data/';

respostfix = '_layres.mat';
labelpostfix = '_labels.mat';

addpath('../SpatialLayout/spatiallayoutcode');
addpath('../SpatialLayout/spatiallayoutcode/Geometry');

files = dir(fullfile(imgpath, '*.jpg'));
pixerr = nan(length(files), 50);
% 0.01
pixerr_th = nan(length(files), 20);
thlist = 0.01 .* (0:19);
% pixerr10 = nan(1, length(files));
for i = 1:length(files)
    resfile = fullfile(respath, [files(i).name(1:end-4) respostfix]);
    
    if(exist(resfile))
        labelfile = fullfile(gtpath, [files(i).name(1:end-4) labelpostfix]);
        load(resfile);
        load(labelfile);
%         pixerr(i) = getPixerr(gtPolyg, polyg(lay_scores(1, 2), :));
%         minerr = pixerr(i);
        if show
            im = imread(fullfile(imgpath, files(i).name));
            tempimg=displayout(polyg(lay_scores(1, 2), :), size(im,2), size(im,1), im);
            imshow(uint8(tempimg));
            title(['error : ' num2str(minerr)])
            pause;
        end
        
        best_conf = lay_scores(1, 1);
        minerr = 1;
        for j = 1:min(50, size(lay_scores, 1))
            temp = getPixerr(gtPolyg, polyg(lay_scores(j, 2), :));
            if(temp < minerr)
                minerr = temp;
            end
            pixerr(i, j) = minerr;
            
            
            pixerr_th(i, thlist >= (best_conf - lay_scores(j, 1))) = minerr;
        end
    end
%     keyboard
end
% 
% mean(pixerr(~isnan(pixerr)))
% mean(pixerr10(~isnan(pixerr10)))
%%
hf = figure(1);
err_stat = zeros(1, 50);
for i = 1:50
    err_stat(i) = mean(pixerr(~isnan(pixerr(:, i)), i));
end
plot(err_stat, '.-');
xlabel('best among Top K');
ylabel('pixel error');
grid on;

% saveas(gcf, 'pixerr_K.png', 'PNG')
saveas(hf, 'pixerr_K.fig', 'fig')
print(hf, '-dpng', 'pixerr_K.png');

%%
hf = figure(2);
err_stat_th = zeros(1, length(thlist));
for i = 1:length(thlist)
    err_stat_th(i) = mean(pixerr_th(~isnan(pixerr_th(:, i)), i));
end
plot(thlist, err_stat_th, '.-');
xlabel('best within threshold');
ylabel('pixel error');
grid on;

% saveas(gcf, 'pixerr_threshold.png', 'PNG')
saveas(hf, 'pixerr_threshold.fig', 'fig')
print(hf, '-dpng', 'pixerr_threshold.png');

close all
