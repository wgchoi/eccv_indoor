function annotate_one_image( imfile, annofile, types, annotator)

assert(nargin == 4);
gtPolyg = annotate_layout(imfile);
% types = {'Sofa', 'Table', 'TV'};
for id = 1:length(types)
    [objs{id}] = annotate_objects(imfile, id, types{id});
end
objtypes = types;
save(annofile, 'gtPolyg', 'objs', 'annotator', 'objtypes');

addpath ../IndoorLayoutUnderstanding/objmodel/
annotate_obj_poses(imfile, annofile, objmodels());
rmpath ../IndoorLayoutUnderstanding/objmodel/

end

