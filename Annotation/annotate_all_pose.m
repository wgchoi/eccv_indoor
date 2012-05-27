% clear
% 
% imdir = '../Data_Collection/bedroom/';
% annodir = './bedroom/';
% exts = {'jpg' 'JPEG'};
% 
% for i = 1:length(exts)
%     imfiles = dir(fullfile(imdir, ['*.' exts{i}]));
%     
%     for j = 1:length(imfiles)
%         imfile = fullfile(imdir, imfiles(j).name);
%         
%         idx = find(imfiles(j).name == '.', 1, 'last');
%         annofile = fullfile(annodir, [imfiles(j).name(1:idx-1) '_labels.mat']);
%         
%         if(~exist(annofile, 'file'))
%             disp([annofile ' doesnot exist']);
%             continue;
%         end
%         try
%             annotate_obj_poses(imfile, annofile, objmodels());
%         catch e
%             e
%         end
%     end
% end
% %%
% clear
% 
% addpath ../IndoorLayoutUnderstanding/objmodel/
% 
% imdir = '../Data_Collection/bedroom/';
% annodir = './bedroom/';
% imfiles = dir(fullfile(imdir, '*.jpg'));
% 
% for j = 1:length(imfiles)
%     imfile = fullfile(imdir, imfiles(j).name);
%     idx = find(imfiles(j).name == '.', 1, 'last');
%     annofile = fullfile(annodir, [imfiles(j).name(1:idx-1) '_labels.mat']);
%     if(~exist(annofile, 'file'))
%         disp([annofile ' doesnot exist']);
%         continue;
%     end
%     try
%         correct_obj_labels(imdir, imfiles(j).name, annofile, objmodels());
%     catch e
%         e
%     end
% end

%%
clear

addpath ../IndoorLayoutUnderstanding/objmodel/

imdir = '../Data_Collection/bedroom/';
annodir = './bedroom/';
imfiles = dir(fullfile(imdir, '*.jpg'));

om = objmodels();

for j = 1:length(imfiles)
    imfile = fullfile(imdir, imfiles(j).name);
    idx = find(imfiles(j).name == '.', 1, 'last');
    annofile = fullfile(annodir, [imfiles(j).name(1:idx-1) '_labels.mat']);
    
    if(~exist(annofile, 'file'))
        disp([annofile ' doesnot exist']);
        continue;
    end
    
    try
        objs = struct('id', cell(1, 0), 'pose', cell(1, 0), 'poly', cell(1, 0), 'bbs', cell(1, 0));
        objs(:) = [];
        
        draw_annotation(imfile, annofile);
        key = input('need addition of side table? (y/n)', 's');
        if(key == 'y')
            idx = 7; % side table
            objs = annotate_objects(imfile, idx, om(idx).name, objs);
            if(~isempty(objs))
                anno = load(annofile);

                anno.objs{idx} = objs;
                anno.objmodel = om;
                anno.poses{idx} = annotate_object_poses(imfile, objs, idx, om);
                for k = 1:length(om)
                    anno.objtypes{k} = om(k).name;
                end
                save(annofile, '-struct', 'anno');
            end
        end
        correct_obj_labels(imdir, imfiles(j).name, annofile, objmodels());
    catch e
        e
    end
end