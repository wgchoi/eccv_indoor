clear

imdir = '../Data_Collection/livingroom/';
annodir = './livingroom/';
exts = {'jpg' 'JPEG'};

for i = 1:length(exts)
    imfiles = dir(fullfile(imdir, ['*.' exts{i}]));
    
    for j = 1:length(imfiles)
        imfile = fullfile(imdir, imfiles(j).name);
        
        idx = find(imfiles(j).name == '.', 1, 'last');
        annofile = fullfile(annodir, [imfiles(j).name(1:idx-1) '_labels.mat']);
        
        if(~exist(annofile, 'file'))
            disp([annofile ' doesnot exist']);
            continue;
        end
        try
            annotate_obj_poses(imfile, annofile, objmodels());
        catch e
            e
        end
    end
end
%%
clear

addpath ../IndoorLayoutUnderstanding/objmodel/

imdir = '../Data_Collection/livingroom/';
annodir = './livingroom/';
imfiles = dir(fullfile(imdir, '*.jpg'));

for j = 1:length(imfiles)
    imfile = fullfile(imdir, imfiles(j).name);
    idx = find(imfiles(j).name == '.', 1, 'last');
    annofile = fullfile(annodir, [imfiles(j).name(1:idx-1) '_labels.mat']);
    if(~exist(annofile, 'file'))
        disp([annofile ' doesnot exist']);
        continue;
    end
    try
        correct_obj_labels(imdir, imfiles(j).name, annofile, objmodels());
    catch e
        e
    end
end