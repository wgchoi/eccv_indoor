function phi = features(pg, x, iclusters, model)

if( isfield(model, 'commonground') && model.commonground )
    if(strcmp(model.feattype, 'type2'))
        phi = features3(pg, x, iclusters, model);
    elseif(strcmp(model.feattype, 'type3'))
        phi = features4(pg, x, iclusters, model);
    elseif(strcmp(model.feattype, 'type5'))
        phi = features5(pg, x, iclusters, model);
    elseif(strcmp(model.feattype, 'type6'))
        phi = features6(pg, x, iclusters, model);
    elseif(strcmp(model.feattype, 'itm_v0'))
        phi = features_itm0(pg, x, iclusters, model);
    end
    return;
end

if(~isfield(model, 'feattype') || strcmp(model.feattype, 'type1'))
    phi = features1(pg, x, iclusters, model);
elseif(strcmp(model.feattype, 'type2'))
    phi = features2(pg, x, iclusters, model);
end

end

function phi = features_itm0(pg, x, iclusters, model)

featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            ( length(model.ow_edge) - 1 ) + ... % object-wall inclusion 
            ( model.nobjs * model.nscene ) + ... % semantic constext
            sum(model.itmfeatlen) + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            1 + ...         % projection-deformation cost
            1;              % floor distance

phi = zeros(featlen, 1);
ibase = 1;

objidx = getObjIndices(pg, iclusters);

assert(isfield(pg, 'objscale'));
cubes = cell(1, length(objidx));
for i = 1:length(objidx)
    idx = objidx(i);
    cubes{i} = x.cubes{idx} .* pg.objscale(i);
end

%% scene classification
phi(ibase) = x.sconf(pg.scenetype);
ibase = ibase + 1;
%% scene layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;
%% object observation confidence + bias
for i = 1:length(objidx)
    i1 = objidx(i);
    if(iclusters(i1).isterminal)
        obase = (iclusters(i1).ittype - 1) * 2;
        
        phi(ibase + obase) = phi(ibase + obase) + x.dets(i1, 8); % detection confidence
        phi(ibase + obase + 1) = phi(ibase + obase + 1) + 1;
    else
        assert(false, 'not ready');
    end
end
ibase = ibase + 2 * model.nobjs;
%% object-wall interaction - no inclusion
buf_w = zeros(3 * length(objidx), 1);

for i = 1:length(cubes)
    %%%%%% need to make it robust!!!
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, cubes{i});
    buf_w((3*i-2):3*i) = volume(2:4);
end

temp = histc(buf_w, model.ow_edge);
phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;

%% object scene context
sidx = (pg.scenetype - 1) * model.nobjs;
for i = 1:length(objidx)
    i1 = objidx(i);
    if(iclusters(i1).isterminal)
        idx = ibase + sidx + iclusters(i1).ittype - 1;
        phi(idx) = phi(idx) + 1;
    else
        assert(false, 'not ready');
    end
end
ibase = ibase + model.nobjs * model.nscene;
%% interaction templates!
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    if(~iclusters(i1).isterminal)
        itmid = iclusters(i1).ittype - model.nobjs;
        % compute itm features
        temp = ibase + model.itmbase(itmid);
        locs = zeros(length(iclusters(i1).chindices), 4);
        for j = 1:length(iclusters(i1).chindices)
            idx = find(objidx == iclusters(i1).chindices(j), 1);
            
            locs(j, 1:3) = x.locs(iclusters(i1).chindices(j), 1:3) * pg.objscale(idx);
            locs(j, 4) = x.locs(iclusters(i1).chindices(j), 4);
        end
        % 
        itmfeat = getITMfeat(model.itmptns(itmid), locs, model);
        phi(temp:temp+model.itmfeatlen(itmid)-1) = itmfeat;
    end
end
ibase = ibase + sum(model.itmfeatlen);
%% overlap between a pair of objects
phi(ibase) = sum(sum(x.orarea(objidx, objidx)));
phi(ibase + 1) = sum(sum(x.orpolys(objidx, objidx)));
ibase = ibase + 2;

