%% load data
load tempvar

addPaths
addVarshaPaths

datadir = 'tempdata2';
datafiles = dir(fullfile(datadir, '*.mat'));
for i = 1:length(datafiles)
	data(i) = load(fullfile(datadir, datafiles(i).name));
end
load livingroominvid2
data(invidx) = [];
try
    matlabpool open 8
end
parfor i = 1:length(data)
    data(i).gpg = findConsistent3DObjects(data(i).gpg, data(i).x);
end
%% training
params.C = 1;
params.fncost = 1;

params.losstype = 'isolation';
params.inference = 'combined';
params.model.commonground = true;

params.pmove = [0 0 0 0.33 0.33 0.34 0 0];
params.numsamples = 1000;
%
params.model.feattype = 'type2';
params.model.ow_edge = [-inf 0.05 0.3 1 2 inf];
params.model.w_ior = zeros((length(params.model.ow_edge) - 1) * 3, 1);

params.model.feattype = 'type3';
params.model.w_iof = -1; 
params.model.w_iod = -1; 
params.model.w_ior = [0; -0.1; -0.2; -0.3; -0.5];

params.evaltrain = false;

allset = 1:length(data);
szset = length(data) / 3;
for i = 1:3
    testsets{i} = floor((i-1)*szset)+1:floor(i*szset);
    tsetptr(testsets{i}) = i;
end

for i = 1:length(testsets)
    testset = testsets{i};
    trainset = setdiff(1:length(data), testset);
    [paramsout(i), info(i)] = train_ssvm_uci(data(trainset), params);
end
%% testing
res = struct('spg', cell(length(data), 1), 'maxidx', []);
parfor i = 1:length(data)
    fprintf(['processing ' num2str(i)])
    params = paramsout(tsetptr(i));

    pg = findConsistent3DObjects(data(i).gpg, data(i).x);
    [res(i).spg, res(i).maxidx] = infer_top(data(i).x, data(i).iclusters, params, pg);

    params.objconftype = 'odd';
    [conf1{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params);
    params.objconftype = 'orgdet';
    [conf2{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params);
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
    fprintf(' => done\n')
end
%%
[recsofa, precsofa, apsofa] = evalDetection(annos, xs, conf1, 1, false);
[rectable, prectable, aptable] = evalDetection(annos, xs, conf1, 2, false);

[recsofa_base, precsofa_base, apsofa_base] = evalDetection(annos, xs, conf2, 1, false);
[rectable_base, prectable_base, aptable_base] = evalDetection(annos, xs, conf2, 2, false);

figure;
plot(recsofa, precsofa, 'b-', 'linewidth', 2)
hold on;
plot(recsofa_base, precsofa_base, 'm-', 'linewidth', 2)
grid on
axis([0 1 0 1])
xlabel('recall');
ylabel('precision');
legend({['ours AP=' num2str(apsofa, '%.04f')], ['dets AP=' num2str(apsofa_base, '%.04f')]});
title('sofa')

figure;
plot(rectable, prectable, 'b-', 'linewidth', 2)
hold on;
plot(rectable_base, prectable_base, 'm-', 'linewidth', 2)
grid on
axis([0 1 0 1])
xlabel('recall');
ylabel('precision');
legend({['ours AP=' num2str(aptable, '%.04f')], ['dets AP=' num2str(aptable_base, '%.04f')]});
title('table')

return;
% % %% testing
% % % load('outputs.mat', 'params2')
% % % params2.model.w_ioo(:) = 0;
% % % params2.model.w_iof(:) = 0;
% % % params2.model.w_ior(:) = 0;
% % % w = [ 0,0,-0.1676,0,0,0,0,0,0,0,0,0,0,0.018502,-0.062205,0.068347,-0.31195,-0.56368,0,0,0,0,-1.3576,-1.2798,0.941,-0.14738,1.3294,-0.13629];
% % params2.model.w_iof = [-1.0; -.5];
% % params2.model.w_ioo = [0; -.5];
% % params2.model.w_oo = [1; 0.5; .5; 0.0];
% % params2.model.w_ior = [ 0.0; 0.0; 0.0; 0; 0; ...
% %                        0.0; 0.0; 0.0; 0; 0; ...
% %                        0.0; -0.1; -0.25; -.5; -1.0];
% % %%
% % disp(getweights(params2.model)')
% % %
% % parfor i = 1:length(data)
% %     fprintf(['processing ' num2str(i)])
% %     pg = findConsistent3DObjects(data(i).gpg, data(i).x);
% %     [res(i).spg, res(i).maxidx] = infer_top(data(i).x, data(i).iclusters, params2, pg);
% %     fprintf(' => done\n')
% % end
% % %% evaluation
% % params2.objconftype = 'odd';
% % for i = 1:length(data)
% %     [conf{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params2);
% %     annos{i} = data(i).anno;
% %     xs{i} = data(i).x;
% % end
% % [rec1, prec1, ap1] = evalDetection(annos, xs, conf, 1, false);
% % [rec12, prec12, ap12] = evalDetection(annos, xs, conf, 2, false);
% % 
% % params2.objconftype = 'samplesum';
% % for i = 1:length(data)
% %     [conf{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params2);
% % end
% % [rec2, prec2, ap2] = evalDetection(annos, xs, conf, 1, false);
% % [rec22, prec22, ap22] = evalDetection(annos, xs, conf, 2, false);
% % 
% % params2.objconftype = 'orgdet';
% % for i = 1:length(data)
% %     [conf{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params2);
% % end
% % [rec3, prec3, ap3] = evalDetection(annos, xs, conf, 1, false);
% % [rec32, prec32, ap32] = evalDetection(annos, xs, conf, 2, false);
% % 
% % % drawing
% % figure;
% % plot(rec1, prec1, 'b-', 'linewidth', 2)
% % hold on;
% % plot(rec2, prec2, 'k-', 'linewidth', 2)
% % plot(rec3, prec3, 'm-', 'linewidth', 2)
% % grid on
% % axis([0 1 0 1])
% % xlabel('recall');
% % ylabel('precision');
% % legend({['ours AP=' num2str(ap1, '%.04f')], ['ours(ss) AP=' num2str(ap2, '%.04f')], ['dets AP=' num2str(ap3, '%.04f')]});
% % 
% % figure;
% % plot(rec12, prec12, 'b-', 'linewidth', 2)
% % hold on;
% % plot(rec22, prec22, 'k-', 'linewidth', 2)
% % plot(rec32, prec32, 'm-', 'linewidth', 2)
% % grid on
% % axis([0 1 0 1])
% % xlabel('recall');
% % ylabel('precision');
% % legend({['ours AP=' num2str(ap12, '%.04f')], ['ours(ss) AP=' num2str(ap22, '%.04f')], ['dets AP=' num2str(ap32, '%.04f')]});