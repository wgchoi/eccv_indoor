function ShowGTPolyg(img,gtPolyg,fignum)
pfc={'r','g','b','k','m'};
facenames={'floor', 'center', 'right', 'left', 'ceiling'};

%pfc={'r','r','r','r','r'};
figure(fignum);
imshow(img,[]);hold on;
set(gcf, 'position', [1 1 800 600]);


for f=1: numel(gtPolyg)
    if numel(gtPolyg{f})>0
      plot([gtPolyg{f}(:,1);gtPolyg{f}(1,1)],[gtPolyg{f}(:,2);gtPolyg{f}(1,2)],'LineWidth',4,...
            'Color',pfc{f});
      pt = mean(gtPolyg{f}, 1);
      text(pt(1), pt(2), facenames{f}, 'color', pfc{f}, 'EdgeColor', pfc{f}, 'BackgroundColor', 'w');
    end
end

hold off;
 
   