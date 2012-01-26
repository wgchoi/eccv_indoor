function restore_files(listfile, indirs, destdir)

cnt = 1;
fp = fopen(listfile, 'r');
while(1)
    tline = fgets(fp);
    if ~ischar(tline)
        break;
    end
    
    idx = find(tline == '/', 1, 'last');
    fname(cnt).name = tline(idx+1:end-1);
    cnt = cnt + 1;
end
fclose(fp);

copied = zeros(1, length(fname));
for i = 1:length(indirs)
    for j = 1:length(fname)
        if(copied(j) == 1)
            continue;
        end
        
        if(exist(fullfile(indirs{i}, fname(j).name)) && ~exist(fullfile(destdir, fname(j).name)))
            copied(j) = 1;
            unix(['unset LD_LIBRARY_PATH; cp ' fullfile(indirs{i}, fname(j).name) ' ' fullfile(destdir, fname(j).name)]);
        end
    end
end

end