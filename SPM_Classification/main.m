close all; clear; clc;

addpath('SpatialPyramid/');
addpath('libsvm-3.11/matlab/');
addpath('scene_categories/');

image_dir = 'scene_categories/'; 
data_dir = 'cache/scene_categories/';
% image_dir = 'nips_trial1/'; 
% data_dir = 'cache/nips_trial1/';

LISTclass = dir(image_dir);
LISTclass = LISTclass(3:end);               % Remove '.' and '..'
NUMclass = length(LISTclass);

for cls = 1:NUMclass
    
    LISTclass(cls).fnames = dir(fullfile(image_dir, LISTclass(cls).name, '*.jpg'));
    LISTclass(cls).fnum = length(LISTclass(cls).fnames);
    
end

%% Set parameters
params.maxImageSize = 1000;
params.gridSpacing = 8;
params.patchSize = 16;
params.dictionarySize = 400;
params.numTextonImages = 50;
params.pyramidLevels = 1;
params.oldSift = false;
canSkip = 1;

pfig = sp_progress_bar('Building Spatial Pyramid');

%% Generate SIFT discriptors
sift_dir = fullfile(data_dir, 'sift');

for cls = 1:NUMclass

    filenames = [];
    for f = 1:LISTclass(cls).fnum;
        filenames{f} = LISTclass(cls).fnames(f).name;
    end
   
    imageFileList = filenames;
    imageBaseDir = fullfile(image_dir, LISTclass(cls).name);
    siftBaseDir = fullfile(sift_dir, LISTclass(cls).name);
    
    GenerateSiftDescriptors(imageFileList, imageBaseDir, siftBaseDir, params, canSkip, pfig);
    
end

%% Calculate dictoinary
CalDicImNUM = 4;
dicLearn_dir = fullfile(data_dir, 'dicLearn');
BASEIMGsel = fullfile(data_dir, 'dicLearn', 'selectedIMG');
BASESIFTsel = fullfile(data_dir, 'dicLearn', 'selectedDATA');

if ~exist(BASEIMGsel,'dir')
    mkdir(BASEIMGsel);
end

if ~exist(BASESIFTsel,'dir')
    mkdir(BASESIFTsel);
end

fprintf('Selecting images for dictionary learning... (%d per class)\n\n',CalDicImNUM);

filenames = [];
for cls = 1:NUMclass
    
    imageBaseDir = fullfile(image_dir, LISTclass(cls).name);
    siftBaseDir = fullfile(sift_dir, LISTclass(cls).name);
    
    for INDimg = 1:CalDicImNUM
        
        INNAMEsel = LISTclass(cls).fnames(INDimg).name;
        OUTNAMEsel = sprintf('%s_%s',LISTclass(cls).name, INNAMEsel);
        [~,INbase] = fileparts(INNAMEsel);
        [~,OUTbase] = fileparts(OUTNAMEsel);
        
        filenames = [filenames {OUTNAMEsel}];
        
        INselIMG = fullfile(imageBaseDir, INNAMEsel);
        INselSIFT = fullfile(siftBaseDir, sprintf('%s_sift.mat',INbase));
        OUTselIMG = fullfile(BASEIMGsel, OUTNAMEsel);
        OUTselSIFT = fullfile(BASESIFTsel, sprintf('%s_sift.mat',OUTbase));
        
        if exist(OUTselIMG,'file') == 0
            unix(['cp ' INselIMG ' ' OUTselIMG]);       % Copy selected files
        end
        
        if exist(OUTselSIFT,'file') == 0
            unix(['cp ' INselSIFT ' ' OUTselSIFT]);     % Copy selected data
        end
        
    end
    
end

imageFileList = filenames;
imageBaseDir = BASEIMGsel;
siftBaseDir = BASESIFTsel;
dicBaseDir = dicLearn_dir;

params.numTextonImages = length(imageFileList);

myCalculateDictionary(imageFileList, imageBaseDir, siftBaseDir, dicBaseDir, '_sift.mat', params, canSkip, pfig);

