function annotate_one_dir( image_dir, anno_dir, annotator)

if ~exist(image_dir, 'dir')
    disp([image_dir ' does not exist!!!!']);
    return
end

if ~exist(anno_dir, 'dir')
    mkdir(anno_dir);
end

exts = {'jpg' 'JPEG' 'png'};


labelpostfix = '_labels.mat';
objtypes = {'Sofa', 'Table', 'TV', 'Chair', 'Bed'};

times = [];
for i = 1:length(exts)
    imfiles = dir(fullfile(image_dir, ['*.' exts{i}]));
    
    for j = 1:length(imfiles)
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
                continue; 
                
                for id = 1:length(objtypes)
                    if(id <= length(data.objs))
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
        else
            annotate_one_image( imfile, annofile, objtypes, annotator);
        end
        close;
        times(end+1) = toc
    end
end

end

