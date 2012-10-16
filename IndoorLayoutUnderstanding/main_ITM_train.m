%% train
clear

addPaths
addVarshaPaths
addpath ../3rdParty/ssvmqp_uci/
% 
try
    matlabpool open 8
catch em
    disp(em);
end

params = initparam(3, 6);
params.quicklearn = true;

dataroot = 'filtereddata'; 
datadir = fullfile(dataroot, 'data_fixed');
%%
datafiles = dir(fullfile(datadir, '*.mat'));
parfor i = 1:length(datafiles) % min(200, length(datafiles))
    data(i) = load(fullfile(datadir, datafiles(i).name));
    % data(i).x = sceneClassify(data(i).x);
    % data(i).anno.scenetype = data(i).gpg.scenetype;
    disp(['reading ' num2str(i) 'th done'])
end
expinfo = load(fullfile(dataroot, 'info'));
%%
addpath ./experimental/
% params.model.feattype = 'org';
for i = 1:length(data)
    leo(i) = data(i).x.lerr(1);
end
%% 
params.model.feattype = 'org';
C = [1 10];
summary0 = 1:length(C);
for i = 1:length(C)
    [p0(i), iout0(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p0(i));
    summary0(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
    
    show_testlayout(data, outputs, le, 0, ['experimental/org_C' num2str(C(i))]);
    show_testlayout(data, outputs, le, 1, ['experimental/org_C' num2str(C(i))]);
end
%% 
params.model.feattype = 'new';
C = [1 10];
summary1 = 1:length(C);
for i = 1:length(C)
    [p1(i), iout1(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p1(i));
    summary1(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
    
    show_testlayout(data, outputs, le, 0, ['experimental/new_C' num2str(C(i))]);
    show_testlayout(data, outputs, le, 1, ['experimental/new_C' num2str(C(i))]);
end
%% 
params.model.feattype = 'new3';
C = [1 10];
summary2 = 1:length(C);
for i = 1:length(C)
    [p2(i), iout2(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p2(i));
    summary2(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
    
    show_testlayout(data, outputs, le, 0, ['experimental/new3_C' num2str(C(i))]);
    show_testlayout(data, outputs, le, 1, ['experimental/new3_C' num2str(C(i))]);
end
%% 
params.model.feattype = 'new4';
C = [1 10];
summary3 = 1:length(C);
for i = 1:length(C)
    [p3(i), iout3(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p3(i));
    summary3(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
    
    show_testlayout(data, outputs, le, 0, ['experimental/new4_C' num2str(C(i))]);
    show_testlayout(data, outputs, le, 1, ['experimental/new4_C' num2str(C(i))]);
end
%% 
params.model.feattype = 'new5';
C = [1 10];
summary4 = 1:length(C);
for i = 1:length(C)
    [p4(i), iout4(i)] = train_feat_test(data(1:3:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data, p4(i));
    summary4(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
    
    show_testlayout(data, outputs, le, 0, ['experimental/new5_C' num2str(C(i))]);
    show_testlayout(data, outputs, le, 1, ['experimental/new5_C' num2str(C(i))]);
end
%%
% expname = 'itmv1_scene';
% [paramsout, info] = trainLITM_ssvm(data(expinfo.trainsplit), params, expname);