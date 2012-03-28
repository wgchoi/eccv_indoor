% batch convert from collada to structure

for i = 23:25
    disp(i)
    filename = strcat('E:\directed study\warehouse\Collada\bedroom\', num2str(i), '.dae');
    Objects = getObjectsFromCollada(filename);
%     save(strcat('E:\directed study\warehouse\BedroomStructs\', num2str(i), '.mat'), 'Objects');
end