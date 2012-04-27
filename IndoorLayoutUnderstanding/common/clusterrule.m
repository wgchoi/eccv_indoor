function rule = clusterrule()
%
rule = struct('type', 0, 'numparts', 1, 'parts', partrules(1));
end

function rules = partrules(numparts)
%
citypes = cell(numparts, 1);
citypes(:) = {0};
rules = struct('citype', citypes, ...
                'dx', 0, 'dy', 0, 'dz', 0,  ...
                'wx', 0, 'wy', 0, 'wz', 0,  ...
                'bias', 0);

end