%% Build Histograms
hist_dir = fullfile(data_dir, 'hist');
for cls = 1:NUMclass
    
    BASEhist_temp = fullfile(hist_dir, LISTclass(cls).name);
    if ~exist(BASEhist_temp,'dir')
        mkdir(BASEhist_temp);
    end
    
    filenames = [];
    for f = 1:LISTclass(cls).fnum;
        filenames{f} = LISTclass(cls).fnames(f).name;
    end

    imageFileList = filenames;
    imageBaseDir = fullfile(image_dir, LISTclass(cls).name);
    siftBaseDir = fullfile(sift_dir, LISTclass(cls).name);
    histBaseDir = BASEhist_temp;
    
    myBuildHistograms(imageFileList, imageBaseDir, siftBaseDir, dicBaseDir, histBaseDir, '_sift.mat', params, canSkip, pfig);
    
end

%% Compile Pyramid
pyramid_dir = fullfile(data_dir, 'pyramid');
textonSuffix = sprintf('_texton_ind_%d.mat',params.dictionarySize);

for cls = 1:NUMclass
    
    BASEhist_temp = fullfile(hist_dir, LISTclass(cls).name);
    BASEpyramid_temp = fullfile(pyramid_dir, LISTclass(cls).name);
    if ~exist(BASEpyramid_temp,'dir')
        mkdir(BASEpyramid_temp);
    end
    
    filenames = [];
    for f = 1:LISTclass(cls).fnum;
        filenames{f} = LISTclass(cls).fnames(f).name;
    end

    imageFileList = filenames;
    histBaseDir = BASEhist_temp;
    
    myCompilePyramid(imageFileList, histBaseDir, BASEpyramid_temp, textonSuffix, params, canSkip, pfig);
    
end

close(pfig);

%% Split data into training and test set
DATAtrain = [];
DATAtest = [];
LABELtrain = [];
LABELtest = [];

NUMtrain = 100;     % Set number of training data per class

fprintf('Splitting dataset into training and test set ...\n\n');
for cls = 1:NUMclass
    
    fprintf('Class %d: %s\n', cls, LISTclass(cls).name);
    
    pyramidBaseDir = fullfile(pyramid_dir, LISTclass(cls).name);
    NAMEpyramidall = sprintf('pyramids_all_%d_%d.mat', params.dictionarySize, params.pyramidLevels);
    PATHpyramidall = fullfile(pyramidBaseDir, NAMEpyramidall);
    
    load(PATHpyramidall);
    
    DATAtrain = [DATAtrain;pyramid_all(1:100,:)];  
    DATAtest = [DATAtest;pyramid_all(101:end,:)];
    LABELtrain = [LABELtrain; cls*ones(100,1)];
    LABELtest = [LABELtest; cls*ones(size(pyramid_all(101:end,:),1),1)];
    
end

fprintf('\n');

%% Compute histogram intersection kernel
kernelBaseDir = fullfile(data_dir, 'HIKernel');
if ~exist(kernelBaseDir,'dir')
    mkdir(kernelBaseDir);
end

NAMEkernel = sprintf('hikernel_%d_%d.mat', params.dictionarySize, params.pyramidLevels);
PATHkernel= fullfile(kernelBaseDir,NAMEkernel);

if exist(PATHkernel,'file')
    
    load(PATHkernel);
    fprintf('Loaded kernel (histogram intersection kernel) ... \n\n');
    
else
    
    fprintf('Computing histogram intersection kernel on training data ...\n');
    tic;
    K_train = hist_isect(DATAtrain, DATAtrain);
    TIMEkernel = toc;
    fprintf('Computing time: %f seconds\n\n',TIMEkernel);
    
    fprintf('Computing histogram intersection kernel on test data ...\n');
    K_test = hist_isect(DATAtest, DATAtrain);
    TIMEkernel = toc;
    fprintf('Computing time: %f seconds\n\n',TIMEkernel);
    
    save(PATHkernel,'K_train','K_test');
    
