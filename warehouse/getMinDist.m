function mindist = getMinDist(SaveStruct, j)

minx = SaveStruct.minx;
maxx = SaveStruct.maxx;
miny = SaveStruct.miny;
maxy = SaveStruct.maxy;
pos = SaveStruct.objects(j).location;

objMin = min(pos, [], 2);
objMax = max(pos, [], 2);

mindist = SaveStruct.scale*min([abs(objMin(1) - minx), ...
                                abs(objMin(2) - miny), ...
                                abs(objMax(1) - maxx), ...
                                abs(objMax(2) - maxy)]);

end