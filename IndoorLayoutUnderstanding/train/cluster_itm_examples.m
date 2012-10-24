function [clusters] = cluster_itm_examples(itm_examples)

if(1)
    clusters = 1:length(itm_examples);
    for i = 1:length(itm_examples)
        azimuth = get_closest(-2*pi:pi/4:7*pi/4, itm_examples(i).azimuth);
        if(azimuth < 0)
            azimuth = azimuth + 2 * pi;
        end
        assert(azimuth < 2 * pi);
        clusters(i) = (azimuth * 4 / pi) + 1;
    end
else
    %cnt = 1;
    % pdist = zeros(1, length(itm_examples) * (length(itm_examples) - 1) / 2);
    % pdist = zeros(length(itm_examples), length(itm_examples));
    pdist = inf(length(itm_examples), length(itm_examples));
    for i = 1:length(itm_examples)
        for j = i+1:length(itm_examples)
            pdist(i, j) = get_layout_dist(itm_examples(i), itm_examples(j));
            % pdist(j, i) = pdist(i, j);
            %pdist(cnt) = get_layout_dist(itm_examples(i), itm_examples(j));
            %cnt = cnt + 1;
        end
    end

    nparts = size(itm_examples(1).objboxes, 2);
    clusters = 1:length(itm_examples);
    for i = 2:length(itm_examples)
        [val, idx] = min(pdist(1:i, i));
        if(val < 1 * nparts)
            clusters(i) = clusters(idx);
        end
    %     for j = i+1:length(itm_examples)
    %         if(pdist(i, j) < 0.7 * nparts)
    %             idx = find(clusters == )
    %         end
    %     end
    end

end

end

function [dist] = get_layout_dist(e1, e2)

dist = 0;

diag1 = sqrt( (e1.bbox(3) - e1.bbox(1) + 1).^2 + (e1.bbox(4) - e1.bbox(2) + 1).^2);
diag2 = sqrt( (e2.bbox(3) - e2.bbox(1) + 1).^2 + (e2.bbox(4) - e2.bbox(2) + 1).^2);

for i = 1:size(e1.objboxes, 2)
    bbox1 = e1.objboxes(:, i);
    bbox2 = e2.objboxes(:, i);
    
    bbox1(1) = (bbox1(1) - e1.bbox(1)) / diag1;
    bbox1(3) = (bbox1(3) - e1.bbox(1)) / diag1;
    bbox1(2) = (bbox1(2) - e1.bbox(2)) / diag1;
    bbox1(4) = (bbox1(4) - e1.bbox(2)) / diag1;
    
    
    bbox2(1) = (bbox2(1) - e2.bbox(1)) / diag2;
    bbox2(3) = (bbox2(3) - e2.bbox(1)) / diag2;
    bbox2(2) = (bbox2(2) - e2.bbox(2)) / diag2;
    bbox2(4) = (bbox2(4) - e2.bbox(2)) / diag2;
    
    dist = dist - log(boxoverlap(bbox1' .* 100, bbox2'  .* 100));
end

% if(dist < 0.7 * size(e1.objboxes, 2))
%     cols = {'r' 'g' 'b' 'k' 'm'};
%     subplot(121);
%     imshow(e1.imfile);
%     for i = 1:size(e1.objboxes, 2)
%         rectangle('position', bbox2rect(e1.objboxes(:, i)), 'linewidth', 2, 'edgecolor', cols{i});
%     end
%     subplot(122);
%     imshow(e2.imfile);
%     for i = 1:size(e2.objboxes, 2)
%         rectangle('position', bbox2rect(e2.objboxes(:, i)), 'linewidth', 2, 'edgecolor', cols{i});
%     end
% end

end