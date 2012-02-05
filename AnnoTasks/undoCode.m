function [undo] = undoCode(poly)

xmin=min(poly(:, 1));
xmax=max(poly(:, 1));

ymin=min(poly(:, 2));
ymax=max(poly(:, 2));

undo = ((xmax - xmin) < 10) && ((ymax - ymin) < 10);

end
