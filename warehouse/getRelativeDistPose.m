function [dist pose] = getRelativeDistPose(SaveStruct, j, k)

mean1 = mean(SaveStruct.objects(j).location, 2);
mean2 = mean(SaveStruct.objects(k).location, 2);

dist = SaveStruct.scale*sqrt((mean1(1) - mean2(1))^2 + (mean1(2) - mean2(2))^2);

posearr = [0 1 2 3 4 3 2 1];

poseidx = abs(SaveStruct.objects(j).orientation - SaveStruct.objects(k).orientation);

pose = posearr(poseidx + 1);
