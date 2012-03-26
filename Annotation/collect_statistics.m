clear


objtypes = {'Sofa', 'Table', 'TV', 'Chair', 'Bed'};
subtypes = [2 2 2 1 3];
az_sets = [- pi / 8, pi / 8; ...
           1 * pi / 8, 3 * pi / 8; ...
           3 * pi / 8, 5 * pi / 8; ...
           5 * pi / 8, 7 * pi / 8; ...
           7 * pi / 8, 9 * pi / 8; ...
           -7 * pi / 8, -5 * pi / 8; ...
           -5 * pi / 8, -3 * pi / 8; ...
           -3 * pi / 8, -1 * pi / 8];
       
dset = 'livingroom';

for o = 1:length(objtypes)
    for s = 1:subtypes(o)
        for az = 1:size(az_sets, 1)
            try
                [im, spos] = collect_object_images(['../Data_Collection/' dset '/'], ['./' dset '/'], o, s, az_sets(az, :));
                imwrite(im, fullfile('datastat', [dset '_o' objtypes{o} '_s' num2str(s) '_p' num2str(az) '.jpg']), 'JPEG');
                save(fullfile('datastat', [dset '_o' objtypes{o} '_s' num2str(s) '_p' num2str(az)]), 'spos', 'im');
            catch err
                err
            end
        end
    end
end

%% 
count = zeros(size(az_sets, 1), max(subtypes), length(objtypes));
for o = 1:length(objtypes)
    for s = 1:subtypes(o)
        for az = 1:size(az_sets, 1)
            load(fullfile('datastat', [dset '_o' objtypes{o} '_s' num2str(s) '_p' num2str(az)]), 'spos');
            count(az,s,o) = length(spos);
        end
    end
end