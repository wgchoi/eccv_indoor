function [ifeat, cloc, theta, dloc, dpose] = getITMfeat(ptn, locs, model)
% (dx^2, dz^2, da^2) * n + view dependent biases
ifeat = zeros(ptn.numparts * 3 + 8, 1);
  
partslocs = locs(:, [1 3]);
partspose = locs(:, 4);

cloc = mean(partslocs, 1);
theta = atan2(partslocs(2, 2) - partslocs(1, 2), partslocs(2, 1) - partslocs(1, 1));

R = rotationMat(theta);

dloc = ( partslocs - repmat(cloc, size(partslocs, 1), 1) ) * R;
dpose =  partspose - theta;

ibase = 0;
for i = 1:length(ptn.parts)
    ifeat(ibase + 1) = (dloc(i, 1) - ptn.parts(i).dx) ^ 2;
    ifeat(ibase + 2) = (dloc(i, 2) - ptn.parts(i).dz) ^ 2;
    
    if(model.objmodel(ptn.parts(i).citype).ori_sensitive)
        ifeat(ibase + 3) = anglediff(dpose(i), ptn.parts(i).da) ^ 2;
    else
        % ignore orientation feature.. 
        % e.g. table, dining table - no consistent pose definition
        ifeat(ibase + 3) = 0;
    end
    ibase = ibase + 3;
end

% view dependent bias
idx = getposeidx(theta, 8);
ifeat(ibase + idx) = 1;

end