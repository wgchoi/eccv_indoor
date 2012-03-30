% split positive training samples according to viewpoints
function [spos, index_pose] = pose_split(pos, n, subtype)

N = numel(pos);
view = zeros(N, 1);
type = zeros(N, 1);

for i = 1:N
    view(i) = find_interval(pos(i).azimuth, n);
    type(i) = pos(i).subid;
end

spos = cell(n * subtype, 1);
index_pose = [];
for i = 1:n
    for j = 1:subtype
        idx = (j - 1) * n + i;
        
        spos{idx} = pos(view == i & type == j);
        
        if numel(spos{idx}) >= 10
            index_pose = [index_pose idx];
        end
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