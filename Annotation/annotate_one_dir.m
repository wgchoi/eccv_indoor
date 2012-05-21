function [list_annotated, times] = annotate_one_dir( image_dir, anno_dir, annotator, ignorelist)

if nargin < 4
    ignorelist = {};
end

if ~exist(image_dir, 'dir')
    disp([image_dir ' does not exist!!!!']);
    return
end

if ~exist(anno_dir, 'dir')
    mkdir(anno_dir);
end

exts = {'jpg' 'JPEG' 'png'};

labelpostfix = '_labels.mat';
objtypes = {'Sofa', 'Table', 'TV', 'Chair', 'Bed', 'Dining Table'};

times = [];

list_annotated = cell(0, 1);
if(length(ignorelist) > 0)
    list_annotated = ignorelist;
end

for i = 1:length(exts)
    imfiles = dir(fullfile(image_dir, ['*.' exts{i}]));
    
    for j = 1:length(imfiles)
        if(in_list(ignorelist, imfiles(j).name))
            disp([imfiles(j).name ' is ignored']);
            continue;
        end
        
        tic;
        imfile = fullfile(image_dir, imfiles(j).name);
        annofile = fullfile(anno_dir, [imfiles(j).name(1:end-4) labelpostfix]);
        
        if(exist(annofile, 'file'))
            %%%%
            data = load(annofile);
            if(isfield(data, 'gtPolyg'))
                gtPolyg = data.gtPolyg;
                ShowGTPolyg(imread(imfile), gtPolyg, 1);
                pause(1);
                close;
            else
                gtPolyg = annotate_layout(imfile);
            end
            %%%%
            if(isfield(data, 'objs'))
                for id = 1:length(objtypes)
                    if(id <= length(data.objs))
                        removeidx = [];
                        for k = 1:length(data.objs{id})
                            if(size(data.objs{id}(k).pose, 1) ~= 2 ||size(data.objs{id}(k).pose, 2) ~= 2)
                                removeidx(end+1) = k;
                            end
                        end
                        data.objs{id}(removeidx) = [];
                        
                        [objs{id}] = annotate_objects(imfile, id, objtypes{id}, data.objs{id});
                    else
                        [objs{id}] = annotate_objects(imfile, id, objtypes{id});
                    end
                end
            else
                for id = 1:length(objtypes)
                    [objs{id}] = annotate_objects(imfile, id, objtypes{id});
                end
            end
            
            %%%%
            save(annofile, 'gtPolyg', 'objs', 'annotator', 'objtypes');
            
            addpath ../IndoorLayoutUnderstanding/objmodel/
            annotate_obj_poses(imfile, annofile, objmodels());
            rmpath ../IndoorLayoutUnderstanding/objmodel/
        else
            annotate_one_image( imfile, annofile, objtypes, annotator);
        end
        close;
        times(end+1) = toc;
        disp(['Took ' num2str(times(end), '%.02f') ' seconds for annotating ' imfiles(j).name]);
        
        list_annotated{end + 1} = imfiles(j).name;
        
        keyin = input('Do you want to stop? [y/n]', 's');
        if(keyin == 'y')
            return;
        end
    end
end

end

function bin = in_list(list, filename)

bin = 0;
for i = 1:length(list)
    if(strcmp(list{i}, filename))
        bin = 1;
        return;
    end
end

end
