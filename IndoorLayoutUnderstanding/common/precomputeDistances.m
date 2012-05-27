function x = precomputeDistances(x)

x.dists = zeros(size(x.locs, 1), size(x.locs, 1));
x.angdiff = zeros(size(x.locs, 1), size(x.locs, 1));
for i = 1:size(x.locs, 1)
    for j = i+1:size(x.locs, 1)
        d = norm(x.locs(i, 1:3) - x.locs(j, 1:3));
        x.dists(i, j) = d;
        x.dists(j, i) = d;
        
        ad = anglediff(x.locs(i, 4), x.locs(j, 4));
        x.angdiff(i, j) = ad;
        x.angdiff(j, i) = ad;
    end
end

end