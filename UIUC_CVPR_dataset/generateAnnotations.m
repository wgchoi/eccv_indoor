addpath ../IndoorLayoutUnderstanding/objmodel/
addpath ../IndoorLayoutUnderstanding/common/

imdir = 'Images';
imfiles = dir(fullfile(imdir, '*.jpg'));

layoutdir = 'GTSpatiallayout/';
objdir = 'GT3dcuboids';
annodir = 'Annotations';

annos= struct('objtypes', [], 'gtPolyg', [], ...
                'objmodel', [], 'obj_annos', struct('im', [], 'objtype', 0, 'subid', 0, 'x1', 0, 'x2', 0, 'y1', 0, 'y2', 0, 'azimuth', 0, 'elevation', 0));

objtypes =  {'Sofa'  'Table'  'Chair'  'Bed' 'Dining Table' 'Side Table'};

temp = {};
for i = 1:length(imfiles)
    layoutfile = [imfiles(i).name(1:find(imfiles(i).name =='.', 1, 'last')-1) '_labels'];
    objfile = [imfiles(i).name(1:find(imfiles(i).name =='.', 1, 'last')-1) '_box'];
    annofile = layoutfile;
    
    annos.objtypes = objtypes;
    annos.gtPolyg = cell(1, 5);
    annos.objmodel = objmodels();
    annos.obj_annos(:) = [];

    try
        layout = load(fullfile(layoutdir, layoutfile));
    catch
        continue;
    end
    
    for j = 1:length(layout.gtPolyg)
        annos.gtPolyg{j} = layout.gtPolyg{j};
    end
    
    try
        objs = load(fullfile(objdir, objfile));
        for j = 1:length(objs.annotation)
            if(strcmp(objs.annotation(j).label, 'sofa'))
                type = 1;
                subtype = 1;
            elseif(strcmp(objs.annotation(j).label, 'table'))
                type = 2;
                subtype = 1;
            elseif(strcmp(objs.annotation(j).label, 'bed'))
                type = 4;
                subtype = 1;
            elseif(strcmp(objs.annotation(j).label, 'drawer'))
                type = 6;
                subtype = 1;
            elseif(strcmp(objs.annotation(j).label, 'chair'))
                type = 3;
                subtype = 1;
            elseif(strcmp(objs.annotation(j).label, 'sofa chair'))
                type = 1;
                subtype = 2;
            end
            
            bbox = [min(objs.annotation(j).fullbox(:, 1)), ...
                    min(objs.annotation(j).fullbox(:, 2)), ...
                    max(objs.annotation(j).fullbox(:, 1)), ...
                    max(objs.annotation(j).fullbox(:, 2))];
            
            obj = struct('im', fullfile(imdir, imfiles(i).name), ...
                        'objtype', type, ...
                        'subid', subtype, ...
                        'x1', min(objs.annotation(j).fullbox(:, 1)), ...
                        'x2', max(objs.annotation(j).fullbox(:, 1)), ...
                        'y1', min(objs.annotation(j).fullbox(:, 2)), ...
                        'y2', max(objs.annotation(j).fullbox(:, 2)), 'azimuth', 0, 'elevation', 0);
                    
            annos.obj_annos(end+1) = obj;
        end
    catch
        % continue;
    end
    
    save(fullfile(annodir, annofile), '-struct', 'annos');
end


%  'sofa' 'table' 'bed' 'drawer' 'chair'  'sofa chair' 
% 'Sofa', 'Table', 'Bed', 'Side Table', 'Chair', 'Sofa'