function verify_image(source_dir, dest_dir, ext)
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
    
    im = imread(imfile);
    if(size(im, 1) < 300 || size(im, 2) < 400)
        disp(['image ' imfile ' is too small ' num2str(size(im, 2)) ' by ' num2str(size(im, 1)) '. Skipping...']);
    end
    
    imshow(im);
    r = input('store image? (y/n)', 's');
    if(lower(r) == 'y')
        copyfile(imfile, dest);
    else
    end
end

end