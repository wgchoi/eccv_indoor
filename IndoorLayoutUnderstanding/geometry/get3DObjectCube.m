% return 8 vertices that specifies a cube in 3D
function [cube] = get3DObjectCube(ct3, w, h, d, angle)
% at pose 1
% x : width
% y : hiehgt
% z = depth
%       7-----------8
%      /          / |
%     3----------4  |
%     |          |  6
%     |          | / 
%     1----------2/
%

dv(:, 1) = [-0.5 * w; -0.5 * h; 0.5 * d];
dv(:, 2) = [0.5 * w; -0.5 * h; 0.5 * d];
dv(:, 3) = [-0.5 * w; 0.5 * h; 0.5 * d];
dv(:, 4) = [0.5 * w; 0.5 * h; 0.5 * d];
dv(:, 5) = [-0.5 * w; -0.5 * h; -0.5 * d];
dv(:, 6) = [0.5 * w; -0.5 * h; -0.5 * d];
dv(:, 7) = [-0.5 * w; 0.5 * h; -0.5 * d];
dv(:, 8) = [0.5 * w; 0.5 * h; -0.5 * d];

% angle = pi/4 * (pose - 1);
% to world coordinate
R = angle2dcm(0, angle, 0, 'XYZ');
cube = repmat(ct3, 1, 8) + R * dv;

end
