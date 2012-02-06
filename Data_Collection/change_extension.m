function change_extension(imdir, org, to)
files = dir([imdir '/*.' org]);
for i = 1:length(files)
    src = fullfile(imdir, files(i).name);
    
    idx = find(src == '.', 1, 'last');
    
    dest = [src(1:idx) to];
    
    unix(['git mv ' src ' ' dest]);
%     movefile(src, dest);
end
end