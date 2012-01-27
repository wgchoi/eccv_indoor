function [objs] = annotate_objects(imfile, id, name, objs)

img = imread(imfile);

margin = floor(size(img, 1) / 5);

img2 = uint8(zeros(size(img, 1) + 2 * margin, size(img, 2) + 2 * margin, size(img, 3)));
img2(margin+1:margin+size(img, 1), margin+1:margin+size(img, 2), :) = img;
img = img2;
% 
% patch = imread('pose_anno.bmp');
% patch = imresize(patch, [margin margin]);
% img(end-margin+1:end, end-margin+1:end, :) = patch;

imshow(img);
set(gcf, 'position', [1 1 800 600]);

if nargin < 4
    objs = struct('id', cell(1, 0), 'pose', cell(1, 0), 'poly', cell(1, 0), 'bbs', cell(1, 0));
else
    hold on;
    for i = 1:length(objs)
        objs(i).poly = objs(i).poly + margin;
        objs(i).bbs(1:2) = objs(i).bbs(1:2) + margin;
        objs(i).pose = objs(i).pose + margin;
        
        poly = objs(i).poly;
        plot([poly(:,1); poly(1,1)],[poly(:,2); poly(1,2)], 'linewidth', 4, 'Color', 'w');
        rectangle('position', objs(i).bbs, 'edgecolor', 'r', 'linewidth', 2);
        if 1
            plot([objs(i).pose(1, 1) objs(i).pose(2, 1)], [objs(i).pose(1, 2) objs(i).pose(2, 2)], 'linewidth', 2, 'color', 'g'); 
        else
            draw_pose(objs(i).bbs, objs(i).pose);
        end
    end
    hold off;
end

cnt = length(objs);
while(1)
    title(['Please annotate ' name 's, if done please press esc']);
    poly = getclosedpoly;
    if(isempty(poly))
        break;
    end
    bbox = [min(poly(:, 1)), min(poly(:, 2)), ...
                max(poly(:, 1)) - min(poly(:, 1)) + 1, ...
                max(poly(:, 2)) - min(poly(:, 2)) + 1];
    
    if(bbox(3) < 8 || bbox(4) < 8)
        continue;
    end
    
    hold on;
    plot([poly(:,1); poly(1,1)],[poly(:,2); poly(1,2)], 'linewidth', 4, 'Color', 'w');
    hold off;
    
    cnt = cnt + 1;
    
    objs(cnt).id = id;
    objs(cnt).poly = poly;
    objs(cnt).bbs = bbox;
                
    rectangle('position', objs(cnt).bbs, 'edgecolor', 'r', 'linewidth', 2);
    if(1)
        cpt = [objs(cnt).bbs(1) + objs(cnt).bbs(3) / 2, objs(cnt).bbs(2) + objs(cnt).bbs(4) / 2];
        objs(cnt).pose = getPoseDirection(cpt);
        hold on;
        plot([objs(cnt).pose(1, 1) objs(cnt).pose(2, 1)], [objs(cnt).pose(1, 2) objs(cnt).pose(2, 2)], 'linewidth', 2, 'color', 'g'); 
        hold off;
    else
        objs(cnt).pose = input('Input pose (1 ~ 8)');
        hold on;
        draw_pose(objs(cnt).bbs, objs(cnt).pose);
        hold off;
    end
end

for i = 1:length(objs)
    objs(i).poly = objs(i).poly - margin;
    objs(i).bbs(1:2) = objs(i).bbs(1:2) - margin;
    objs(i).pose = objs(i).pose - margin;
end

end
% end
% 
% function draw_pose(bb, pose)
% 
% pt1(1) = bb(1) + bb(3) / 2;
% pt1(2) = bb(2) + bb(4) / 2;
% 
% len = bb(4) * 0.2;
% 
% angle = pi / 4 * (pose - 1);
% pt2(1) = pt1(1) - len * sin(angle);
% pt2(2) = pt1(2) + len * cos(angle);
% 
% scatter(pt1(1), pt1(2), 'go')
% plot([pt1(1) pt2(1)], [pt1(2) pt2(2)], 'linewidth', 2, 'color', 'g'); 
% end
