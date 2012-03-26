% split positive training samples according to viewpoints
function [spos, index_pose] = pose_split(pos, n)

N = numel(pos);
view = zeros(N, 1);
for i = 1:N
    view(i) = find_interval(pos(i).azimuth, n);
end

spos = cell(n,1);
index_pose = [];
for i = 1:n
    spos{i} = pos(view == i);
    if numel(spos{i}) >= 10
        index_pose = [index_pose i];
    end
end

function ind = find_interval(azimuth, num)

if num == 8
    a = 22.5:45:337.5;
elseif num == 24
    a = 7.5:15:352.5;
end

for i = 1:numel(a)
    if azimuth < a(i)
        break;
    end
end
ind = i;
if azimuth > a(end)
    ind = 1;
end