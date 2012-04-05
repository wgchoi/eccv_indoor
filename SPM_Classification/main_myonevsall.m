close all; clear; clc;

addpath('SpatialPyramid/');
addpath('libsvm-3.11/matlab/');
addpath('scene_categories/');

image_dir = 'scene_categories/'; 
data_dir = 'cache/';

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
params.dictionarySize = 200;
params.numTextonImages = 50;
params.pyramidLevels = 3;
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

%% Run cross validation on parameter C
svmparBaseDir = fullfile(data_dir, 'svmpar');
if ~exist(svmparBaseDir,'dir')
    mkdir(svmparBaseDir);
end

NAMEsvmpar = sprintf('svmpar_%d_%d.mat', params.dictionarySize, params.pyramidLevels);
PATHsvmpar = fullfile(svmparBaseDir,NAMEsvmpar);

NUMfold = 5;                    % Set number of folds
C_cand = 10.^(10:-1:4)';        % Set candidate C value
gamma_cand = 10.^(2:-1:-4)';    % Set candidate gamma value

if exist(PATHsvmpar,'file')    
    
    load(PATHsvmpar);
    fprintf('Loaded parameter C\n\n');
    
else
    
    %ACCval = zeros(length(C_cand), NUMfold, NUMclass);
    ACCval = zeros(length(C_cand), length(gamma_cand), NUMfold);
    %fprintf('Running cross validation on C (1-vs-all rule) ...\n\n');
    %for cls = 1:NUMclass
        
        %instance_pos = DATAtrain(LABELtrain == cls,:);
        %instance_neg = DATAtrain(LABELtrain ~= cls,:);
        %size_pos = NUMtrain;
        %size_neg = size(instance_neg,1);    
        %fprintf('Training SVM on class %d: %s ...\n\n', cls, LISTclass(cls).name);
        
        for indC = 1:length(C_cand)
        
            C_test = C_cand(indC);
            %svmtrain_option = sprintf('-c %f -t 2 -q',C_test);
            %fprintf('C_test = %.2e\n',C_test);
            
            for indgamma = 1:length(gamma_cand)
                
                gamma_test = gamma_cand(indgamma);
                fprintf('C_test = %.2e, gamma_test = %.2e\n',C_test,gamma_test);
                svmtrain_option = sprintf('-c %f -t 2 -g %d -q',C_test,gamma_test);
            
            for fold = 1:NUMfold
                
                INDval = [];
                for cls = 1:NUMclass
                    INDval = [INDval (cls-1)*NUMtrain + (((fold-1)/NUMfold)*NUMtrain+1:1:(fold/NUMfold)*NUMtrain)]; 
                end
                INDtrain = 1:NUMtrain*NUMclass;
                INDtrain(INDval) = [];
                
                %INDval_pos = ((fold-1)/NUMfold)*size_pos+1:1:(fold/NUMfold)*size_pos;
                %INDtrain_pos = 1:size_pos;
                %INDtrain_pos(INDval_pos) = [];
                %
                %INDval_neg = ((fold-1)/NUMfold)*size_neg+1:1:(fold/NUMfold)*size_neg;
                %INDtrain_neg = 1:size_neg;
                %INDtrain_neg(INDval_neg) = [];
                % 
                %train_instance_pos = instance_pos(INDtrain_pos,:);
                %train_instance_neg = instance_neg(INDtrain_neg,:);
                %val_instance_pos = instance_pos(INDval_pos,:);
                %val_instance_neg = instance_neg(INDval_neg,:);
                %                
                %train_instance = [train_instance_pos;train_instance_neg];                       % Extract training data
                %train_label = [ones(length(INDtrain_pos),1);-ones(length(INDtrain_neg),1)];     % Extract training label
                %
                %val_instance = [val_instance_pos;val_instance_neg];                             % Extract validatoin data
                %val_label = [ones(length(INDval_pos),1);-ones(length(INDval_neg),1)];           % Extract validation label
                
                train_instance = DATAtrain(INDtrain,:);
                train_label = LABELtrain(INDtrain,:);
                
                val_instance = DATAtrain(INDval,:);
                val_label = LABELtrain(INDval,:);
                
                model = svmtrain(train_label, train_instance, svmtrain_option);
                
                fprintf('fold %d, ',fold);
                [predict_label, accuracy, dec_values] = svmpredict(val_label, val_instance, model);
                %ACCval(indC,fold,cls) = accuracy(1);
                ACCval(indC,indgamma,fold) = accuracy(1);
                
            end
            
            end
        
        end
        
    %end
    
    %ACCcv = mean(ACCval,2);
    %ACCcv = permute(ACCcv,[1 3 2]);
    %
    %[acc_val,C_ind] = max(ACCcv,[],1);
    %C_sel = C_cand(C_ind);
    % % ACCcv = mean(ACCcv,2);
    % % [acc_val,C_ind] = max(ACCcv,[],1);
    % % C_sel = C_cand(C_ind);
    
    ACCcv = mean(ACCval,3);
    [r,c] = find(ACCcv == max(ACCcv(:)));   % Find maximum CV accuracy
    r = r(1);                               % Randamly pick one parameter if there are multiple
    c = c(1);                               % Randamly pick one parameter if there are multiple
    C_sel = C_cand(r);
    gamma_sel = gamma_cand(c);
    
    fprintf('\n');
    fprintf('C_sel: %f  gamma_sel: %f\n\n',C_sel,gamma_sel);
    save(PATHsvmpar,'C_cand','gamma_cand','ACCval','ACCcv','C_sel','gamma_sel');
    
