function data = append_ITM_detections(data, ptns, itmcache, dataidx)

assert(length(data) == length(dataidx))
for i = 1:length(dataidx)
    idx = dataidx(i);
    itm = load(fullfile(itmcache, ['data' num2str(idx, '%03d')]));
    
    assert(strcmp(data(i).x.imfile, itm.imfile));
    
    assert(length(itm.itm_type) == length(itm.names));
    itm.obs_idx(itm.itm_type) = 1:length(itm.itm_type);
    data(i).x.itms = itm;
end

end