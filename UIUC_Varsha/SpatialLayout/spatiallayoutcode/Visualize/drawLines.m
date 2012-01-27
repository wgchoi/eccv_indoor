function drawLines(img, lines)
imshow(img);
hold on;
for i = 1:size(lines, 1)
    plot([lines(i, 1) lines(i, 2)], [lines(i, 3) lines(i, 4)], 'r-');
end
hold off;
end