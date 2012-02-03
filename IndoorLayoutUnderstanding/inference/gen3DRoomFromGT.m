function [r, objs] = gen3DRoomFromGT(img, gtPolyg, objs)
%% find camera position and room layout (up to scale)
vp = getVPfromGT(img, gtPolyg);
vp = order_vp(vp); % v, h, m
[K, R, F] = get3Dcube(img, vp, gtPolyg);

%% find object location and room scale
objmodel = objmodels();
[camh, objs] = jointInfer3DObjCubes(K, R, objs, objmodel);

%% form output
r = room();
r.K = K;
r.R = R; 
r.F = F;
r.h = camh;
end