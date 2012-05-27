function params = appendITMtoParams(params, ptns)

%%%
params.model.itmptns = ptns;
params.model.itmbase = zeros(1, length(ptns));
params.model.itmfeatlen = zeros(1, length(ptns));

for i = 1:length(ptns)
    params.model.itmptns(i).type = params.model.nobjs + i;
    
    params.model.itmfeatlen(i) = ptns(i).numparts * 3 + 8;
    if(i < length(ptns))
        params.model.itmbase(i + 1) = params.model.itmbase(i) + params.model.itmfeatlen(i);
    end
end

end