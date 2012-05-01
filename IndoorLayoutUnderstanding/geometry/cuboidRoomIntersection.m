function [volume] = cuboidRoomIntersection(faces, camheight, cuboid)
% faces : 1. floor
%         2. center
%         3. right
%         4. left
%         5. ceiling
volume = zeros(5, 1);
% floor
if(~isnan(faces(1, :)))
    y = -camheight;
    if(cuboid(2, 1) > y)
        volume(1) = 0;
    else
        dy = y - cuboid(2, 1);
        rt = cuboid([1 3], [1 2 6 5 1]);
        volume(1) = dy * polyarea(rt(1, :), rt(2,:));
    end
end
% center
if(~isnan(faces(2, :)))
    z = -camheight * faces(2, end);
    if(min(cuboid(3, :)) > z)
        volume(2) = 0;
    else
        dz = cuboid(2, 3) - cuboid(2, 1);
        rt = cuboid([1 3], [1 2 6 5 1]);
        rt(2, :) = min(rt(2, :), z);
        volume(2) = dz * polyarea(rt(1, :), rt(2,:));
    end
end
% right
if(~isnan(faces(3, :)))
    x = -camheight * faces(3, end);
    if(min(cuboid(1, :)) < x)
        volume(3) = 0;
    else
        dx = cuboid(2, 3) - cuboid(2, 1);
        rt = cuboid([1 3], [1 2 6 5 1]);
        rt(1, :) = max(rt(1, :), x);
        volume(3) = dx * polyarea(rt(1, :), rt(2,:));
    end
end
% left
if(~isnan(faces(4, :)))
    x = -camheight * faces(4, end);
    if(min(cuboid(1, :)) > x)
        volume(4) = 0;
    else
        dx = cuboid(2, 3) - cuboid(2, 1);
        rt = cuboid([1 3], [1 2 6 5 1]);
        rt(1, :) = min(rt(1, :), x);
        volume(4) = dx * polyarea(rt(1, :), rt(2,:));
    end
end
% ceiling
if(~isnan(faces(5, :)))
    y = -camheight * faces(5, end);
    if(cuboid(2, 3) < y)
        volume(5) = 0;
    else
        dy = cuboid(2, 3) - y;
        rt = cuboid([1 3], [1 2 6 5 1]);
        volume(5) = dy * polyarea(rt(1, :), rt(2,:));
    end
end

end