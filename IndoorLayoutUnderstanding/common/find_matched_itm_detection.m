function [dets, overlap]= find_matched_itm_detection(type, itms, bbox, azimuth)

dets = [];
overlap = 0;

obsidx = itms.obs_idx(type);
if(obsidx == 0) % no detector trained
    return;
end

itmbox = itms.bbox{obsidx};
if(isempty(itmbox))
    return;
end
top = itms.top2{obsidx};
itmbox = itmbox(top, :);

az = floor(azimuth / pi * 180);
poseidx = find_interval(az, 8);
idx = find(itmbox(:, 5) == poseidx);

ov = boxoverlap(itmbox(idx, 1:4), bbox);
[val, maxidx] = max(ov);
if(val > 0.4)
    dets = itmbox(idx(maxidx), :);
    overlap = val;
end

end