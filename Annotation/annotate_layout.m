function Polyg = annotate_layout(imfile)

img = imread(imfile);
ph=imshow(img);
set(gcf, 'position', [1 1 800 600]);

name = {'floor' 'center wall' 'right wall' 'left wall' 'ceiling'};
pfc={'r','g','b','k','w'};
lines = cell(1, length(name));
Polyg = cell(1, length(name));
i = 1;
while(i <= length(name))
    title(['Please annotate ' name{i} ' if not visible please press ESC']);
    if(~isempty(lines{i}))
        hidePoly(lines{i});
    end
    
    h = impoly;
    poly = wait(h);
    if(isempty(poly))
        i = i + 1;
        continue;
    end
    
    set(h, 'Visible', 'off');
    [undo] = undoCode(poly);
    if(undo)
        if('y' == input('Undo last annotation? [y/n]', 's'))
            i = max(1, i - 1);
        else
            disp('WARNING: Annotation smaller than 10 pixle is not allowed (dedicated for undo code). Press ESC if you want to skip the wall');
        end
        continue;
    end
    
    Polyg{i} = poly;
    if(~isempty(Polyg{i}))
        if(isempty(lines{i}))
            lines{i} = showPoly(gca, Polyg{i}, pfc{i});
        else
            resetPoly(lines{i}, Polyg{i});
        end
    end
    i = i + 1;
end

end

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