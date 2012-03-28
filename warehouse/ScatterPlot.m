% Scatter plots

clear all
close all

Sofa = []; Table = []; TV = []; Chair = []; Bed = [];
SofaPose = []; TablePose = []; TVPose = []; ChairPose = []; BedPose = [];
cpose = [-pi/2, -3*pi/4, -pi, 3*pi/4, pi/2, pi/4, 0, -pi/4]; 
for i = 1:22
    load(strcat('E:\directed study\warehouse\BedroomStructs\objects\', num2str(i), '.mat'));
    for j = 1:length(SaveStruct.objects)
        type = SaveStruct.objects(j).type;
        Maxx = SaveStruct.maxx;
        Maxy = SaveStruct.maxy;
        Minx = SaveStruct.minx;
        Miny = SaveStruct.miny;
        switch(type)
            case 1
                centroids = mean(SaveStruct.objects(j).location, 2);
                Sofa  = [Sofa (centroids(1:2, 1)-[Minx; Miny])./abs([Maxx-Minx; Maxy-Miny])];
                SofaPose = [SofaPose cpose(SaveStruct.objects(j).orientation)];
                if Sofa(2, end) < 0
                    disp(i)
                    disp(size(Sofa, 2))
                end
            case 2
                centroids = mean(SaveStruct.objects(j).location, 2);
                Table = [Table (centroids(1:2, 1)-[Minx; Miny])./abs([Maxx-Minx; Maxy-Miny])];
                TablePose = [TablePose cpose(SaveStruct.objects(j).orientation)];
            case 3
                centroids = mean(SaveStruct.objects(j).location, 2);
                TV = [TV (centroids(1:2, 1)-[Minx; Miny])./abs([Maxx-Minx; Maxy-Miny])];
                TVPose = [TVPose cpose(SaveStruct.objects(j).orientation)];
            case 4
                centroids = mean(SaveStruct.objects(j).location, 2);
                Chair = [Chair (centroids(1:2, 1)-[Minx; Miny])./abs([Maxx-Minx; Maxy-Miny])];
                ChairPose = [ChairPose cpose(SaveStruct.objects(j).orientation)];
            case 5
                centroids = mean(SaveStruct.objects(j).location, 2);
                Bed = [Bed (centroids(1:2, 1)-[Minx; Miny])./abs([Maxx-Minx; Maxy-Miny])];
                BedPose = [BedPose cpose(SaveStruct.objects(j).orientation)];
                if SaveStruct.objects(j).orientation == 8
                    disp(i)
                end
        end
    end
end

figure(1), 
subplot(221),
for i = 1:size(Sofa, 2)
    draw_target(gca, Sofa(:, i), SofaPose(i), 'b');
end
title('Pose and normalized location of sofas', 'FontSize', 14);
subplot(222),
for i = 1:size(Table, 2)
    draw_target(gca, Table(:, i), TablePose(i), 'b');
end
title('Pose and normalized location of tables', 'FontSize', 14);
subplot(223),
for i = 1:size(TV, 2)
    draw_target(gca, TV(:, i), TVPose(i), 'b');
end
title('Pose and normalized location of TVs', 'FontSize', 14);
subplot(224),
for i = 1:size(Chair, 2)
    draw_target(gca, Chair(:, i), ChairPose(i), 'b');
end
title('Pose and normalized location of chairs', 'FontSize', 14);
figure(2)
for i = 1:size(Bed, 2)
    draw_target(gca, Bed(:, i), BedPose(i), 'b');
end
title('Pose and normalized location of beds', 'FontSize', 14);