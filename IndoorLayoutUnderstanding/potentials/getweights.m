% should be paired with features.m
function w = getweights(model)
featlen =   1 + ... % layout confidence : no bias required, selection problem    
            2 + ... % object pairs : 1) 3D intersection 2) 2D bboverlap
            5 + ... % object inclusion : 3D volume intersection
            1 + ... % floor distance : sofa to floor
            2;      % object confidence : (weight + bias) per type

w = zeros(featlen, 1);
ibase = 1;
w(ibase) = model.w_or;
ibase = ibase + 1;

w(ibase:ibase+1) = model.w_ioo;
ibase = ibase + 2;

w(ibase:ibase+4) = model.w_ior;
ibase = ibase + 5;

w(ibase) = model.w_iof;
ibase = ibase + 1;

w(ibase:ibase+1) = model.w_oo;
ibase = ibase + 1;

end