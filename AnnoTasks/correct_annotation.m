function correct_annotation(imfile, annofile, outfile, corrector)

%% check layout first
img = imread(imfile);
load(annofile);

ph=imshow(img);
set(gcf, 'position', [1 1 800 600]);

name = {'floor' 'center wall' 'right wall' 'left wall' 'ceiling'};
pfc={'r','g','b','k','w'};
lines = cell(1, length(name));

i = 1;
while(i <= length(name))
    if(~isempty(gtPolyg{i}))
        lines{i} = showPoly(gca, gtPolyg{i}, pfc{i});
    end
    title(['Please annotate ' name{i} ' if not visible please press ESC'])
    if('y' == input(['Redo ' name{i} ' Annotation? [y/n]'], 's'))
        hidePoly(lines{i});
        
        h = impoly;
        poly = wait(h);
        if(isempty(poly))
            gtPolyg{i} = poly;
            i = i + 1;
            continue;
        end
        set(h, 'Visible', 'off');        
        gtPolyg{i} = poly;
        if(isempty(lines{i}))
            lines{i} = showPoly(gca, gtPolyg{i}, pfc{i});
        else
            resetPoly(lines{i}, gtPolyg{i});
        end
        
        i = i + 1;
        continue;
    else
        i = i + 1;
        continue;
    end
end

margin = floor(size(img, 1) / 5);
img2 = uint8(zeros(size(img, 1) + 2 * margin, size(img, 2) + 2 * margin, size(img, 3)));
img2(margin+1:margin+size(img, 1), margin+1:margin+size(img, 2), :) = img;

for i = 1:length(objs)
    clf;

    img = img2;
    imshow(img);
    title(['Please correct ' objtypes{i} 's']);    
    oneobjs = objs{i};
    
    removelist = [];
    for j = 1:length(oneobjs)
        oneobjs(j).poly = oneobjs(j).poly + margin;
        oneobjs(j).bbs(1:2) = oneobjs(j).bbs(1:2) + margin;
        oneobjs(j).pose = oneobjs(j).pose + margin;

        hobj = showObj(gca, oneobjs(j));
        key = input(['Redo Annotation? [y/d(delete)/n]'], 's');
        if('y' == key)
            hobj = hideObj(hobj);
            
            poly = getclosedpoly;
            
            bbox = [min(poly(:, 1)), min(poly(:, 2)), ...
                max(poly(:, 1)) - min(poly(:, 1)) + 1, ...
                max(poly(:, 2)) - min(poly(:, 2)) + 1];

            oneobjs(j).poly = poly;
            oneobjs(j).bbs = bbox;

            hobj = showObj(gca, oneobjs(j));
            
            cpt = [oneobjs(j).bbs(1) + oneobjs(j).bbs(3) / 2, oneobjs(j).bbs(2) + oneobjs(j).bbs(4) / 2];
            oneobjs(j).pose = getPoseDirection(cpt);
            hobj = showPose(gca, hobj, oneobjs(j));
            
            continue;
        elseif ('d' == key)
            hobj = hideObj(hobj);
            removelist(end+1) = j;
            continue;
        end

        hobj = showPose(gca, hobj, oneobjs(j));
        if('y' == input(['Redo Annotation? [y/n]'], 's'))
            hobj = hidePose(hobj);
            
            cpt = [oneobjs(j).bbs(1) + oneobjs(j).bbs(3) / 2, oneobjs(j).bbs(2) + oneobjs(j).bbs(4) / 2];
            oneobjs(j).pose = getPoseDirection(cpt);
            hobj = showPose(gca, hobj, oneobjs(j));
        end
    end
    
    oneobjs(removelist) = [];
    
    for j = 1:length(oneobjs)
        oneobjs(j).poly = oneobjs(j).poly - margin;
        oneobjs(j).bbs(1:2) = oneobjs(j).bbs(1:2) - margin;
        oneobjs(j).pose = oneobjs(j).pose - margin;
    end

    if('y' == input(['More Annotation? [y/n]'], 's'))
        [oneobjs] = annotate_objects(imfile, i, objtypes{i}, oneobjs);
    end
    
    objs{i} = oneobjs;
end

save(outfile, 'gtPolyg', 'objs', 'annotator', 'objtypes', 'corrector');
end

%%
function hobj = showObj(p, obj)
bbs = obj.bbs;
poly = obj.poly;
% pose = obj.pose;
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

function hobj = showPose(p, hobj, obj)
xdata = obj.pose(:,1);
ydata = obj.pose(:,2);
hobj.pose = line('Parent', p, ...
          'XData', xdata, ...
          'YData', ydata, ...
          'Visible', 'on', ...
          'Clipping', 'off', ...
          'Color', 'g', ...
          'LineStyle', '-', ...
          'LineWidth', 2);
end

function hobj = hideObj(hobj)
set(hobj.bbs, 'Visible', 'off');
set(hobj.poly, 'Visible', 'off');
end

function hobj = hidePose(hobj)
set(hobj.pose, 'Visible', 'off');
end
%%

function h = showPoly(p, poly, color)

xdata = [poly(:,1);poly(1,1)];
ydata = [poly(:,2);poly(1,2)];

h = line('Parent', p, ...
          'XData', xdata, ...
          'YData', ydata, ...
          'Visible', 'on', ...
          'Clipping', 'off', ...
          'Color', color, ...
          'LineStyle', '-', ...
          'LineWidth', 4);

end

function h = hidePoly(h)
set(h, 'Visible', 'off');
end

function h = resetPoly(h, poly)

xdata = [poly(:,1); poly(1,1)];
ydata = [poly(:,2); poly(1,2)];

set(h, 'XData', xdata, 'YData', ydata, 'Visible', 'on');

end