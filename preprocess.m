function preprocess(imgbase, resbase, dataset)
% dataset = 'meeting'; % 'ECCVdata_test';
% imgbase = '~/datasets/HumanSpaceInteraction/flkr/';
% resbase = '~/datasets/HumanSpaceInteraction/cache/';
curdir = pwd();

cd UIUC_Varsha/SpatialLayout/spatiallayoutcode;
process_directory(imgbase, resbase, dataset);
cd(curdir);

cd Detector;
process_detector(fullfile(imgbase, dataset), fullfile(resbase, dataset));
cd(curdir);

cd IndoorLayoutUnderstanding/
preprocess_data(imgbase, resbase, dataset);
cd(curdir);

end