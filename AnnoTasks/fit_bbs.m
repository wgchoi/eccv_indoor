function fit_bbs(anno_file)
data = load(anno_file, 'objs');
if(isfield(data, 'objs'))
    objs = data.objs;
    for id = 1:length(objs)
        for i = 1:length(objs{id})
            poly = objs{id}(i).poly;
            
            objs{id}(i).bbs = [min(poly(:, 1)), min(poly(:, 2)), ...
                    max(poly(:, 1)) - min(poly(:, 1)) + 1, ...
                    max(poly(:, 2)) - min(poly(:, 2)) + 1];
        end
    end
    
    save(anno_file, '-append', 'objs');
end
end