function generatTrainData(roomname)
rootdir = 'traindata4';
params = initparam(3, 5);

load(['../Results/layout/' roomname '/res_set_jpg.mat']);

imdir = fullfile('../Data_Collection', roomname);
imfiles = dir(fullfile(imdir, '*.jpg'));

detdir = fullfile('../Detector/results/DPM_MINE_AUG/', roomname);
detfiles = dir(fullfile([detdir '/sofa'], '*.mat'));

annodir = fullfile('../Annotation', roomname);
%%
dirname = fullfile(rootdir, roomname);
if exist(dirname, 'dir')
    unix(['rm -rf ' dirname]);
end
mkdir(dirname);
data = struct(  'x', cell(length(imfiles), 1), 'anno', cell(length(imfiles), 1), ...
                'iclusters',  cell(length(imfiles), 1), 'gpg',  cell(length(imfiles), 1));
for i = 1:length(imfiles)
    try
        annofile = [imfiles(i).name(1:find(imfiles(i).name == '.', 1, 'last')-1) '_labels.mat'];
        [data(i).x, data(i).anno] = readOneImageObservationData(fullfile(imdir, imfiles(i).name), ...
                                                {fullfile([detdir '/sofa'], detfiles(i).name), ...
                                                fullfile([detdir '/table'], detfiles(i).name), ...
                                                fullfile([detdir '/chair'], detfiles(i).name), ...
                                                fullfile([detdir '/bed'], detfiles(i).name), ...
                                                fullfile([detdir '/diningtable'], detfiles(i).name)}, ...
                                                boxlayout{i}, vpdata{i}, fullfile(annodir, annofile));
                                            
        [data(i).iclusters] = clusterInteractionTemplates(data(i).x, params.model);
        data(i).gpg = getGTparsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
    end
end
disp('done');
for i = 1:length(imfiles)
    temp = data(i);
    save([dirname '/data' num2str(i, '%03d')], '-struct', 'temp');
end
