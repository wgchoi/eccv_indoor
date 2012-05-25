function model = objmodels()

model = struct('name', cell(1, 0), 'type', cell(1, 0), ...
                'width', cell(1, 0), 'height', cell(1, 0), 'depth', cell(1, 0), ...
                'grounded', cell(1, 0));

model(1).name = 'Sofa';
model(1).type = {'Wide' 'Narrow'};
model(1).width = [1.8 .9];
model(1).height = [0.8 0.8];
model(1).depth = [0.8 0.8];
model(1).grounded = 1;

model(2).name = 'Table';
model(2).type = {'Wide' 'Square'};
model(2).width = [1.2 0.8];
model(2).height = [0.4 0.4];
model(2).depth = [0.75 0.8];
model(2).grounded = 1;

model(3).name = 'TV';
model(3).type = {'Flat' 'CRT'};
model(3).width = [0.8, 0.5];
model(3).height = [0.4, 0.5];
model(3).depth = [0.2, 0.3];
model(3).grounded = 0;

model(4).name = 'Chair';
model(4).type = {'Regular'};
model(4).width = [0.5];
model(4).height = [1.0];
model(4).depth = [0.5];
model(4).grounded = 1;

model(5).name = 'Bed';
model(5).type = {'Full', 'Queen', 'King'};
model(5).width = [1.5, 1.6, 2.1];
model(5).height = [1.3, 1.3, 1.3];
model(5).depth = [2.0, 2.1, 2.2];
model(5).grounded = 1;

model(6).name = 'Dining Table';
model(6).type = {'Wide' 'Square'};
model(6).width = [1.2 0.8];
model(6).height = [0.75 0.75];
model(6).depth = [0.75 0.8];
model(6).grounded = 1;

model(7).name = 'Side Table';
model(7).type = {'Wide' 'tall'};
model(7).width = [0.55 0.35];
model(7).height = [0.6 0.6];
model(7).depth = [0.4 0.35];
model(7).grounded = 1;

end
