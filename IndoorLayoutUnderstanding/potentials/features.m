function phi = features(pg, x, iclusters, model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object-object interaction : 1) 3D intersection 2) 2D bboverlap
            5 + ... % object inclusion : 3D volume intersection
            model.nobjs + ... % min distance to wall 3D
            model.nobjs + ... % min distance to wall 2D
            model.nobjs + ... % floor distance per object: sofa to floor
            2 * model.nobjs;      % object confidence : (weight + bias) per type


phi = zeros(featlen, 1);
ibase = 1;

%% scene
% layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;
%% for a pair of objects
% per object definition??
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
%% below : all per object!
% object-room face interaction - no inclusion
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, x.cubes{iclusters(i1).chindices});
    phi(ibase:ibase+4) = phi(ibase:ibase+4) + volume;
end
ibase = ibase + 5;

% object-wall interaction % min distance to wall 3D
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    [d1, d2] = obj2wallFloorDist(x.faces{pg.layoutidx}, x.cubes{iclusters(i1).chindices}, pg.camheight);
    oid = iclusters(i1).ittype - 1;
    phi(ibase+oid) = phi(ibase+oid) + min(abs(d1) + abs(d2));
end
ibase = ibase + model.nobjs;

% object-wall interaction % min distance to wall 2D
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    [d1, d2] = obj2wallImageDist(x.corners{pg.layoutidx}, x.projs(iclusters(i1).chindices).poly);
    oid = iclusters(i1).ittype - 1;
    
    phi(ibase+oid) = phi(ibase+oid) + min(d1 + d2);
end
ibase = ibase + model.nobjs;

% object-floor interaction 
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    bottom = x.cubes{iclusters(i1).chindices}(2, 1); % bottom y position.
    oid = iclusters(i1).ittype - 1;
    
    phi(ibase+oid) = phi(ibase+oid) + (pg.camheight + bottom) .^ 2; %
end
ibase = ibase + model.nobjs;

% object observation confidence + bias
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    
    oid = (iclusters(i1).ittype - 1) * 2;
    
    phi(ibase + oid) = phi(ibase + oid) + x.dets(i1, 8);
    phi(ibase + oid + 1) = phi(ibase + oid + 1) + 1;
end
ibase = ibase + 2 * model.nobjs;
assert(featlen == ibase - 1);
end

% NClusterType = model.nobjs + length(model.rules);
% phi = zeros(model.nscene * NClusterType + ...
%             0, 1);
% % compatibility between cluster and scene 
% % function of cluster type and room type.
% ibase = 0;
% for i = 1:length(pg.childs)
%     idx = ibase + (pg.scenetype - 1) * NClusterType;
%     idx = idx + iclusters(pg.childs(i)).ittype;
%     
%     phi(idx) = phi(idx) + 1;
% end
% ibase = ibase + model.nscene * NClusterType;
% % geometric compatibility between clusters and scene layout
% % function of camera height, room faces, clusters
% 
% % compatibility between clusters and childs
% % 
% 
% % observation
% % scene, layout, objects
% end