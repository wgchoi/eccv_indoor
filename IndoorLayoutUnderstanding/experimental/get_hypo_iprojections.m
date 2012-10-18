function h = get_hypo_iprojections(imfile, K, R, yaw, objmodel, rect, attr)
     
mid = attr(2);
dstep = 0.05; % 5 cm at 1m distance

obj.bbs = rect;
cpt2 = [obj.bbs(1) + obj.bbs(3) / 2; obj.bbs(2) + obj.bbs(4) / 2];
cray3 = (K * R) \ [cpt2; 1];

aaa = atan2(-cray3(1), -cray3(3));

dp = -2*pi:pi/4:2*pi;
angle = get_closest(dp, attr(3) - yaw);
angle = get_closest(dp, attr(3) - aaa);

if(angle < 0)
    angle = angle + 2 * pi;
end

best_depth = 0;
mindiff = 1.0;
for depth = 0.1:0.1:10
    loc = - cray3 .* (depth / cray3(3));
    [cube] = get3DObjectCube(loc, objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
    [~, pbbox] = get2DCubeProjection(K, R, cube);
    
    dheight = abs(rect(4) - pbbox(4)) / rect(4);
    if(dheight < 0.2)
       if(mindiff > dheight)
           mindiff = dheight;
           best_depth = depth;
       end
    end
end

dstep = dstep * best_depth;

loc = -cray3 .* (best_depth / cray3(3));
[cube] = get3DObjectCube(loc, objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
[ppoly, pbbox] = get2DCubeProjection(K, R, cube);
maxov = boxoverlap(rect2bbox(pbbox), rect2bbox(rect));

h = struct( 'oid', 0, 'locs', zeros(3, 27), ...
            'cubes', zeros(3, 8, 27), ...
            'polys', zeros(2, 8, 27), ...
            'bbs', zeros(4, 27), ...
            'ovs', zeros(1, 27), ...
            'azimuth', attr(3), ... % notice that this angle is azimuth defined in image plane!!!
            'angle', angle ); 
        
% subplot(121);
% imshow(imfile);
% hold on;
% rectangle('position', rect, 'edgecolor', 'k', 'LineStyle', '--', 'linewidth', 3);
% rectangle('position', pbbox, 'edgecolor', 'r', 'LineStyle', '-.', 'linewidth', 4);
% idx= [1 2 4 3 1 5 6 8 7 5];
% plot(ppoly(1, idx), ppoly(2, idx), 'w-', 'linewidth', 2);
% hold off;
while(1)
    % dv = zeros(3, 27);
    cnt = 1;
    for dx = [-1 0 1]
        for dy = [-1 0 1]
            for dz = [-1 0 1]
                h.locs(:, cnt) = loc + [dx; dy; dz] .* dstep;
                h.cubes(:, :, cnt) = get3DObjectCube(h.locs(:, cnt), objmodel.width(mid), objmodel.height(mid), objmodel.depth(mid), angle);
                [h.polys(:, :, cnt), h.bbs(:, cnt)] = get2DCubeProjection(K, R, h.cubes(:, :, cnt));
                % dv(:, cnt) = [dx; dy; dz];
                cnt = cnt + 1;
            end
        end
    end
    h.bbs(3:4, :) = h.bbs(3:4, :) + h.bbs(1:2, :) - 1;
    h.ovs = boxoverlap(h.bbs', rect2bbox(rect));
    
    [val, idx] = max(h.ovs);
    if(maxov < val)
        loc = h.locs(:, idx);
        maxov = val;
    else
        break;
    end
end

end


function val = get_closest(list, v)
[~, idx] = min(abs(list-v));
val = list(idx);
end