%% object scale deformation
objscale = pg.objscale;
objscale(objscale < 0) = 1e-2; % safe guard to avoid error
for i = 1:length(objidx)
    phi(ibase) = phi(ibase) + ( log(objscale(i)) ) .^ 2;
end
ibase = ibase + 1;

%% object-floor interaction 
for i = 1:length(objidx)
    bottom = min(cubes{i}(2, :)); % bottom y position.
    phi(ibase) = phi(ibase) + (pg.camheight + bottom) .^ 2; %
end
ibase = ibase + 1;

assert(featlen == ibase - 1);
assert(~(any(isnan(phi)) || any(isinf(phi))));

end

function phi = features6(pg, x, iclusters, model)

featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            model.nobjs * ( length(model.ow_edge) - 1 ) + ... % object-wall inclusion 
            ( model.nobjs * model.nscene ) + ... % semantic constext
            0 + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            model.nobjs + ...         % projection-deformation cost
            1;              % floor distance

phi = zeros(featlen, 1);
ibase = 1;
assert(isfield(pg, 'objscale'));
cubes = cell(1, length(pg.childs));
for i = 1:length(pg.childs)
    idx = pg.childs(i);
    cubes{i} = x.cubes{idx} .* pg.objscale(i);
end
%% scene classification
phi(ibase) = x.sconf(pg.scenetype);
ibase = ibase + 1;
%% scene layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;
%% object observation confidence + bias
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    if(iclusters(i1).isterminal)
        obase = (iclusters(i1).ittype - 1) * 2;
        
        phi(ibase + obase) = phi(ibase + obase) + x.dets(i1, 8); % detection confidence
        phi(ibase + obase + 1) = phi(ibase + obase + 1) + 1;
    else
        assert(false, 'not ready');
    end
end
ibase = ibase + 2 * model.nobjs;
%% object-wall interaction - no inclusion
nbin = (length(model.ow_edge) - 1);
for i = 1:length(cubes)
    %%%%%% need to make it robust!!!
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, cubes{i});
    temp = histc(volume(2:4), model.ow_edge);
    
    i1 = pg.childs(i);
    if(iclusters(i1).isterminal)
        idx = ibase + nbin * (iclusters(i1).ittype - 1);
        phi(idx:idx+nbin-1) = phi(idx:idx+nbin-1) + temp(1:end-1);
    else
        assert(false, 'not ready');
    end
end

ibase = ibase + model.nobjs * nbin;
%% object scene context
sidx = (pg.scenetype - 1) * model.nobjs;
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    if(iclusters(i1).isterminal)
        idx = ibase + sidx + iclusters(i1).ittype - 1;
        phi(idx) = phi(idx) + 1;
    else
        assert(false, 'not ready');
    end
end
ibase = ibase + model.nobjs * model.nscene;
%% interaction templates!
%% overlap between a pair of objects
phi(ibase) = sum(sum(x.orarea(pg.childs, pg.childs)));
phi(ibase + 1) = sum(sum(x.orpolys(pg.childs, pg.childs)));
ibase = ibase + 2;
%% object scale deformation
objscale = pg.objscale;
objscale(objscale < 0) = 1e-2; % safe guard to avoid error
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    if(iclusters(i1).isterminal)
        idx = ibase + iclusters(i1).ittype - 1;
        phi(idx) = phi(idx) + ( log(objscale(i)) ) .^ 2;
    else
        assert(false, 'not ready');
    end
end
ibase = ibase + model.nobjs;
%% object-floor interaction 
for i = 1:length(pg.childs)
    bottom = min(cubes{i}(2, :)); % bottom y position.
    phi(ibase) = phi(ibase) + (pg.camheight + bottom) .^ 2; %
end
ibase = ibase + 1;

assert(featlen == ibase - 1);
assert(~(any(isnan(phi)) || any(isinf(phi))));

end

function phi = features5(pg, x, iclusters, model)

