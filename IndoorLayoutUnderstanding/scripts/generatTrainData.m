clear
clc

load tempvar
load ../Results/layout/livingroom/res_set_jpg.mat
% mkdir tempdata3
%%
errid = [];
for i = 1:length(imfiles)
    try
        if(exist(['./tempdata2/train' num2str(i, '%03d') '.mat'], 'file'))
            continue;
        end
        i
        annofile = [imfiles(i).name(1:find(imfiles(i).name == '.', 1, 'last')-1) '_labels.mat'];
        [x, anno] = readOneImageObservationData(fullfile(imdir, imfiles(i).name), {fullfile([detdir '/sofa'], detfiles(i).name) fullfile([detdir '/table'], detfiles(i).name)}, boxlayout{i}, vpdata{i}, fullfile(annodir, annofile));
        [iclusters] = clusterInteractionTemplates(x, params.model);
        gpg = getGTparsegraph(x, iclusters, anno, params.model);
        for j = 1:length(gpg.childs)
            assert(sum(isnan(x.cubes{gpg.childs(j)}(:))) == 0);
        end
%         pg = gpg;
%         pg = findConsistent3DObjects(pg, x);
%         show2DGraph(pg, x, iclusters); 
%         show3DGraph(pg, x, iclusters); 
%         drawnow
        save(['./tempdata2/train' num2str(i, '%03d')], 'x', 'anno', 'iclusters', 'gpg');
    catch ee
        ee
        errid(end+1) = i;
    end
end
%%
% for i = 1:length(nonerridx)
%     load(['./tempdata2/train' num2str(nonerridx(i), '%03d')], 'x', 'anno', 'iclusters', 'gpg');
%     gpg = getGTparsegraph(x, iclusters, anno, params.model);
%     show2DGraph(gpg, x, iclusters);
%     pause;
% end