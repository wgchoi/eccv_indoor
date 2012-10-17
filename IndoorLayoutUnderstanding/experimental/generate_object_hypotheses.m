function [hypotheses] = generate_object_hypotheses(imfile, K, R, objmodels, dets)
for o = 1:length(objmodels)
    didx = dets(:, 1) == o;
    h = one_object_hypotheses2(imfile, K, R, objmodels(o), dets(didx, :));
end
end

function h = one_object_hypotheses2(imfile, K, R, objmodel, dets)
dstep = 0.05;
dx = -10:dstep:10; % x discretization
dy = -2:dstep:0;
dz = -10:dstep:0;
dp = 0:pi/4:7*pi/4;
for i = 1:size(dets, 1)
    [loc, angle, cube] = get_iproject(K, R, bbox2rect(dets(i, 4:7)), dets(i, 1:3));
    
end
end

function [h] = one_object_hypotheses1(imfile, K, R, objmodel, dets)

dstep = 0.05;
dx = -10:dstep:10; % x discretization
dy = -2:dstep:0;
dz = -10:dstep:0;
dp = 0:pi/4:7*pi/4;

im = imread(imfile);
imsz = size(im);

for i = 1:length(dx)
    for j = 1:length(dy)
        for k = 1:length(dz)
            for l = 1:length(dp)
                loc = [dx(i), dy(j), dz(k), dp(l)];
                
                subid = 1;
                
                cube = get3DObjectCube(loc(1:3)', objmodel.width(subid), objmodel.height(subid), objmodel.depth(subid), loc(end));
                [poly, rt] = get2DCubeProjection(K, R, cube);
                bbox = [rt(1:2), rt(3:4) + rt(1:2)];
                
                if(1)
                end
            end
        end
    end
end

end