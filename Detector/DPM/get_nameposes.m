function [names, poses] = get_nameposes()
pose8 = {'f' 'fr' 'r' 'br' 'b' 'bl' 'l' 'fl'};
pose24 = {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10' '11' '12' ...
		 '13' '14' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24'};

idx = 1;
names{idx} = 'sofa8';
poses{idx} = pose8;

idx = idx + 1;
names{idx} = 'sofa24';
poses{idx} = pose24;

idx = idx + 1;
names{idx} = 'table8';
poses{idx} = pose8;

idx = idx + 1;
names{idx} = 'table24';
poses{idx} = pose24;

idx = idx + 1;
names{idx} = 'bed8';
poses{idx} = pose8;

idx = idx + 1;
names{idx} = 'bed24';
poses{idx} = pose24;

idx = idx + 1;
names{idx} = 'chair8';
poses{idx} = pose8;

idx = idx + 1;
names{idx} = 'chair24';
poses{idx} = pose24;

end
