function angle3 = get3DAngle(K, R, ct, pose, ref)
if nargin < 5
	ref = -1;
end

pt1 = ct;
pt2 = ct + [-sin(pi/4 * (pose - 1)); cos(pi/4 * (pose - 1))] * 10;

ray1 = (K * R) \ [pt1; 1];
ray2 = (K * R) \ [pt2; 1];

ray1 = ray1 ./ ray1(2) * ref;
ray2 = ray2 ./ ray2(2) * ref;

v = ray2 - ray1;
angle3 = atan2(v(3), v(1)) + pi / 2;
return;

ray1, ray2

figure(20);
hold on;
plot3([ray1(1) ray2(1)], [ray1(2) ray2(2)], [ray1(3) ray2(3)], 'ro-')
hold off;

end
