clear

addPaths;

if(~exist('./dataset', 'dir'))
    mkdir('dataset');
    system('wget http://www.eecs.umich.edu/vision/data/cvpr13IndoorData.tar.gz');
    system('mv cvpr13IndoorData.tar.gz ./dataset/; cd dataset/; tar xvf cvpr13IndoorData.tar.gz');
    system('rm cvpr13IndoorData.tar.gz; cd ..');
end

preprocess_dir = 'cache/test';
if(~exist(preprocess_dir, 'dir'))
    r = input('Download preprocessed data? (y/n)', 's');
    if(r == 'y')
        mkdir('cache');
        system('wget http://www.eecs.umich.edu/vision/data/cvpr13IndoorPreprocessed.tar.gz'); 
        system('mv cvpr13IndoorPreprocessed.tar.gz ./cache/; cd cache; tar xvf cvpr13IndoorPreprocessed.tar.gz');
        system('rm cvpr13IndoorPreprocessed.tar.gz; cd ..');
    else
        % preprocess data
        % detector
        % layout estimator
        % scene classifier
        assert(0);
    end
end
%% load pre-processed data
datafiles = dir(fullfile(preprocess_dir, '*.mat'));
%% run 3DGP model
% load trained baseline model
paramfile = 'model/params_baseline'; % without 3DGP
temp = load(paramfile);
params1 = temp.paramsout;
params1.numsamples = 1000;
params1.pmove = [0 0.4 0 0.3 0.3 0 0 0];
params1.accconst = 3;
% load trained 3DGP model
paramfile = 'model/params_3dgp';
temp = load(paramfile);
params2 = temp.paramsout;
params2.numsamples = 1000;
params2.pmove = [0 0.4 0 0.3 0.3 0 0 0];
params2.accconst = 3;
params2.retainAll3DGP = 1;

% initialize buffer
res = cell(1, length(datafiles));
annos = cell(1, length(datafiles));
xs = cell(1, length(datafiles));
conf0 = cell(1, length(datafiles)); % baseline
conf1 = cell(1, length(datafiles)); % no 3DGP
conf2 = cell(1, length(datafiles)); % 3DGP with Marginalization 1
conf3 = cell(1, length(datafiles)); % 3DGP with Marginalization 2

erroridx = false(1, length(datafiles));
csize = 32;
matlabpool open;
for idx = 1:csize:length(datafiles)
    setsize = min(length(datafiles) - idx + 1, csize);
    fprintf(['processing ' num2str(idx) ' - ' num2str(idx + setsize)]);
    
    for i = 1:setsize
        tdata(i) = load(fullfile(preprocess_dir, datafiles(idx+i-1).name));
    end    
    tdata(setsize+1:end) = [];
    
    tempres = cell(1, setsize);
    tconf0 = cell(1, setsize);
    tconf1 = cell(1, setsize);
    tconf2 = cell(1, setsize);
    tconf3 = cell(1, setsize);
    
    terroridx = false(1, setsize);
    parfor i = 1:setsize
%      for i = 1:setsize
        try
            pg0 = parsegraph(); 
            
            pg0.layoutidx = 1; % initialization
            pg0.scenetype = 1;
            
            params = params2;
            [tdata(i).iclusters] = clusterInteractionTemplates(tdata(i).x, params.model);
            %%%%% baseline  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            params = params1;
            [tempres{i}.spg, tempres{i}.maxidx, tempres{i}.h, tempres{i}.clusters] = infer_top(tdata(i).x, tdata(i).iclusters, params, pg0);
            
            params.objconftype = 'orgdet';
            [tconf0{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            params.objconftype = 'odd';
            [tconf1{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            %%%%% 3DGP      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            params = params2;
            [tempres{i}.spg, tempres{i}.maxidx, tempres{i}.h, tempres{i}.clusters] = infer_top(tdata(i).x, tdata(i).iclusters, params, pg0);
            
            params.objconftype = 'odd';
            [tconf2{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            params.objconftype = 'odd2';
            [tconf3{i}] = reestimateObjectConfidences(tempres{i}.spg, tempres{i}.maxidx, tdata(i).x, tempres{i}.clusters, params);
            tempres{i}.clusters = [];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fprintf('+');
        catch
            fprintf('-');
            terroridx(i) = true;
        end
    end
    erroridx(idx:idx+setsize-1) = terroridx;
    
    for i = 1:setsize
        res{idx+i-1} = tempres{i};
        annos{idx+i-1} = tdata(i).anno;
        xs{idx+i-1} = tdata(i).x;
        conf0{idx+i-1} = tconf0{i};
        conf1{idx+i-1} = tconf1{i};
        conf2{idx+i-1} = tconf2{i};
        conf3{idx+i-1} = tconf3{i};
    end
    fprintf(' => done\n')
end
matlabpool close
%% draw curves
om = objmodels();
for i = 1:length(om)
    figure;
    [rec, prec, ap0]= evalDetection(annos, xs, conf0, i, 0, 0, 1);
    plot(rec, prec, 'r--', 'linewidth', 2);
    hold on;
    [rec, prec, ap1]= evalDetection(annos, xs, conf1, i, 0, 0, 1);
    plot(rec, prec, 'g-.', 'linewidth', 2);
    [rec, prec, ap2]= evalDetection(annos, xs, conf2, i, 0, 0, 1);
    plot(rec, prec, 'k', 'linewidth', 2);
    [rec, prec, ap3]= evalDetection(annos, xs, conf3, i, 0, 0, 1);
    plot(rec, prec, 'b-.', 'linewidth', 2);
    hold off;
    
    h = title(om(i).name);
    set(h, 'fontsize', 30);
    grid on;
    axis([0 1 0 1]);
    h = gca;
    set(h, 'fontsize', 18);
    
    h = xlabel('recall');
    set(h, 'fontsize', 30);
    h = ylabel('precision');
    set(h, 'fontsize', 30);
    
    h = legend({['DPM AP=' num2str(ap0, '%.03f')], ...
            ['NO 3DGP AP=' num2str(ap1, '%.03f')], ...
            ['3DGP-M1 AP=' num2str(ap2, '%.03f')], ...
            ['3DGP-M2 AP=' num2str(ap3, '%.03f')]}, ...
            'Location', 'SouthWest', 'fontsize', 20);
end