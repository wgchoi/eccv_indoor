for i = 1:22
% --------- For living room
%     if i ~= 24 && i ~= 25
%         scale = 0.0254;
%     elseif i == 24
%         scale = 0.01;
%     else
%         scale = 1;
%     end

% --------- For Bedroom
if i ~= 18 && i <= 20 %i ~= 20 && i ~= 21
    scale = 0.0254;
else
    scale = 0.001;
end
    
    load(strcat('E:\directed study\warehouse\BedroomStructs\objects\', num2str(i), '.mat'));
%     disp(i);
%     disp(SaveStruct.scale);
    SaveStruct.scale = scale;
    save(strcat('E:\directed study\warehouse\BedroomStructs\objects\', num2str(i), '.mat'), 'SaveStruct');
end