featlen =   1 + ... % scene classification 
            1 + ... % layout confidence : no bias required, selection problem    
            2 * model.nobjs + ... % object confidence : (weight + bias) per type
            ( length(model.ow_edge) - 1 ) + ... % object-wall inclusion 
            ( model.nobjs * model.nscene ) + ... % semantic constext
            0 + ... % intearction templates!
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            1 + ...         % projection-deformation cost
            1;              % floor distance

phi = zeros(featlen, 1);
ibase = 1;

assert(isfield(pg, 'objscale'));
cubes = cell(1, length(pg.childs));
for i = 1:length(pg.childs)
    idx = pg.childs(i);
    cubes{i} = x.cubes{idx} .* pg.objscale(i);
end

%% scene classification
phi(ibase) = x.sconf(pg.scenetype);
ibase = ibase + 1;
%% scene layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;
%% object observation confidence + bias
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    if(iclusters(i1).isterminal)
        obase = (iclusters(i1).ittype - 1) * 2;
        
        phi(ibase + obase) = phi(ibase + obase) + x.dets(i1, 8); % detection confidence
        phi(ibase + obase + 1) = phi(ibase + obase + 1) + 1;
    else
        assert(false, 'not ready');
    end
end
ibase = ibase + 2 * model.nobjs;
%% object-wall interaction - no inclusion
buf_w = zeros(3 * length(pg.childs), 1);

for i = 1:length(cubes)
    %%%%%% need to make it robust!!!
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, cubes{i});
    buf_w((3*i-2):3*i) = volume(2:4);
end

temp = histc(buf_w, model.ow_edge);
phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;
%% object scene context
sidx = (pg.scenetype - 1) * model.nobjs;
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    if(iclusters(i1).isterminal)
        idx = ibase + sidx + iclusters(i1).ittype - 1;
        phi(idx) = phi(idx) + 1;
    else
        assert(false, 'not ready');
    end
end
ibase = ibase + model.nobjs * model.nscene;
%% interaction templates!
%% overlap between a pair of objects
phi(ibase) = sum(sum(x.orarea(pg.childs, pg.childs)));
phi(ibase + 1) = sum(sum(x.orpolys(pg.childs, pg.childs)));
ibase = ibase + 2;
%% object scale deformation
objscale = pg.objscale;
objscale(objscale < 0) = 1e-2; % safe guard to avoid error
for i = 1:length(pg.childs)
    phi(ibase) = phi(ibase) + ( log(objscale(i)) ) .^ 2;
end
ibase = ibase + 1;
%% object-floor interaction 
for i = 1:length(pg.childs)
    bottom = min(cubes{i}(2, :)); % bottom y position.
    phi(ibase) = phi(ibase) + (pg.camheight + bottom) .^ 2; %
end
ibase = ibase + 1;

assert(featlen == ibase - 1);
assert(~(any(isnan(phi)) || any(isinf(phi))));

end

function phi = features4(pg, x, iclusters, model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object-object interaction : 2D bboverlap, 2D polyoverlap
            (length(model.ow_edge) - 1) + ... % object-wall inclusion 
            1 + ...       % projection-deformation cost
            1 + ...       % floor distance
            2 * model.nobjs;        % object confidence : (weight + bias) per type

phi = zeros(featlen, 1);
ibase = 1;

assert(isfield(pg, 'objscale'));
cubes = cell(1, length(pg.childs));
for i = 1:length(pg.childs)
    idx = pg.childs(i);
    cubes{i} = x.cubes{idx} .* pg.objscale(i);
end
%% scene layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;
%% overlap between a pair of objects
phi(ibase) = sum(sum(x.orarea(pg.childs, pg.childs)));
phi(ibase + 1) = sum(sum(x.orpolys(pg.childs, pg.childs)));
ibase = ibase + 2;
%% below : all per object!
% object-wall interaction - no inclusion
buf_w = zeros(3 * length(pg.childs), 1);
for i = 1:length(cubes)
    %%%%%% need to make it robust!!!
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, cubes{i});
    buf_w((3*i-2):3*i) = volume(2:4);
