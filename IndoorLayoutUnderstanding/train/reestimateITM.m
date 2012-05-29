function rule = reestimateITM(rule, composites, onlycenter)
if nargin < 3
    onlycenter = false;
end
% conservative..
N = 4;
for i = 1:rule.numparts
    temp = [rule.parts(i).dx, rule.parts(i).dz, rule.parts(i).da];
    for j = 1:length(composites)
        temp(end+1, :) = [ composites(j).dloc(i, :), composites(j).dpose(i)];
    end
    
    rule.parts(i).dx = mean(temp(:, 1));
    rule.parts(i).dz = mean(temp(:, 2));
    rule.parts(i).da = anglemean(temp(:, 3));
    if(onlycenter), continue; end
    
    rule.parts(i).wx = - 1 / var(temp(:, 1)) / N ;
    rule.parts(i).wz = - 1 / var(temp(:, 2)) / N ;
    da = [];
    for j = 1:size(temp, 1)
        da(j) = anglediff(rule.parts(i).da, temp(j, 3));
    end
    rule.parts(i).wa = -1 / mean(da.^2) / N ;
end

end