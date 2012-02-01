function drawCube(Faces, poly, K, R, objs, objmodel, cam_height)

if nargin < 7
    cam_height = 1;
end

% wall1, wall2, bound1, bound2
linePairs = [1, 2, 3, 4; ...
            1, 3, 2, 0;  ...
            1, 4, 2, 0; ...
            2, 3, 1, 5; ...
            2, 4, 1, 5; ...
            2, 5, 3, 4; ...
            3, 5, 2, 0; ...
            4, 5, 2, 0];
       
        
        
figid = 20;        
figure(figid);

hold on;
for i = 1:size(linePairs, 1)
    id1 = linePairs(i, 1);
    id2 = linePairs(i, 2);
    
    if( sum(isnan(Faces(id1, :))) > 0 || sum(isnan(Faces(id2, :))) > 0)
        continue;
    end
    
    n1 = Faces(id1, 1:3);       n2 = Faces(id2, 1:3);
    p1 = - n1 * Faces(id1, 4) * cam_height;  
    p2 = - n2 * Faces(id2, 4) * cam_height;
    
    [P, N, check] = plane_intersect(n1, p1, n2, p2);
    assert(check == 2);
    if 1
        b1 = linePairs(i, 3);
        b2 = linePairs(i, 4);

        pi = [];  pe = [];
        if( sum(isnan(Faces(b1, :))) == 0 && b2 > 0 && sum(isnan(Faces(b2, :))) == 0)
            pl0 = -500 .* N + P;
            pl1 = 500 .* N + P;

            np = Faces(b1, 1:3); vp = - np * Faces(b1, 4) * cam_height;  
            [pi, check] = plane_line_intersect(np, vp, pl0, pl1);
            assert(check == 1 || check == 3);

            np = Faces(b2, 1:3); vp = - np * Faces(b2, 4) * cam_height;  
            [pe, check] = plane_line_intersect(np, vp, pl0, pl1);
            assert(check == 1 || check == 3);
        elseif (sum(isnan(Faces(b1, :))) == 0)
            pl0 = -500 .* N + P;
            pl1 = 500 .* N + P;

            np = Faces(b1, 1:3); vp = - np * Faces(b1, 4) * cam_height;  
            [pi, check] = plane_line_intersect(np, vp, pl0, pl1);
            assert(check == 1 || check == 3);
            N = N * get_vector_direction(N, pi, [0, 0, 0]);

            pe = pi + N * cam_height * 3;
        elseif (b2 > 0 && sum(isnan(Faces(b2, :))) == 0)
            pl0 = -500 .* N + P;
            pl1 = 500 .* N + P;

            np = Faces(b2, 1:3); vp = - np * Faces(b2, 4) * cam_height;  
            [pi, check] = plane_line_intersect(np, vp, pl0, pl1);
            assert(check == 1 || check == 3);
            N = N * get_vector_direction(N, pi, [0, 0, 0]);

            pe = pi + N * cam_height * 3;
        else
            % get projection of camera location onto the line
            pp = get_vector_direction(N, P, [0, 0, 0]);
            p1 = pp - N * cam_height * 3;
            pe = pp + N * cam_height * 3;
        end
        % find the point of intersection
        plot3([pi(1) pe(1)], [pi(2) pe(2)], [pi(3) pe(3)], 'r--', 'LineWidth', 3);
    else
        steps = -5:0.1:5 * cam_height;

        pts = zeros(length(steps), 3);
        for j = 1:length(steps)
            pts(j, :) = steps(j) .* N + P;
        end

        plot3(pts(:, 1), pts(:, 2), pts(:, 3));
    end

%             pts =  .* N + P;
end
hold off;

hold on;
% floor visible
if( sum(isnan(Faces(1, :))) == 0)
    % draw floor
    np = Faces(1, 1:3); vp = - np * Faces(1, 4) * cam_height;  
    
    for i = 1:size(poly{1}, 1)
        ray = (K * R) \ [poly{1}(i, :)'; 1];
        ray = ray ./ norm(ray);
        
        pl0 = [0, 0, 0] + 100 * ray';
        pl1 = [0, 0, 0] - 100 * ray';
        [pi(i, :), check] = plane_line_intersect(np, vp, pl0, pl1);
    end
    h=patch(pi(:, 1), pi(:, 2), pi(:, 3), 'c');
    set(h,'edgecolor','k');
end

% visualize camera
p1 = [0; 0; 0];
p2 = R' * [0; 0; .3 * cam_height];
arrow3d(p1', p2', 15, 'cylinder', [0.7,0.3]);
hold off;
%
view([170 -60]); grid on;
xlabel('x'); ylabel('y'); zlabel('z');
axis equal

figure(figid);
%
view([170 -60]); grid on;
xlabel('x'); ylabel('y'); zlabel('z');
axis equal

% x=-10:.1:10;
% [X,Y] = meshgrid(x);
% a=2; b=-3; c=10; d=-1;
% Z=(d- a * X - b * Y)/c;
% surf(X,Y,Z)
% shading flat
% xlabel('x'); ylabel('y'); zlabel('z')

end

% get the sign of direction vector dl that points p0 direction
function sign = get_vector_direction(dl, pl, p0)
if(dot(dl, p0 - pl) > 0)
    sign = 1;
else 
    sign = -1;
end
end
