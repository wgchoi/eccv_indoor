function showVOCbboxes(imfile, annofile, figid, synset, objname)
figure(figid);
imshow(imfile);
addpath('vocreader')

a = VOCreadxml(annofile);
objs = a.annotation.object;
for i = 1:length(objs)
    if(strcmp(objs(i).name, synset))
        rt = bndbox2rect(objs(i).bndbox);
        rectangle('position', rt, 'linewidth', 2, 'edgecolor', 'w')
        text(rt(1) + 5, rt(2) + 10, objname, 'color', 'k', 'backgroundcolor', 'w')
    end
end

end

function rect = bndbox2rect(bb)
rect(1) = str2double(bb.xmin);
rect(2) = str2double(bb.ymin);
rect(3) = str2double(bb.xmax) - str2double(bb.xmin) + 1;
rect(4) = str2double(bb.ymax) - str2double(bb.ymin) + 1;
end