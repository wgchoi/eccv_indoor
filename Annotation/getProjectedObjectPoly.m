function [poly, face] = getProjectedObjectPoly(imsz, w, h, d, azimuth, elevation)
% at pose 1
% x : width
% y : heihgt
% z : depth
%       7-----------8
%      /          / |
%     3----------4  |
%     |          |  6
%     |          | / 
%     1----------2/
%
dv(:, 1) = [-0.5 * w; -0.5 * d; -0.5 * h];
dv(:, 2) = [0.5 * w; -0.5 * d; -0.5 * h];
dv(:, 3) = [-0.5 * w; -0.5 * d; 0.5 * h];
dv(:, 4) = [0.5 * w; -0.5 * d; 0.5 * h];
dv(:, 5) = [-0.5 * w; 0.5 * d; -0.5 * h];
dv(:, 6) = [0.5 * w; 0.5 * d; -0.5 * h];
dv(:, 7) = [-0.5 * w; 0.5 * d; 0.5 * h];
dv(:, 8) = [0.5 * w; 0.5 * d; 0.5 * h];
% dv(:, 5) = [-0.5 * w; -0.5 * h; -0.5 * d];
% dv(:, 6) = [0.5 * w; -0.5 * h; -0.5 * d];
% dv(:, 7) = [-0.5 * w; 0.5 * h; -0.5 * d];
% dv(:, 8) = [0.5 * w; 0.5 * h; -0.5 * d];

%%% copied from YuXiang's code Thanks Yu.
% viewport size M
R = 100 * [1 0 0.5; 0 -1 0.5; 0 0 1];
R(3,3) = 1;

P = projection(azimuth, elevation, 5);
P1 = R * P([1 2 4], :);
F = dv;
cube = P1 * [F; ones(1, size(F, 2))];
cube = cube(1:2, :) ./ repmat(cube(3, :), 2, 1);

% keyboard;
scale = imsz(2) / (max(cube(1, :)) - min(cube(1, :)));
cube = cube .* scale;

cx = (min(cube(1, :)) + max(cube(1, :))) / 2; 
cy = (min(cube(2, :)) + max(cube(2, :))) / 2;

cube(1, :) = cube(1, :) - cx + imsz(2) / 2;
cube(2, :) = cube(2, :) - cy + imsz(1) / 2;

cube = cube';
poly = [cube(1, 1), cube(2, 1), cube(4, 1), cube(3, 1), cube(1, 1), ...
        cube(5, 1), cube(7, 1), cube(3, 1), ...
        cube(4, 1), cube(8, 1), cube(7, 1), ...
        cube(5, 1), cube(6, 1), cube(8, 1), ...
        cube(6, 1), cube(2, 1), ...
        cube(1, 1), cube(5, 1), cube(6, 1); ...
        cube(1, 2), cube(2, 2), cube(4, 2), cube(3, 2), cube(1, 2), ...
        cube(5, 2), cube(7, 2), cube(3, 2), ...
        cube(4, 2), cube(8, 2), cube(7, 2), ...
        cube(5, 2), cube(6, 2), cube(8, 2), ...
        cube(6, 2), cube(2, 2), ...
        cube(1, 2), cube(5, 2), cube(6, 2)];

face = [cube(1, 1), cube(2, 1), cube(4, 1), cube(3, 1); ...
        cube(1, 2), cube(2, 2), cube(4, 2), cube(3, 2)];

end


%%% copied from YuXiang's code Thanks Yu.
% compute project matrix P from azimuth a, elevation e and distance d 
% of camera pose. Rotate coordinate system by theta is equal to rotating
% the model by -theta.
function [P, C] = projection(a, e, d)

%camera center
C = zeros(3,1);
C(1) = d*cos(e)*sin(a);
C(2) = -d*cos(e)*cos(a);
C(3) = d*sin(e);

a = -a;
e = -(pi/2-e);

%rotation matrix
Rz = [cos(a) -sin(a) 0; sin(a) cos(a) 0; 0 0 1];   %rotate by a
Rx = [1 0 0; 0 cos(e) -sin(e); 0 sin(e) cos(e)];   %rotate by e
R = Rx*Rz;

%orthographic project matrix
%P = [R -R*C; 0 0 0 1];

%perspective project matrix
P = [1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 -1 0] * [R -R*C; 0 0 0 1];

end
