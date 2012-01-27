function model = objmodels()

model = struct('name', cell(1, 0), 'type', cell(1, 0), 'width', cell(1, 0), 'height', cell(1, 0), 'depth', cell(1, 0));

model(1).name = 'Sofa';
model(1).type = {'Wide' 'Narrow'};
model(1).width = [1.4 .6];
model(1).height = [0.6 0.6];
model(1).depth = [0.6 0.6];

model(2).name = 'Table';
model(2).type = {'Wide'};
model(2).width = [1.0];
model(2).height = [0.4];
model(2).depth = [0.4];

end
