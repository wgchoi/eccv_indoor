function show_itm_examples(examples)
for i = 1:length(examples)
    imshow(examples(i).imfile);
    rectangle('position', bbox2rect(examples(i).bbox), 'linewidth', 2, 'edgecolor', 'w');
    
    cols = {'r' 'g' 'b' 'k' 'm'};
    cts = [];
    for j = 1:size(examples(i).objboxes, 2)
        rectangle('position', bbox2rect( examples(i).objboxes(:, j) ), 'linewidth', 3, 'edgecolor', cols{j});
        cts(:, j) = bbox2ct(examples(i).objboxes(:, j));
    end
    
    hold on;
    plot(cts(1,1), cts(2, 1), 'c.', 'MarkerSize', 30);
    plot(cts(1, 1:2), cts(2, 1:2), 'r-', 'linewidth', 3)
    hold off
    title(['angle: ' num2str(examples(i).angles / pi * 180, '%.02f') ' azimuth: ' num2str(examples(i).azimuth / pi * 180, '%.02f')]);
    pause
end
end