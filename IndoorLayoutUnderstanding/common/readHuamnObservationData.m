function x=readHuamnObservationData(imfile, detfile, x)
data = load(detfile);
dets = parseDets(data);

if(~useoldver)
    [hobjs, invalid_idx] = generate_object_hypotheses(x.imfile, x.K, x.R, x.yaw, objmodels(), dets);
    hobjs(invalid_idx) = []; dets(invalid_idx, :) = [];

    x.hobjs(ocnt+1:ocnt+length(hobjs)) = hobjs;

    ocnt = ocnt + length(hobjs);
end
end

function dets = parseDets(data)

end