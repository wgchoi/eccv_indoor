function loss = layout_loss(gtpoly, poly)
% Varsha's method 
loss = 0;
if(length(gtpoly) < 5)
    gtpoly(end+1:5) = {[]};
end

for i = 1:5
    if(~isempty(gtpoly{i}) && ~isempty(poly{i}))
        Ax = gtpoly{i}(:, 1);    Ay = gtpoly{i}(:, 2);
        [Ax, Ay] = poly2cw(Ax, Ay);
        Bx = poly{i}(:, 1);    By = poly{i}(:, 2);
        [Bx, By]  = poly2cw(Bx, By);
        
%         [x, y] = polybool('union', Ax, Ay, Bx, By);
%         ua = polyarea(x, y);
        [x, y] = polybool('intersection', Ax, Ay, Bx, By);
        x(isnan(x)) = []; y(isnan(y)) = [];
        
        ia = polyarea(x, y);
        ua = polyarea(Ax, Ay) + polyarea(Bx, By) - ia;
        assert(~isnan(ia));
        assert(~isnan(ua));
        loss = loss + ( 1 - ia / ua);
    elseif(isempty(gtpoly{i}) && isempty(poly{i}))
        % no error
    else
        loss = loss + 1;
    end
end

end

% 1. penalize the absence, defined below..
% for i = 1:5
%     loss = loss + sum(isempty(gtpoly{i})~=isempty(poly{i}));
% end
% 2. shift of the centroid - ambiguous
% for i = 1:5
%     [area,cx,cy] = polycenter(x,y,dim)
% end
% 3. 