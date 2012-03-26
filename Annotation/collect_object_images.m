function [im, spos] = collect_object_images(imdir, annodir, objtype, subtype, azrange)

N = 1000;
spos = struct(  'im', cell(N, 1), ...
                'x1', cell(N, 1), ...
                'x2', cell(N, 1), ...
                'y1', cell(N, 1), ...
                'y2', cell(N, 1));

imfiles = dir(fullfile(imdir, '*.jpg'));
N = 1;

for i = 1:length(imfiles)
    imfile = fullfile(imdir, imfiles(i).name);
    annofile = fullfile(annodir, [imfiles(i).name(1:end-4) '_labels.mat']);
    
    annotation = load(annofile);
    
    obj = annotation.objs{objtype};
    if(length(annotation.poses) < objtype)
        continue;
    end
    pose = annotation.poses{objtype};
    for j = 1:length(obj)
        if(subtype == pose(j).subid)
            if(azrange(1) < pose(j).az && azrange(2) >= pose(j).az)
                spos(N).im = imfile;
                spos(N).x1 = obj(j).bbs(1);
                spos(N).x2 = obj(j).bbs(1) + obj(j).bbs(3) - 1;
                spos(N).y1 = obj(j).bbs(2);
                spos(N).y2 = obj(j).bbs(2) + obj(j).bbs(4) - 1;
                N = N + 1;
            elseif(azrange(1) - 2 * pi < pose(j).az && azrange(2)  - 2 * pi >= pose(j).az)
                spos(N).im = imfile;
                spos(N).x1 = obj(j).bbs(1);
                spos(N).x2 = obj(j).bbs(1) + obj(j).bbs(3) - 1;
                spos(N).y1 = obj(j).bbs(2);
                spos(N).y2 = obj(j).bbs(2) + obj(j).bbs(4) - 1;
                N = N + 1;
            end
        end
    end
end

spos(N:end) = [];
im = show_pose_images(spos);
% title(['total ' num2str(N-1) ' examples found']);

end

function fullim = show_pose_images(spos)

nx = 4; ny = 8;
w = 100; h = 50;

fullim = uint8(zeros(h * ny, w * nx, 3));

for i = 1:ny
    for j = 1:nx
        idx = (i - 1) * nx + j;
        
        if(idx > length(spos))
            continue;
        end
        
        window = subarray(imread(spos(idx).im), ...
                            floor(spos(idx).y1), floor(spos(idx).y2), ...
                            floor(spos(idx).x1), floor(spos(idx).x2), 1);

        fullim(((i-1) * h + 1):(i * h), ((j-1) * w + 1):(j * w), :) = uint8(imresize(window, [h w]));
    end
end

if nargout < 1
    imshow(fullim);
end
end