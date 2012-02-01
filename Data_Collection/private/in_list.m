function bin = in_list(list, filename)

bin = 0;
for i = 1:length(list)
    if(strcmp(list{i}, filename))
        bin = 1;
        return;
    end
end

end
