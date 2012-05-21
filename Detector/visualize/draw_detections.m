function draw_detections(im, dets, tops, th, names, poses, cols)

imshow(im);
hold on;
for i = 1:length(dets)
	odets = dets{i}(tops{i}, :);

	for j = 1:size(odets, 1)
		if(odets(j, 6) <= th)
			continue;
		end

		bbox = odets(j, :);
		bbox(3) = bbox(3) - bbox(1) + 1;
		bbox(4) = bbox(4) - bbox(2) + 1;

		rectangle('position', bbox(1:4), 'linewidth', 2, 'edgecolor', cols(i));
		text(bbox(1), bbox(2), [names{i} ':' poses{i}{bbox(5)}], 'backgroundcolor', 'w');
	end
end
hold off;

end