end
temp = histc(buf_w, model.ow_edge);
phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;

% object scale deformation
objscale = pg.objscale;
objscale(objscale < 0) = 1e-2;

for i = 1:length(pg.childs)
    phi(ibase) = phi(ibase) + ( log(objscale(i)) ) .^ 2;
end
ibase = ibase + 1;

% object-floor interaction 
for i = 1:length(pg.childs)
    bottom = min(cubes{i}(2, :)); % bottom y position.
    phi(ibase) = phi(ibase) + (pg.camheight + bottom) .^ 2; %
end
ibase = ibase + 1;

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

if(any(isnan(phi)) || any(isinf(phi)))
    assert(0);
end

end

function phi = features3(pg, x, iclusters, model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object-object interaction : 1) 3D intersection 2) 2D bboverlap
            3 * (length(model.ow_edge) - 1) + ... % object-wall inclusion 
            model.nobjs + ... % min distance to wall 3D
            model.nobjs + ... % min distance to wall 2D
            model.nobjs + ... % floor distance per object: sofa to floor
            2 * model.nobjs;      % object confidence : (weight + bias) per type

phi = zeros(featlen, 1);
ibase = 1;

assert(isfield(pg, 'objscale'));
cubes = cell(1, length(pg.childs));
for i = 1:length(pg.childs)
    idx = pg.childs(i);
    cubes{i} = x.cubes{idx} .* pg.objscale(i);
end
%% scene
% layout confidence
phi(ibase) = x.lconf(pg.layoutidx);
ibase = ibase + 1;
%% for a pair of objects
% per object definition??
% object interaction - repulsion
% for i = 1:length(pg.childs)
%     for j = i+1:length(pg.childs)
%         % not supporting grouping yet!
%         i1 = pg.childs(i);
%         i2 = pg.childs(j);
%         
%         assert(iclusters(i1).isterminal);
%         assert(iclusters(i2).isterminal);
%         
%         % way too much time consuming disabling for now..
%         % phi(ibase) = phi(ibase) + cuboidIntersectionsVolume(cubes{i}, cubes{j});
%         phi(ibase + 1) = phi(ibase + 1) + x.orarea(i1, i2);
%     end
% end
phi(ibase + 1) = sum(sum(x.orarea(pg.childs, pg.childs)));
ibase = ibase + 2;
%% below : all per object!
% object-room face interaction - no inclusion
buf_f = zeros(length(pg.childs), 1);
buf_c = zeros(length(pg.childs), 1);
buf_w = zeros(3 * length(pg.childs), 1);
for i = 1:length(cubes)
    %%%%%% need to make it robust!!!
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, cubes{i});
    
    buf_f(i) = volume(1);
    buf_c(i) = volume(5);
    buf_w((3*i-2):3*i) = volume(2:4);
end
% temp = histc(buf_f, model.ow_edge);
% phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;
% temp = histc(buf_c, model.ow_edge);
% phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;
temp = histc(buf_w, model.ow_edge);
phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;
% object-wall interaction % min distance to wall 3D
% for i = 1:length(pg.childs)
%     i1 = pg.childs(i);
%     assert(iclusters(i1).isterminal);
%     [d1, d2] = obj2wallFloorDist(x.faces{pg.layoutidx}, x.cubes{i1}, pg.camheight);
%     oid = iclusters(i1).ittype - 1;
%     phi(ibase+oid) = phi(ibase+oid) + min(abs(d1) + abs(d2));
% end
ibase = ibase + model.nobjs;

% object-wall interaction % min distance to wall 2D
% for i = 1:length(pg.childs)
%     i1 = pg.childs(i);
%     assert(iclusters(i1).isterminal);
%     [d1, d2] = obj2wallImageDist(x.corners{pg.layoutidx}, x.projs(i1).poly);
%     oid = iclusters(i1).ittype - 1;
%     
%     phi(ibase+oid) = phi(ibase+oid) + min(d1 + d2);
% end
ibase = ibase + model.nobjs;

