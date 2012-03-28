function [objs] = annotate_object_poly(imfile, id, name, objs)

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

hobjs = {};
if nargin < 4
    objs = struct('id', cell(1, 0), 'poly', cell(1, 0), 'bbs', cell(1, 0));
else
    for i = 1:length(objs)
        objs(i).poly = objs(i).poly + margin;
        objs(i).bbs(1:2) = objs(i).bbs(1:2) + margin;
        poly = objs(i).poly;        
        hobj = showObj(gca, objs(i));
    end
end

cnt = length(objs);
while(1)
    title(['Please annotate ' name 's, if done please press esc']);    
    assert(cnt == length(objs));
    
    poly = getclosedpoly;
    if(isempty(poly))
        break;
    end 
    
    [undo] = undoCode(poly);
    if(undo)
        if('y' == input('Undo last annotation? [y/n]', 's'))
            if(cnt > 0)
                hideObj(hobjs{cnt});
                objs(cnt) = [];
                cnt = cnt - 1;
            end
        else
            disp('WARNING: Annotation smaller than 10 pixle is not allowed (dedicated for undo code). Press ESC if you want to finish!');
        end
        continue;
    end
    
    bbox = [min(poly(:, 1)), min(poly(:, 2)), ...
                max(poly(:, 1)) - min(poly(:, 1)) + 1, ...
                max(poly(:, 2)) - min(poly(:, 2)) + 1];

    cnt = cnt + 1;
    
    objs(cnt).id = id;
    objs(cnt).poly = poly;
    objs(cnt).bbs = bbox;
                
    hobj = showObj(gca, objs(cnt));
    cpt = [objs(cnt).bbs(1) + objs(cnt).bbs(3) / 2, objs(cnt).bbs(2) + objs(cnt).bbs(4) / 2];
end

for i = 1:length(objs)
    objs(i).poly = objs(i).poly - margin;
    objs(i).bbs(1:2) = objs(i).bbs(1:2) - margin;
end
clf;

end

function hobj = showObj(p, obj)
bbs = obj.bbs;
poly = obj.poly;
xdata = [bbs(1); bbs(1) + bbs(3) - 1; bbs(1) + bbs(3) - 1; bbs(1); bbs(1)];
ydata = [bbs(2); bbs(2); bbs(2) + bbs(4) - 1; bbs(2) + bbs(4) - 1; bbs(2)];
hobj.bbs = line('Parent', p, ...
          'XData', xdata, ...
          'YData', ydata, ...
          'Visible', 'on', ...
          'Clipping', 'off', ...
          'Color', 'r', ...
          'LineStyle', '--', ...
          'LineWidth', 2);
      
xdata = [poly(:,1);poly(1,1)];
ydata = [poly(:,2);poly(1,2)];
hobj.poly = line('Parent', p, ...
          'XData', xdata, ...
          'YData', ydata, ...
          'Visible', 'on', ...
          'Clipping', 'off', ...
          'Color', 'w', ...
          'LineStyle', '-', ...
          'LineWidth', 4);
end

function hobj = hideObj(hobj)
set(hobj.bbs, 'Visible', 'off');
set(hobj.poly, 'Visible', 'off');
end
