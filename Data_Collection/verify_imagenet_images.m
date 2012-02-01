function verify_imagenet_images(source_dir, anno_dir, dest_dir, ext, synset, objname)
images = dir(fullfile(source_dir, ['*.' ext]));

if ~exist(dest_dir, 'dir')
    mkdir(dest_dir);
end

for i = 1:length(images)
    imfile = fullfile(source_dir, images(i).name);
    dest = fullfile(dest_dir, images(i).name);
    
    if exist(dest, 'file')
        continue;
    end
    
    xmlfile = fullfile(anno_dir, [images(i).name(1:end-4) 'xml']);
    if exist(xmlfile, 'file')
        showVOCbboxes(imfile, xmlfile, 1, synset, objname);
    else
        imshow(imfile);
    end
    r = input('store image? (y/n)', 's');
    if(lower(r) == 'y')
        copyfile(imfile, dest);
    else
    end
end

end