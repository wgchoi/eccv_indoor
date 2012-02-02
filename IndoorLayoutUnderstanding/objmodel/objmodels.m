function model = objmodels()

model = struct('name', cell(1, 0), 'type', cell(1, 0), ...
                'width', cell(1, 0), 'height', cell(1, 0), 'depth', cell(1, 0), ...
                'grounded', cell(1, 0));

model(1).name = 'Sofa';
model(1).type = {'Wide' 'Mid' 'Narrow'};
model(1).width = [1.4 1.0 .6];
model(1).height = [0.6 0.6 0.6];
model(1).depth = [0.6 0.6 0.6];
model(1).grounded = 1;

model(2).name = 'Table';
model(2).type = {'Wide' 'Square'};
model(2).width = [1.0 0.5];
model(2).height = [0.3 0.3];
model(2).depth = [0.5 0.5];
model(2).grounded = 1;

end