end

%% Train SVM using histogram intersection kernel
%model = [];
%for cls = 1:NUMclass

    %fprintf('Training SVM for class %d (1-vs-all rule) ...\n\n',cls);
    fprintf('Training multi-class SVM ...\n\n');
    tic;
    
    train_instance = DATAtrain;
    train_label = LABELtrain;
    
    %INDpos = train_label == cls;
    %INDneg = train_label ~= cls;
    %
    %train_label(INDpos) = 1;
    %train_label(INDneg) = -1;
    
    % svmtrain_option = sprintf('-c %f -t 2',C_sel(cls));
    svmtrain_option = sprintf('-c %f -t 2 -g %d',C_sel,gamma_sel);
    %model(cls).model = svmtrain(train_label, train_instance, svmtrain_option);
    model = svmtrain(train_label, train_instance, svmtrain_option);
    
    TIMEtrain = toc;
    fprintf('\n');
    fprintf('Training time: %f seconds\n\n',TIMEtrain);
    
%end

%% Classify Test data using learned SVM
SIZEtest = length(LABELtest);
%score = zeros(SIZEtest,NUMclass);

%for cls = 1:NUMclass

    %fprintf('Classifying test data using model %d (1-vs-all rule) ...\n\n',cls);
    fprintf('Classifying test data ...\n\n');
    tic;
    
    test_instance = DATAtest;
    test_label = LABELtest;
    
    %INDpos = test_label == cls;
    %INDneg = test_label ~= cls;
    %
    %test_label(INDpos) = 1;
    %test_label(INDneg) = -1;
    %
    %test_model = model(cls).model;
    %[predict_label, accuracy, dec_values] = svmpredict(test_label, test_instance, test_model);
    [predict_label, accuracy, dec_values] = svmpredict(test_label, test_instance, model);
    
    %score(:,cls) = dec_values;
    
    TIMEtest = toc;
    fprintf('Test time: %f seconds\n\n',TIMEtest);
    
%end

%[~,LABELpred] = max(score,[],2);
%NUMsuc = sum(LABELpred == LABELtest);
%acc = NUMsuc/SIZEtest;
NUMsuc = sum(predict_label == LABELtest);
acc = NUMsuc/SIZEtest;

fprintf('Accuracy: %f %% (%d/%d)\n\n',100*acc,NUMsuc,SIZEtest);

NAMEacc = sprintf('acc_%d_%d.mat', params.dictionarySize, params.pyramidLevels);
PATHacc = fullfile(data_dir,NAMEacc);
save(PATHacc,'acc');
