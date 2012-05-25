%% train
clear

addPaths
addVarshaPaths

try
    matlabpool open 8
catch em
    disp(em);
end

params = initparam(3, 5);
cnt = 1;
rooms = {'bedroom' 'livingroom' 'diningroom'};
for i = 1:length(rooms)
    datadir = fullfile('traindata4', rooms{i});
    datafiles = dir(fullfile(datadir, '*.mat'));
    for j = 1:length(datafiles) % min(200, length(datafiles))
        data(cnt) = load(fullfile(datadir, datafiles(j).name));
        data(cnt).gpg.scenetype = i;
        cnt = cnt + 1;
    end
end

for i = 1:length(data)
    temp(i) = isempty(data(i).x);
end
data(temp) = [];
[paramsout, info] = train_ssvm_uci(data, params);
%% testing
res = struct('spg', cell(length(data), 1), 'maxidx', []);
parfor i = 1:length(data)
    fprintf(['processing ' num2str(i)])
    params = paramsout;
    
	pg = findConsistent3DObjects(data(i).gpg, data(i).x);
	pg.layoutidx = 1; % initialization

    [res(i).spg, res(i).maxidx] = infer_top(data(i).x, data(i).iclusters, params, pg);
    params.objconftype = 'odd';
    [conf1{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params);
    params.objconftype = 'orgdet';
    [conf2{i}] = reestimateObjectConfidences(res(i).spg, res(i).maxidx, data(i).x, data(i).iclusters, params);
    annos{i} = data(i).anno;
    xs{i} = data(i).x;
    fprintf(' => done\n')
end
%% evaluation
names = {'sofa', 'table', 'chair', 'bed', 'dtable'};
for i = 1:length(names)
    [rec{i}, prec{i}, ap{i}] = evalDetection(annos, xs, conf1, i, false);
end

for i = 1:length(names)
    [recbase{i}, precbase{i}, apbase{i}] = evalDetection(annos, xs, conf2, i, false);
end

for i = 1:length(names)
    figure(i);
    plot(rec{i}, prec{i}, 'b-', 'linewidth', 2)
    hold on;
    plot(recbase{i}, precbase{i}, 'm-', 'linewidth', 2)
    grid on
    axis([0 1 0 1])
    xlabel('recall');
    ylabel('precision');
    legend({['ours AP=' num2str(ap{i}, '%.04f')], ['dets AP=' num2str(apbase{i}, '%.04f')]});
    title(names{i})
    saveas(gcf, ['pr_' names{i}], 'fig');
end
%% layout evaluation
baseline = zeros(1, length(data));
ours = zeros(1, length(data));
for i = 1:length(data)
    baseline(i) = data(i).x.lerr(1);
    rid = res(i).spg(res(i).maxidx).layoutidx;
    ours(i) = data(i).x.lerr(rid);
    temp(i) = res(i).maxidx;
end