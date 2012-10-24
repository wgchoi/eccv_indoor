function in = inlist(list, string)

for i = 1:length(list)
    if(strcmp(list{i}, string))
        in = true;
        return
    end
end
in = false;

end