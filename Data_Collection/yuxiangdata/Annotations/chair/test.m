function test

for i = 1:770
    disp(i);
    file = sprintf('%04d.mat', i);
    image = load(file);
    if isfield(image.object, 'leg4') == 0
        disp('error!');
        return;
    end
end