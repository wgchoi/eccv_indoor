function showModel(params)

close all;

w = getweights(params.model);
plot(w, 'b.-', 'linewidth', 2, 'markersize', 20);
set(gca, 'XTick', 1:length(w));
set(gca, 'XTickLabel', {'scene' '3D o' '2D o' 'Floor-O' 'Center-O' 'Left-O' 'Right-O' 'Ceil-O' ...
                        '3D-Wall1' '3D-Wall2' '2D-Wall1' '2D-Wall1' 'Floor dist 1' 'Floor dist 2' ...
                        'Score 1' 'Bias 1' 'Score 2' 'Bias 2'});

rotateXLabels(gca, 45);

title('model weights');
grid on;

end