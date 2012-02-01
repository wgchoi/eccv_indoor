function [cost] = objFitnessCost(xz, camh, K, R, obj, model, mid)
assert(length(xz) == 2);
location = zeros(3, 1);
location(1) = xz(1);
location(3) = xz(2);
location(2) = -(camh - model.height(mid) / 2);
%%%%
angle = get3DAngle(K, R, obj.pose, -camh);
[cube] = get3DObjectCube(location, model.width(mid), model.height(mid), model.depth(mid), angle);
[ppoly, pbbox] = get2DCubeProjection(K, R, cube);
%%%
bbox = obj.bbs;

bbox(1:2) = bbox(1:2) + bbox(3:4) / 2;
pbbox(1:2) = pbbox(1:2) + pbbox(3:4) / 2;
cost = sum( ( bbox(1:2) - pbbox(1:2) ) .^ 2 );
cost = cost + sum( ( bbox(3:4) - pbbox(3:4) ) .^ 2 );

end