end

%% Run cross validation on parameter C
svmparBaseDir = fullfile(data_dir, 'svmpar','hist_inter_kernel');
if ~exist(svmparBaseDir,'dir')
    mkdir(svmparBaseDir);
end

NAMEsvmpar = sprintf('svmpar_%d_%d.mat', params.dictionarySize, params.pyramidLevels);
PATHsvmpar = fullfile(svmparBaseDir,NAMEsvmpar);

NUMfold = 5;                    % Set number of folds
C_cand = (10:-1:1)';            % Set candidate C value

if exist(PATHsvmpar,'file')
    
    load(PATHsvmpar);
    fprintf('Loaded parameter C\n\n');
    
else
    
    fprintf('Running cross validation on C ...\n\n');
    ACCval = zeros(length(C_cand), NUMfold);
    
    for indC = 1:length(C_cand)
        
        C_test = C_cand(indC);
        
        fprintf('C_test = %.2e\n',C_test);
        svmtrain_option = sprintf('-c %f -t 4 -q',C_test);
        
        for fold = 1:NUMfold
            
            INDval = [];
            for cls = 1:NUMclass
                INDval = [INDval (cls-1)*NUMtrain + (((fold-1)/NUMfold)*NUMtrain+1:1:(fold/NUMfold)*NUMtrain)]; 
            end
            INDtrain = 1:NUMtrain*NUMclass;
            INDtrain(INDval) = [];
            
            train_label = LABELtrain(INDtrain,:);
            val_label = LABELtrain(INDval,:);
            
            SIZEtrain = length(train_label);
            K_cv_train = K_train(INDtrain,INDtrain);
            K_cv_train_svm = [(1:SIZEtrain)', K_cv_train];
            
            SIZEval = length(val_label);
            K_cv_val = K_train(INDval,INDtrain);
            K_cv_val_svm = [(1:SIZEval)', K_cv_val];
            
            model = svmtrain(train_label, K_cv_train_svm, svmtrain_option);
            
            fprintf('fold %d, ',fold);
            [predict_label, accuracy, dec_values] = svmpredict(val_label, K_cv_val_svm, model);
            
            ACCval(indC,fold) = accuracy(1);
            
        end        
        
    end
    
    ACCcv = mean(ACCval,2);
    [acc_val,C_ind] = max(ACCcv,[],1);
    C_sel = C_cand(C_ind);    
    
    fprintf('\n');
    
    fprintf('C_sel: %f \n\n',C_sel);
    save(PATHsvmpar,'C_cand','ACCval','ACCcv','C_sel');
    
end

%% Train SVM using histogram intersection kernel
fprintf('Training multi-class SVM ...\n\n');
tic;

train_instance = DATAtrain;
train_label = LABELtrain;

SIZEtrain = length(LABELtrain);
K_train_svm = [(1:SIZEtrain)', K_train];

svmtrain_option = sprintf('-c %f -t 4',C_sel);
model = svmtrain(train_label, K_train_svm, svmtrain_option);

TIMEtrain = toc;
fprintf('\n');
fprintf('Training time: %f seconds\n\n',TIMEtrain);

%% Classify Test data using learned SVM
fprintf('Classifying test data ...\n\n');
tic;

test_instance = DATAtest;
test_label = LABELtest;

SIZEtest = length(LABELtest);
K_test_svm = [(1:SIZEtest)', K_test];

[predict_label, accuracy, dec_values] = svmpredict(test_label, K_test_svm, model);

TIMEtest = toc;
fprintf('Test time: %f seconds\n\n',TIMEtest);

NUMsuc = sum(predict_label == LABELtest);
acc = NUMsuc/SIZEtest;

fprintf('Accuracy: %f %% (%d/%d)\n\n',100*acc,NUMsuc,SIZEtest);

NAMEacc = sprintf('acc_hik_%d_%d.mat', params.dictionarySize, params.pyramidLevels);
PATHacc = fullfile(data_dir,NAMEacc);
save(PATHacc,'acc');
