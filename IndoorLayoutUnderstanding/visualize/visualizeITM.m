function visualizeITM(rule, omodel, figid)
if nargin < 2
    omodel = objmodels();
    cla
else
    figure(figid);
    clf
end

fontsize = 12;
for i = 1:length(rule.parts)
    drawpart(rule.parts(i), omodel, i, fontsize);
end
grid on;

h = xlabel('x');
set(h, 'fontsize', fontsize); 
h = ylabel('z');
set(h, 'fontsize', fontsize); 

end


function drawpart(part, omodel, idx, fontsize)

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
text(part.dx, part.dz, [num2str(idx) ':' omodel(oid).name ':' num2str(part.subtype)], 'backgroundcolor', 'w', 'edgecolor', 'k', 'linewidth', 2, 'fontsize', fontsize);

end