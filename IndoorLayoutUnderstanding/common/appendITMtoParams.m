function params = appendITMtoParams(params, ptns)

%%%
params.model.itmptns = ptns;
params.model.itmbase = zeros(1, length(ptns));
params.model.itmfeatlen = zeros(1, length(ptns));

params.model.itm_map = [];
for i = 1:length(ptns)
    params.model.itm_map(params.model.itmptns(i).type) = i;
    %params.model.itmptns(i).type = params.model.nobjs + i;
    if ~isfield(params.model.itmptns(i), 'wobs')
        params.model.itmptns(i).obs = [0, 0];
    end
    
    params.model.itmfeatlen(i) = ptns(i).numparts * 3 + 8 + 2;
    if(i < length(ptns))
        params.model.itmbase(i + 1) = params.model.itmbase(i) + params.model.itmfeatlen(i);
    end
end

end