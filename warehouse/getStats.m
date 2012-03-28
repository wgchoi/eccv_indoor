clear all
close all

SW = [];
TW = [];
TVW = [];
CW = [];
SSD = [];
SSP = [];
STD = [];
STP = [];
STVD = [];
STVP = [];
SCD = [];
SCP = [];
TTD = [];
TTP = [];
TTVD = [];
TTVP = [];
TCD = [];
TCP = [];
TVCD = [];
TVCP = [];
CCD = [];
CCP = [];
edgesd = 0:0.5:5;
edgesp = 0:4;
for i = 1:26
%     if i == 25
%         continue
%     end
    load(strcat('E:\directed study\warehouse\Structures\objects\', num2str(i), '.mat'));
    for j = 1:length(SaveStruct.objects)
        type = SaveStruct.objects(j).type;
        mindist = getMinDist(SaveStruct, j);
        switch(type)
            case 1
                SW = [SW mindist];
                disp(i)
            case 2
                TW = [TW mindist];
            case 3
                TVW = [TVW mindist];
            case 4
                CW = [CW mindist];
        end
    end
    for j = 1:length(SaveStruct.objects)-1
        for k = j+1:length(SaveStruct.objects)
            [dist pose] = getRelativeDistPose(SaveStruct, j, k);
            types = strcat(num2str(SaveStruct.objects(j).type), num2str(SaveStruct.objects(k).type));
            switch(types)
                case{'11'}
                    SSD = [SSD dist];
                    SSP = [SSP pose];
                case{'12', '21'}
                    STD = [STD dist];
                    STP = [STP pose];
                case{'13', '31'}
                    STVD = [STVD dist];
                    STVP = [STVP pose];
                    if i == 21
                        disp(pose)
                    end
                case{'14', '41'}
                    SCD = [SCD dist];
                    SCP = [SCP pose];
                case{'22'}
                    TTD = [TTD dist];
                    TTP = [TTP pose];
                case{'23', '32'}
                    TTVD = [TTVD dist];
                    TTVP = [TTVP pose];
                case{'24', '42'}
                    TCD = [TCD dist];
                    TCP = [TCP pose];
                case{'34', '43'}
                    TVCD = [TVCD dist];
                    TVCP = [TVCP pose];
                case{'44'}
                    CCD = [CCD dist];
                    CCP = [CCP pose];
            end
        end
    end
end

SWhist = histc(SW, edgesd);
TWhist = histc(TW, edgesd);
TVWhist = histc(TVW, edgesd);
CWhist = histc(CW, edgesd);
figure(1);
subplot(221), bar(edgesd, SWhist),
title(strcat('Closest distance from sofa to wall. \newline\mu = ', num2str(mean(SW)), ', \sigma = ', num2str(std(SW))), 'FontSize', 14);
subplot(222), bar(edgesd, TWhist), 
title(strcat('closest distance from table to wall. \newline\mu = ', num2str(mean(TW)), ', \sigma = ', num2str(std(TW))), 'Fontsize', 14);
subplot(223), bar(edgesd, TVWhist), 
title (strcat('closest distance from TV to wall. \newline\mu = ', num2str(mean(TVW)), ', \sigma = ', num2str(std(TVW))), 'Fontsize', 14);
subplot(224), bar(edgesd, CWhist), 
title(strcat('closest distance from chair to wall. \newline\mu = ', num2str(mean(CW)), ', \sigma = ', num2str(std(CW))), 'Fontsize', 14);

SSDhist =histc(SSD, edgesd);
STDhist =histc(STD, edgesd);
STVDhist =histc(STVD, edgesd);
SCDhist =histc(SCD, edgesd);
TTDhist =histc(TTD, edgesd);
TTVDhist =histc(TTVD, edgesd);
TCDhist =histc(TCD, edgesd);
TVCDhist =histc(TVCD, edgesd);
CCDhist =histc(CCD, edgesd);

SSPhist =histc(SSP, edgesp);
STPhist =histc(STP, edgesp);
STVPhist =histc(STVP, edgesp);
SCPhist =histc(SCP, edgesp);
TTPhist =histc(TTP, edgesp);
TTVPhist =histc(TTVP, edgesp);
TCPhist =histc(TCP, edgesp);
TVCPhist =histc(TVCP, edgesp);
CCPhist =histc(CCP, edgesp);

figure(2);
subplot(221),bar(edgesd, SSDhist), 
title(strcat('sofa-sofa distance. \newline\mu = ', num2str(mean(SSD)), ', \sigma = ', num2str(std(SSD))), 'Fontsize', 14);
subplot(222),bar(edgesd, STDhist), 
title(strcat('sofa-table distance. \newline\mu = ', num2str(mean(STD)), ', \sigma = ', num2str(std(STD))), 'Fontsize', 14);
subplot(223),bar(edgesd, STVDhist), 
title(strcat('sofa-TV distance. \newline\mu = ', num2str(mean(STVD)), ', \sigma = ', num2str(std(STVD))), 'Fontsize', 14);
subplot(224),bar(edgesd, SCDhist), 
title(strcat('sofa-chair distance. \newline\mu = ', num2str(mean(SCD)), ', \sigma = ', num2str(std(SCD))), 'Fontsize', 14);
figure(3);
subplot(221),bar(edgesd, TTDhist), 
title(strcat('table-table distance. \newline\mu = ', num2str(mean(TTD)), ', \sigma = ', num2str(std(TTD))), 'Fontsize', 14);
subplot(222),bar(edgesd, TTVDhist), 
title(strcat('table-TV distance. \newline\mu = ', num2str(mean(TTVD)), ', \sigma = ', num2str(std(TTVD))), 'Fontsize', 14);
subplot(223),bar(edgesd, TCDhist), 
title(strcat('table-chair distance. \newline\mu = ', num2str(mean(TCD)), ', \sigma = ', num2str(std(TCD))), 'Fontsize', 14);
figure(4)
subplot(211),bar(edgesd, TVCDhist), 
title(strcat('TV-chair distance. \newline\mu = ', num2str(mean(TVCD)), ', \sigma = ', num2str(std(TVCD))), 'Fontsize', 14);
subplot(212),bar(edgesd, CCDhist), 
title(strcat('chair-chair distance. \newline\mu = ', num2str(mean(CCD)), ', \sigma = ', num2str(std(CCD))), 'Fontsize', 14);

figure(5);
subplot(221),bar(edgesp, SSPhist), 
title('sofa-sofa pose', 'FontSize', 14);
subplot(222),bar(edgesp, STPhist), 
title('sofa-table pose', 'FontSize', 14);
subplot(223),bar(edgesp, STVPhist), 
title('sofa-TV pose', 'FontSize', 14);
subplot(224),bar(edgesp, SCPhist), 
title('sofa-chair pose', 'FontSize', 14);
figure(6);
subplot(221),bar(edgesp, TTPhist), 
title('table-table pose', 'FontSize', 14);
subplot(222),bar(edgesp, TTVPhist), 
title('table-TV pose', 'FontSize', 14);
subplot(223),bar(edgesp, TCPhist), 
title('table-chair pose', 'FontSize', 14);
figure(7)
subplot(211),bar(edgesp, TVCPhist), 
title('TV-chair pose', 'FontSize', 14);
subplot(212),bar(edgesp, CCPhist), 
title('chair-chair pose', 'FontSize', 14);
% figure(1), hist(SW, edges);
% figure(2), hist(TW, edges);
% figure(3), hist(TVW, edges);
% figure(4), hist(CW, edges);