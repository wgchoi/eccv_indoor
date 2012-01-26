function Polyg = annotate_layout(imfile)

img = imread(imfile);
imshow(img);
set(gcf, 'position', [1 1 800 600]);

name = {'floor' 'center wall' 'right wall' 'left wall' 'ceiling'};


pfc={'r','g','b','k','w'};
for i = 1:5
    title(['Please annotate ' name{i} ' if not visible please press ESC']);
    h = impoly;
    Polyg{i} = wait(h);
    
    if(~isempty(Polyg{i}))
        hold on;
        plot([Polyg{i}(:,1);Polyg{i}(1,1)],[Polyg{i}(:,2);Polyg{i}(1,2)],'LineWidth',4,'Color',pfc{i});
        hold off
    end
end

end