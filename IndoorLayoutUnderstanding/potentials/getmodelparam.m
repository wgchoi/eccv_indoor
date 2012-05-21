function model = getmodelparam(model, w)

if(~isfield(model, 'feattype') || strcmp(model.feattype, 'type1'))
    model = getmodelparam1(model, w);
elseif(strcmp(model.feattype, 'type2'))
    model = getmodelparam2(model, w);
elseif(strcmp(model.feattype, 'type3'))
    model = getmodelparam3(model, w);    
end

end


function model = getmodelparam3(model, w)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object pairs : 2D bboverlap
            (length(model.ow_edge) - 1) + ... % object inclusion : 3D volume intersection
            1 + ...       % projection-deformation cost
            1 + ...       % floor distance
            2 * model.nobjs;      % object confidence : (weight + bias) per type

assert(length(w) == featlen);

ibase = 1;
model.w_or = w(ibase);
ibase = ibase + 1;

model.w_ioo = w(ibase:ibase+1);
ibase = ibase + 2;

model.w_ior = w(ibase:ibase+length(model.ow_edge)-2);
ibase = ibase + length(model.ow_edge) - 1;

model.w_iod = w(ibase);
ibase = ibase + 1;

model.w_iof = w(ibase);
ibase = ibase + 1;

model.w_oo = w(ibase:ibase+2*model.nobjs-1);
ibase = ibase + 2 * model.nobjs;
assert(featlen == ibase - 1);

end


function model = getmodelparam2(model, w)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object pairs : 1) 3D intersection 2) 2D bboverlap
            3 * (length(model.ow_edge) - 1) + ... % object inclusion : 3D volume intersection
            model.nobjs + ... % min distance to wall 3D
            model.nobjs + ... % min distance to wall 2D
            model.nobjs + ... % floor distance per object: sofa to floor
            2 * model.nobjs;      % object confidence : (weight + bias) per type
assert(length(w) == featlen);

ibase = 1;
model.w_or = w(ibase);
ibase = ibase + 1;

model.w_ioo = w(ibase:ibase+1);
ibase = ibase + 2;

model.w_ior = w(ibase:ibase + 3 * (length(model.ow_edge) - 1) - 1);
ibase = ibase + 3 * (length(model.ow_edge) - 1);

model.w_iow3 = w(ibase:ibase+model.nobjs-1);
ibase = ibase + model.nobjs;

model.w_iow2 = w(ibase:ibase+model.nobjs-1);
ibase = ibase + model.nobjs;

model.w_iof = w(ibase:ibase+model.nobjs-1);
ibase = ibase + model.nobjs;

model.w_oo = w(ibase:ibase+2*model.nobjs-1);
ibase = ibase+2*model.nobjs;

assert(featlen == ibase - 1);
end

function model = getmodelparam1(model, w)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object pairs : 1) 3D intersection 2) 2D bboverlap
            5 + ... % object inclusion : 3D volume intersection
            model.nobjs + ... % min distance to wall 3D
            model.nobjs + ... % min distance to wall 2D
            model.nobjs + ... % floor distance per object: sofa to floor
            2 * model.nobjs;      % object confidence : (weight + bias) per type
assert(length(w) == featlen);

ibase = 1;
model.w_or = w(ibase);
ibase = ibase + 1;

model.w_ioo = w(ibase:ibase+1);
ibase = ibase + 2;

model.w_ior = w(ibase:ibase+4);
ibase = ibase + 5;

model.w_iow3 = w(ibase:ibase+model.nobjs-1);
ibase = ibase + model.nobjs;

model.w_iow2 = w(ibase:ibase+model.nobjs-1);
ibase = ibase + model.nobjs;

model.w_iof = w(ibase:ibase+model.nobjs-1);
ibase = ibase + model.nobjs;

model.w_oo = w(ibase:ibase+2*model.nobjs-1);
ibase = ibase+2*model.nobjs;

assert(featlen == ibase - 1);
end