function visualizeITM(rule, omodel, figid)
if nargin < 2
    omodel = objmodels();
    figid = 2000;
elseif nargin < 3
    figid = 2000;
end
figure(figid);
clf
for i = 1:length(rule.parts)
    drawpart(rule.parts(i), omodel, i);
end
grid on;
xlabel('x');
ylabel('z');

end


function drawpart(part, omodel, idx)

oid = part.citype;
col = 'rgbykmcrgbykmcrgbykmcrgbykmc';

rect = [-omodel(oid).width(1) / 2, omodel(oid).depth(1) / 2; ...
        omodel(oid).width(1) / 2, omodel(oid).depth(1) / 2; ...
        omodel(oid).width(1) / 2, -omodel(oid).depth(1) / 2; ...
        -omodel(oid).width(1) / 2, -omodel(oid).depth(1) / 2];
    
R = rotationMat(part.da);
rect = repmat([part.dx; part.dz], 1, 4) + R * rect';

mapshow(rect(1, :), rect(2, :), 'DisplayType','polygon','Marker','.', ...
            'LineStyle','-', 'linewidth', 8, 'facecolor', col(oid));
hold on
plot(rect(1, [1 2]), rect(2, [1 2]), 'w', 'linewidth', 2);
hold off
text(part.dx, part.dz, [num2str(idx) ':' omodel(oid).name], 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2);

end