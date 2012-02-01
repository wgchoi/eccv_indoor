function drawObjects(K, R, cubes, fig3d, fig2d)

if nargin < 4
    fig3d = -1;
    fig2d = -1;
elseif nargin < 5
    fig2d = -1;
end

% drawObjects
for i = 1:length(cubes)
    % each type of objects
    for j = 1:length(cubes{i})
        cube = cubes{i}{j};
        if(isempty(cube))
            continue;
        end
        
        if( fig3d >  0)
            draw3Dcube(cube, fig3d);
        end
        
        if( fig2d >  0)
            [poly, bbox] = get2DCubeProjection(K, R, cube);
            draw2DCube(poly, bbox, fig2d);
        end
    end
end

end