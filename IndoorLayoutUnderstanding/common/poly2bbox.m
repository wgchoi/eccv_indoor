function bbox = poly2bbox(poly)

bbox = [min(poly(1, :)), min(poly(2, :)), ...
                max(poly(1, :)) - min(poly(1, :)) + 1, ...
                max(poly(2, :)) - min(poly(2, :)) + 1];
            
end