% object-floor interaction 
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    oid = iclusters(i1).ittype - 1;
    
    bottom = min(cubes{i}(2, :)); % bottom y position.
    
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

if(any(isnan(phi)) || any(isinf(phi)))
    keyboard;
end

end

function phi = features2(pg, x, iclusters, model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object-object interaction : 1) 3D intersection 2) 2D bboverlap
            3 * (length(model.ow_edge) - 1) + ... % object-wall inclusion 
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
buf_f = zeros(length(pg.childs), 1);
buf_c = zeros(length(pg.childs), 1);
buf_w = zeros(3 * length(pg.childs), 1);

for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    %%%%%% need to make it robust!!!
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, x.cubes{i1});
    
    buf_f(i) = volume(1);
    buf_c(i) = volume(5);
    buf_w((3*i-2):3*i) = volume(2:4);
end
temp = histc(buf_f, model.ow_edge);
phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;

temp = histc(buf_c, model.ow_edge);
phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;

temp = histc(buf_w, model.ow_edge);
phi(ibase:ibase+(length(model.ow_edge) - 2)) = temp(1:end-1);
ibase = ibase + length(model.ow_edge) - 1;

% object-wall interaction % min distance to wall 3D
% for i = 1:length(pg.childs)
%     i1 = pg.childs(i);
%     assert(iclusters(i1).isterminal);
%     [d1, d2] = obj2wallFloorDist(x.faces{pg.layoutidx}, x.cubes{i1}, pg.camheight);
%     oid = iclusters(i1).ittype - 1;
%     phi(ibase+oid) = phi(ibase+oid) + min(abs(d1) + abs(d2));
% end
ibase = ibase + model.nobjs;

% object-wall interaction % min distance to wall 2D
% for i = 1:length(pg.childs)
%     i1 = pg.childs(i);
%     assert(iclusters(i1).isterminal);
%     [d1, d2] = obj2wallImageDist(x.corners{pg.layoutidx}, x.projs(i1).poly);
%     oid = iclusters(i1).ittype - 1;
%     
%     phi(ibase+oid) = phi(ibase+oid) + min(d1 + d2);
% end
ibase = ibase + model.nobjs;

% object-floor interaction 
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    
    bottom = x.cubes{i1}(2, 1); % bottom y position.
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

if(any(isnan(phi)) || any(isinf(phi)))
    keyboard;
end

end

function phi = features1(pg, x, iclusters, model)
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
    %%%%%% need to make it robust!!!
    volume = cuboidRoomIntersection(x.faces{pg.layoutidx}, pg.camheight, x.cubes{i1});
    phi(ibase:ibase+4) = phi(ibase:ibase+4) + volume;
end
ibase = ibase + 5;

% object-wall interaction % min distance to wall 3D
% for i = 1:length(pg.childs)
%     i1 = pg.childs(i);
%     assert(iclusters(i1).isterminal);
%     [d1, d2] = obj2wallFloorDist(x.faces{pg.layoutidx}, x.cubes{i1}, pg.camheight);
%     oid = iclusters(i1).ittype - 1;
%     phi(ibase+oid) = phi(ibase+oid) + min(abs(d1) + abs(d2));
% end
ibase = ibase + model.nobjs;

% object-wall interaction % min distance to wall 2D
% for i = 1:length(pg.childs)
%     i1 = pg.childs(i);
%     assert(iclusters(i1).isterminal);
%     [d1, d2] = obj2wallImageDist(x.corners{pg.layoutidx}, x.projs(i1).poly);
%     oid = iclusters(i1).ittype - 1;
%     
%     phi(ibase+oid) = phi(ibase+oid) + min(d1 + d2);
% end
ibase = ibase + model.nobjs;

% object-floor interaction 
for i = 1:length(pg.childs)
    i1 = pg.childs(i);
    assert(iclusters(i1).isterminal);
    
    bottom = x.cubes{i1}(2, 1); % bottom y position.
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

if(any(isnan(phi)) || any(isinf(phi)))
    keyboard;
end

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
