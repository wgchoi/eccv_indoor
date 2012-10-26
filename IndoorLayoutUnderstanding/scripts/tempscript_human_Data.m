clear
%%
addPaths
addVarshaPaths
addpath ../3rdParty/ssvmqp_uci/
addpath experimental/

resbase = '~/codes/human_interaction/cache/data.v2';
datasets = dir(resbase);
datasets(1:2) = [];

cnt = 1; 
for d = 1:length(datasets)
    resdir = fullfile(resbase, datasets(d).name);
    files = dir(fullfile(resdir, '*.mat'));
    for i = 1:length(files)
        data(cnt) = load(fullfile(resdir, files(i).name));
        if(isempty(data(cnt).x))
            i
        else
            cnt = cnt + 1;
        end
    end
end
%% 
% %% reestimate detections and gt
% params = initparam(3, 7);
% for i = 1:length(data)
%     hidx = find(data(i).x.dets(:, 1) == 7);
%     data(i).x.dets(hidx, 2) = 1;
%     [a, b] = generate_object_hypotheses(data(i).x.imfile, data(i).x.K, data(i).x.R, data(i).x.yaw, objmodels(), data(i).x.dets(hidx, :), 1);
%     data(i).x.hobjs(hidx) = a;
%     
%     data(i).iclusters = clusterInteractionTemplates(data(i).x, params.model);
% 	data(i).gpg = get_GT_human_parsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
% end
%% use real gt
params = initparam(3, 7);
for i = 1:length(data)
    [data(i).x, data(i).iclusters] = get_ground_truth_observations(data(i).x, data(i).anno, params.model);
    data(i).gpg = get_GT_human_parsegraph(data(i).x, data(i).iclusters, data(i).anno, params.model);
end
%%
params.model.feattype = 'itm_v1';
params.model.humancentric = 1;
params.minITMmatch = 15;

%% 
[patterns, labels, annos] = preprocess_train_data(data, params, 2);
for i = 1:length(labels)
    labels(i).pg.childs = 1:length(patterns(i).x.hobjs);
    labels(i).pg.subidx = 14 * ones(1, length(patterns(i).x.hobjs));
end

%%
[ptns, comps, indsets] = learn_itm_patterns(patterns, labels, params, 2, 'human_itm_fixed');
%%
[ps, is, cs] = filter_itms(ptns, indsets, comps, params);
save('cache/human_itm_fixed', '-append', 'ps', 'is', 'cs');
%%
try
    matlabpool open 8
catch
end

for i = 1:length(ptns)
    [itm_examples] = get_itm_examples(data, is{i}, cs{i});
    train_dpm_for_itms(itm_examples, ['human_filtered_itm' num2str(i, '%03d')]);
end

return;
%%
% for i = 1:length(data)
%     show2DGraph(data(i).gpg, data(i).x, data(i).iclusters);
%     show3DGraph(data(i).gpg, data(i).x, data(i).iclusters);
%     pause
% end
%%
params = initparam(3, 7);
params.quicklearn = true;

for i = 1:length(data)
    leo(i) = data(i).x.lerr(1);
end
leo = leo(2:2:end);
%%
params.model.feattype = 'org';
C = [1 10];
summary0 = 1:length(C);
for i = 1:length(C)
    [p0(i), iout0(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p0(i));
    
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
    summary0(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
end
 
params.model.feattype = 'new';
C = [1 10];
summary1 = 1:length(C);
for i = 1:length(C)
    [p1(i), iout1(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p1(i));
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
    summary1(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
end
% 
% params.model.feattype = 'new3';
% C = [1 10];
% summary2 = 1:length(C);
% for i = 1:length(C)
%     [p2(i), iout2(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
%     
%     [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p2(i));
%     disp([params.model.feattype 'C' num2str(C(i))]);
%     [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
%     summary2(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
% end
% summary2
% 
% params.model.feattype = 'new4';
% C = [1 10];
% summary3 = 1:length(C);
% for i = 1:length(C)
%     [p3(i), iout3(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
%     
%     [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p3(i));
%     disp([params.model.feattype 'C' num2str(C(i))]);
%     [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
%     summary3(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
% end
% summary3

params.model.feattype = 'new5';
C = [1 10];
summary4 = 1:length(C);
for i = 1:length(C)
    [p4(i), iout4(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
    
    [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p4(i));
    disp([params.model.feattype 'C' num2str(C(i))]);
    [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
    summary4(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
end
% params.model.feattype = 'new6';
% C = [1 10];
% summary5 = 1:length(C);
% for i = 1:length(C)
%     [p5(i), iout5(i)] = train_feat_test(data(1:2:end), params.model, C(i), 0);
%     
%     [outputs, ls, le] = evaluate_testlayout(data(2:2:end), p5(i));
%     disp([params.model.feattype 'C' num2str(C(i))]);
%     [gain, oracle_gain] = stat_testlayout(data(2:2:end), outputs);
%     summary5(i) = sum(leo(~isnan(leo)) - le(~isnan(leo))) / length(le);
% end
% summary5