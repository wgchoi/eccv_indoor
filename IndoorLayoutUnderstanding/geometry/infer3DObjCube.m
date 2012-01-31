function cube = infer3DObjCube(K, R, obj, model, cam_height, figid)
%%% get intial guess!
cpt2 = [obj.bbs(1) + obj.bbs(3) / 2; obj.bbs(2) + obj.bbs(4) / 2];
cray3 = (K * R) \ [cpt2; 1];
angle = get3DAngle(K, R, obj.pose, -cam_height);
iloc = cray3 ./ cray3(2) * -(cam_height - model.height(1) / 2);

% get max overlapping hypotehsis
loc = fminsearch(@(x) costfunction(x, K, R, model, obj.bbs, obj.poly, angle), iloc);
cube = get3DObjectCube(R, loc, model.width(1), model.height(1), model.depth(1), angle);

% keyboard
end


function [cost] = costfunction(location, K, R, model, bbox, poly, angle)

[cube] = get3DObjectCube(R, location, model.width(1), model.height(1), model.depth(1), angle);
[ppoly, pbbox] = get2DCubeProjection(K, R, cube);

cost = -log(boxoverlap(pbbox, bbox));

end