function [sets, counts] = generate_subsets( image_dir, exts, dest, ignorelist, numset)
%GENERATE_SUBSETS Summary of this function goes here
%   Generates equally distributed subsets.

total = 0;
for i = 1:length(exts)
    imfiles = dir(fullfile(image_dir, ['*.' exts{i}]));
    for j = 1:length(imfiles)
        if(in_list(ignorelist, imfiles(j).name))
            disp([imfiles(j).name ' is ignored']);
            continue;
        end
        total = total + 1;
    end
end

sets = cell(1, numset);
curset = 1;

for i = 1:length(exts)
    imfiles = dir(fullfile(image_dir, ['*.' exts{i}]));
    for j = 1:length(imfiles)
        if(in_list(ignorelist, imfiles(j).name))
            disp([imfiles(j).name ' is ignored']);
            continue;
        end
        if(length(sets{curset}) > total / numset)
            curset = curset + 1;
        end
        sets{curset}{end + 1} = imfiles(j).name;
    end
end

for i = 1:numset
    dest_dir = [dest '_' num2str(i)];
    
    if exist(dest_dir, 'dir')
        key = input('dir exist. remove? [y/n]', 's');
        if(key == 'y')
            system(['rm -rf ' dest_dir]);
        end
    end
    mkdir(dest_dir);
    
    for j = 1:length(sets{i})
        name = sets{i}{j};
        copyfile(fullfile(image_dir, name), fullfile(dest_dir, name));
    end
end

end

