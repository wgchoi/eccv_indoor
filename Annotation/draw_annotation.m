function draw_annotation(imfile, annofile)
img = imread(imfile);

load(annofile);
ShowGTPolyg(img, gtPolyg, 1);

hold on;
for id = 1:length(objs)
    for i = 1:length(objs{id})
        poly = objs{id}(i).poly;
        plot([poly(:,1); poly(1,1)],[poly(:,2); poly(1,2)], 'linewidth', 4, 'Color', 'w');
        rectangle('position', objs{id}(i).bbs, 'edgecolor', 'r', 'linewidth', 2);
        
        text(objs{id}(i).bbs(1), objs{id}(i).bbs(2), objtypes{id}, 'BackgroundColor', 'w', 'EdgeColor', 'k');
        draw_pose(objs{id}(i).bbs, objs{id}(i).pose);
    end
end
hold off;

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