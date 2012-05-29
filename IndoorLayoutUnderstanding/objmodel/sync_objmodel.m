function out = sync_objmodel(anno)
om = objmodels();

out = anno;
out.objmodel = om;
out.objtypes = {};
out.objs = {};
out.poses = {};
out.obj_annos(:) = [];

for i = 1:length(anno.objtypes)
    idx = -1;
    for j = 1:length(om)
        if(strcmp(anno.objtypes{i}, om(j).name))
            idx = j;
            break;
        end
    end
    
    if(idx > 0)
        out.objtypes{idx} = anno.objtypes{i};
        if isfield(anno, 'objs')
            out.objs{idx} = anno.objs{i};
        end
        if isfield(anno, 'poses')
            if length(anno.poses) >= i
                out.poses{idx} = anno.poses{i};
            else
                out.poses{idx} = [];
                assert(isempty(anno.objs{i}));
            end
        end
        
        for j = 1:length(anno.obj_annos)
            if(anno.obj_annos(j).objtype == i)
                temp = anno.obj_annos(j);
                temp.objtype = idx;
                out.obj_annos(end+1) = temp;
            end
        end
    end
end

end