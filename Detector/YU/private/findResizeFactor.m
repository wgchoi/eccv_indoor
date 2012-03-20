function factor = findResizeFactor(fnames, factors, filename)
factor = nan;
for i = 1:length(fnames)
    if compare_file_name(fnames{i}, filename)
        factor = factors(i);
        return;
    end
end
end