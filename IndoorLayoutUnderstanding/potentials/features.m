function phi = features(pg, x, iclusters, model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object pairs : 1) 3D intersection 2) 2D bboverlap
            5 + ... % object inclusion : 3D volume intersection
            1 + ... % floor distance : sofa to floor
            2;      % object confidence : (weight + bias) per type

phi = zeros(featlen, 1);
ibase = 1;

% layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;

% object interaction - repulsion
for i = 1:length(pg.childs)
    for j = i+1:length(pg.childs)
        % not supporting grouping yet!
        i1 = pg.childs(i);
        i2 = pg.childs(j);
        
        assert(iclusters(i1).isterminal);
        assert(iclusters(i2).isterminal);
        
        phi(ibase) = phi(ibase) + x.intvol(i1, i2);
        phi(ibase + 1) = phi(ibase + 1) + x.orarea(i1, i2);
    end
end
ibase = ibase + 2;

% object-room face interaction - no inclusion
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, x.cubes{iclusters(i1).chindices});
    phi(ibase:ibase+4) = phi(ibase:ibase+4) + volume;
end
ibase = ibase + 5;

% object-room face interaction - no inclusion
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    
    bottom = x.cubes{iclusters(i1).chindices}(2, 1); % bottom y position.
    phi(ibase) = phi(ibase) + (pg.camheight + bottom) .^ 2; %
end
ibase = ibase + 1;

% object observation confidence + bias
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    
    phi(ibase) = phi(ibase) + x.dets(i1, 8);
    phi(ibase + 1) = phi(ibase + 1) + 1;
end
ibase = ibase + 2;

return;

NClusterType = model.nobjs + length(model.rules);
phi = zeros(model.nscene * NClusterType + ...
            0, 1);
% compatibility between cluster and scene 
% function of cluster type and room type.
ibase = 0;
for i = 1:length(pg.childs)
    idx = ibase + (pg.scenetype - 1) * NClusterType;
    idx = idx + iclusters(pg.childs(i)).ittype;
    
    phi(idx) = phi(idx) + 1;
end
ibase = ibase + model.nscene * NClusterType;
% geometric compatibility between clusters and scene layout
% function of camera height, room faces, clusters

% compatibility between clusters and childs
% 

% observation
% scene, layout, objects
end