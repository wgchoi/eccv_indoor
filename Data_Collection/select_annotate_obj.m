function select_annotate_obj(imgdir, objid, objname, outdir)
addpath('../Annotation');
addpath('../IndoorLayoutUnderstanding/objmodel/');
imfiles = dir(fullfile(imgdir, '*.jpg'));

if(~exist(outdir, 'dir'))
    mkdir(outdir);
end

models = objmodels();
angles = cell(length(models(objid).type));

count = 0;
usedlist = {};
try
    % count the data from YuXiang's training set.
    basedir = ['~/codes/yuxiang_codes/Annotations/' objname];
    imbasedir = ['~/codes/yuxiang_codes/Images/' objname];
    
    afiles = dir([basedir '/*.mat']);
    assert(~isempty(afiles));
    for i = 1:length(afiles)
        temp = load(fullfile(basedir, afiles(i).name));
        % assuming all objects are wide sofa...
        az = temp.object.view(1);
        if az > 180, az = az - 360; end
        angles{1}(end+1) =  az / 180 * pi; % azimuth
    end
    
    disp('appeding existing dataset for statistics computation');
catch ee
    ee
end

try
    annofile = dir(fullfile(outdir, '*.mat'));
    for i = 1:length(annofile)
        load(fullfile(outdir,annofile(i).name));
        
        usedlist = [usedlist, anno.im];
        angles{anno.subid}(end+1) = anno.azimuth;
        count = count + 1;
    end 
catch ee
    ee
end
i0 = 1;
if(~isempty(usedlist))
    lastfile = usedlist{end};
    for i0 = 1:length(imfiles)
        imfile = fullfile(imgdir, imfiles(i0).name);
        if(strcmp(lastfile, imfile))
            break;
        end
    end
end
count
usedlist = unique(usedlist);
for i = i0:length(imfiles)
    imfile = fullfile(imgdir, imfiles(i).name);
    if(sum(strcmp(usedlist, imfile)) > 0)
        continue;
    end
    
    print_stat(angles);
    figure(1); 
    imshow(imfile);
    key = input('use image? (y/n)', 's');
    
    if(key == 'y')
        objs = annotate_object_poly(imfile, objid, objname);
        poses = annotate_object_poses(imfile, objs, objid, models);
        
        assert(length(objs) == length(poses));
        
        for j = 1:length(poses)
            count = count + 1;
            
            anno.im = imfile;
            anno.x1 = objs(j).bbs(1);
            anno.x2 = objs(j).bbs(1) + objs(j).bbs(3) - 1;
            anno.y1 = objs(j).bbs(2);
            anno.y2 = objs(j).bbs(2) + objs(j).bbs(4) - 1;
            anno.azimuth = poses(j).az;
            anno.elevation = poses(j).el;
            anno.subid = poses(j).subid;
            
            save(fullfile(outdir, ['annotation' num2str(count, '%05d')]), 'anno');
            angles{poses(j).subid}(end+1) = poses(j).az;
        end
    end
end

end

function print_stat(angles)

for i = 1:length(angles)
    dist = hist(angles{i}, -9/8*pi:pi/4:9/8*pi);
    disp(['subtype ' num2str(i)])
    
    assert(dist(end) == 0);
    
    dist = dist(1:end - 1);
    dist = [dist(5:end-1), dist(end) + dist(1), dist(2:4)];
    disp(dist);
end

end