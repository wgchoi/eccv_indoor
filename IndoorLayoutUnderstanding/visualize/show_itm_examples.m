function show_itm_examples(ptn, examples)
for i = 1:length(examples)
    imshow(examples(i).imfile);
    rectangle('position', bbox2rect(examples(i).bbox), 'linewidth', 2, 'edgecolor', 'w');
    
    cols = {'r' 'g' 'b' 'k' 'm' 'r' 'c'};
    cts = [];
    for j = 1:size(examples(i).objboxes, 2)
        if(isempty(ptn))
            colid = j;
        else
            colid = ptn.parts(j).citype;
        end
        rectangle('position', bbox2rect( examples(i).objboxes(:, j) ), 'linewidth', 3, 'edgecolor', cols{colid});
        cts(:, j) = bbox2ct(examples(i).objboxes(:, j));
    end
        
    hold on;
    plot(cts(1,1), cts(2, 1), 'c.', 'MarkerSize', 30);
    plot(cts(1, 1:2), cts(2, 1:2), 'r-', 'linewidth', 3)
    hold off
    
    for j = 1:size(examples(i).objboxes, 2)
        text(examples(i).objboxes(1, j)+5, examples(i).objboxes(2, j)+5, num2str(j), 'fontsize', 20, 'backgroundcolor', 'w');
    end
    
    title([num2str(i) 'th angle: ' num2str(examples(i).angles / pi * 180, '%.02f') ' azimuth: ' num2str(examples(i).azimuth / pi * 180, '%.02f')]);
    pause
end
end