function obj_annos = correct_obj_labels(imdir, imfile, annofile, models)

im = imread(fullfile(imdir, imfile));
org = load(annofile);

if(isfield(org, 'obj_annos'))
    draw_all(imdir, imfile, models, org.obj_annos);
    key = input('Correct annotation? (y/n)', 's');
    if(isempty(key) || key ~= 'y')
        obj_annos = org.obj_annos;
        return;
    end
end

ratio = 1;
if(size(im, 2) > 600)
    ratio = 600 / size(im, 2);
end
im = imresize(im, ratio);
figure(1); imshow(im);
hbbox = line('Parent', gca(), ...
              'XData', [], ...
              'YData', [], ...
              'Visible', 'off', ...
              'Clipping', 'off', ...
              'Color', 'w', ...
              'LineStyle', '-', ...
              'LineWidth', 2);

htext = text(5, 10, '', 'BackgroundColor', 'w');
objnames  = '0 : N/A';
for i = 1:length(models)
    objnames = [objnames, ', ', num2str(i), ' : ', models(i).name];
end

% obj_annos = struct('im', {}, 'objtype', {}, 'subid', {}, 'x1', {}, 'x2', {}, 'y1', {}, 'y2', {}, 'azimuth', {}, 'elevation', {});
count = 1;
for i = 1:length(org.objs)
    for j = 1:length(org.objs{i})
        oneobj = org.objs{i}(j);
        try
            oneposes = org.poses{i}(j);
        catch
            oneposes = struct('subid', 1, 'az', 0, 'el', 0);
        end
        
        bbs = oneobj.bbs * ratio;
        show_obj(hbbox, bbs, htext, models(i).name, i);
        figure(1);
        
        key = input(['What is the object? {' objnames ', otherwise : Correct} '], 's');
        objid = key - '0';
        
        obj_annos(count) = struct(  'im', imfile, ...
                                    'objtype', [], ...
                                    'subid', oneposes.subid, ...
                                    'x1', oneobj.bbs(1), 'x2', oneobj.bbs(1) + oneobj.bbs(3), ...
                                    'y1', oneobj.bbs(2), 'y2', oneobj.bbs(2) + oneobj.bbs(4), ...
                                    'azimuth', oneposes.az, 'elevation', oneposes.el);
        if(isempty(objid))
            obj_annos(count).objtype = i;
        elseif (objid <= length(models) && objid >= 0)
            obj_annos(count).objtype = objid;
        else
            obj_annos(count).objtype = i;
        end
        count = count + 1;
    end
end
save(annofile, '-append', 'obj_annos');

%%% draw all
% figure(1);
% imshow(fullfile(imdir, imfile));
% for i = 1:length(obj_annos)
%     rectangle('position', [obj_annos(i).x1, obj_annos(i).y1, obj_annos(i).x2 - obj_annos(i).x1, obj_annos(i).y2 - obj_annos(i).y1], 'linewidth', 2, 'edgecolor', get_obj_color(obj_annos(i).objtype));
%     if(obj_annos(i).objtype > 0)
%         text(obj_annos(i).x1, obj_annos(i).y1, models(obj_annos(i).objtype).name, 'BackgroundColor', get_obj_color(obj_annos(i).objtype));
%     else
%         text(obj_annos(i).x1, obj_annos(i).y1, 'N/A', 'BackgroundColor', get_obj_color(0));
%     end
% end

draw_all(imdir, imfile, models, obj_annos);
if(input('Is all correct? (y/n)', 's') == 'n')
    obj_annos = correct_obj_labels(imdir, imfile, annofile, models);
end

end

function draw_all(imdir, imfile, models, obj_annos)

%%% draw all
figure(1);
imshow(fullfile(imdir, imfile));
for i = 1:length(obj_annos)
    rectangle('position', [obj_annos(i).x1, obj_annos(i).y1, obj_annos(i).x2 - obj_annos(i).x1, obj_annos(i).y2 - obj_annos(i).y1], 'linewidth', 2, 'edgecolor', get_obj_color(obj_annos(i).objtype));
    if(obj_annos(i).objtype > 0)
        text(obj_annos(i).x1, obj_annos(i).y1, models(obj_annos(i).objtype).name, 'BackgroundColor', get_obj_color(obj_annos(i).objtype));
    else
        text(obj_annos(i).x1, obj_annos(i).y1, 'N/A', 'BackgroundColor', get_obj_color(0));
    end
end

end

function show_obj(h, bbs, htext, name, id)

col = get_obj_color(id);

poly = [bbs(1), bbs(1) + bbs(3), bbs(1) + bbs(3), bbs(1), bbs(1); ...
        bbs(2), bbs(2), bbs(2) + bbs(4), bbs(2) + bbs(4), bbs(2)];
set(h, ...
        'XData', poly(1, :), ...
        'YData', poly(2, :), ...
        'color', col, ...
        'Visible', 'on');

set(htext, ...
    'position', [bbs(1), bbs(2), 0], 'BackgroundColor', col, ...
    'string', name, 'Visible', 'on');
end

function col = get_obj_color(id)
cols = 'wrgbcmk';
col = cols(mod(id, length(cols)) + 1);
end