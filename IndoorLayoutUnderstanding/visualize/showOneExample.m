function showOneExample(img, gtPolyg, objs, objtypes, imgout)

vp = getVPfromGT(img, gtPolyg);
vp = order_vp(vp); % v, h, m

ShowGTPolyg(img, gtPolyg, 10);
hold on;
for id = 1:length(objs)
    for i = 1:length(objs{id})
        poly = objs{id}(i).poly;
        plot([poly(:,1); poly(1,1)],[poly(:,2); poly(1,2)], 'linewidth', 4, 'Color', 'w');
        rectangle('position', objs{id}(i).bbs, 'edgecolor', 'r', 'linewidth', 2);
        
        text(objs{id}(i).bbs(1), objs{id}(i).bbs(2), objtypes{id}, 'BackgroundColor', 'w', 'EdgeColor', 'k');
        plot([objs{id}(i).pose(1, 1) objs{id}(i).pose(2, 1)],...
             [objs{id}(i).pose(1, 2) objs{id}(i).pose(2, 2)], 'linewidth', 2, 'color', 'g'); 
    end
end
hold off;

[K, R, F] = get3Dcube(img, vp, gtPolyg);

objmodel = objmodels();
drawCube(F, gtPolyg, K, R, objs, objmodel, 1.4);

if (nargin >= 5)
    drawnow;
    figure(10);
    print('-djpeg', [imgout '_2D.jpg']);
    figure(20);
    print('-djpeg', [imgout '_3D.jpg']);
    figure(30);
    print('-djpeg', [imgout '_VP.jpg']);
end

end