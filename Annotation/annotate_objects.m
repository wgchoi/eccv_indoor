function [objs] = annotate_objects(imfile, id, name, objs)

img = imread(imfile);

margin = floor(size(img, 1) / 5);

img2 = uint8(zeros(size(img, 1) + 2 * margin, size(img, 2) + 2 * margin, size(img, 3)));
img2(margin+1:margin+size(img, 1), margin+1:margin+size(img, 2), :) = img;
img = img2;

patch = imread('pose_anno.bmp');
patch = imresize(patch, [margin margin]);
img(end-margin+1:end, end-margin+1:end, :) = patch;

imshow(img);
set(gcf, 'position', [1 1 800 600]);

if nargin < 4
    objs = struct('id', cell(1, 0), 'pose', cell(1, 0), 'poly', cell(1, 0), 'bbs', cell(1, 0));
else
    hold on;
    for i = 1:length(objs)
        objs(i).poly = objs(i).poly + margin;
        objs(i).bbs(1:2) = objs(i).bbs(1:2) + margin;
        
        poly = objs(i).poly;
        plot([poly(:,1); poly(1,1)],[poly(:,2); poly(1,2)], 'linewidth', 4, 'Color', 'w');
        rectangle('position', objs(i).bbs, 'edgecolor', 'r', 'linewidth', 2);
        
        draw_pose(objs(i).bbs, objs(i).pose);
    end
    hold off;
end

cnt = length(objs);
while(1)
    title(['Please annotate ' name 's, if done please press esc']);
    h = impoly; poly = wait(h);
    if(isempty(poly))
        break;
    end
    
    cnt = cnt + 1;
    
    objs(cnt).id = id;
    objs(cnt).poly = poly;
    objs(cnt).bbs = [min(poly(:, 1)), min(poly(:, 2)), ...
                    max(poly(:, 1)) - min(poly(:, 1)) + 1, ...
                    max(poly(:, 2)) - min(poly(:, 2)) + 1];
                
    rectangle('position', objs(cnt).bbs, 'edgecolor', 'r', 'linewidth', 2);

    objs(cnt).pose = input('Input pose (1 ~ 8)');
    hold on;
    draw_pose(objs(cnt).bbs, objs(cnt).pose);
    hold off;
end

for i = 1:length(objs)
    objs(i).poly = objs(i).poly - margin;
    objs(i).bbs(1:2) = objs(i).bbs(1:2) - margin;
end

end

function draw_pose(bb, pose)

pt1(1) = bb(1) + bb(3) / 2;
pt1(2) = bb(2) + bb(4) / 2;

len = bb(4) * 0.2;

angle = pi / 4 * (pose - 1);
pt2(1) = pt1(1) - len * sin(angle);
pt2(2) = pt1(2) + len * cos(angle);

scatter(pt1(1), pt1(2), 'go')
plot([pt1(1) pt2(1)], [pt1(2) pt2(2)], 'linewidth', 2, 'color', 'g'); 
end
