clear

addPaths
addVarshaPaths

database = 'cache/itmobs/iter3';
files = dir(fullfile(database, 'train*'));

disp(['reading data']);
for i = 1:length(files)
    temp = load(fullfile(database, files(i).name));
    
    patterns(i) = temp.pattern;
    lables(i) = temp.label;
    annos(i) = temp.anno;
    
    for j = 1:length(patterns(i).iclusters)
        patterns(i).iclusters(j).robs = 0;
    end
end

load('/home/wgchoi/codes/eccv_indoor/IndoorLayoutUnderstanding/cache/itmobs/iter3/params.mat')

params = iparams;
params.model.itmptns
params.pmove = [0 1.0 0 0 0 0 0 0];
params.numsamples = 100;
params.quicklearn = true;
params.max_ssvm_iter = 6 + 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.model.feattype = 'itm_v2';
params.model.w_ior = zeros(8, 1);
params.model.w_iso = zeros(24, 1);
params.model.w_iso = zeros(21, 1);

loadfile = 1;
if(1)
	paramfile = 'cache/itmobs/reproduced_v2_noitm_highloss.mat';
	resfile = 'cache/itmobs/reproduced_testres_v2_noitm_highloss.mat';
	rescachedir = 'cache/itmobs/reproduced_cache_v2_noitm_highloss/';
	for i = 1:length(patterns)
		patterns(i).x.lloss = patterns(i).x.lloss .* 3;
	end

	for i = 1:length(lables)
		lables(i).lcpg = lables(i).pg;
	end

	for i = 1:length(patterns)
		patterns(i).composite(:) = [];
		patterns(i).iclusters = patterns(i).isolated;
	end
	params.model.itmptns(:) = [];
else
	paramfile = 'cache/itmobs/reproduced_v2_highloss.mat';
	resfile = 'cache/itmobs/reproduced_testres_v2_highloss.mat';
	rescachedir = 'cache/itmobs/reproduced_cache_v2_highloss/';

	for i = 1:length(patterns)
		patterns(i).x.lloss = patterns(i).x.lloss .* 3;
	end
end

if(strcmp(params.model.feattype, 'itm_v3'))
	patterns = append_ITM_detections(patterns, params.model.itmptns, 'cache/itmdets', 'cache/dpm_parts');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params2 = appendITMtoParams(params, params.model.itmptns);
keyboard;
try
	matlabpool open 8;
end
disp(['run training experiment for ' paramfile]);
[paramsout, info] = train_ssvm_uci2(patterns, lables, annos, params2, 0); 

save(paramfile, 'paramsout', 'info');
%%
clear patterns lables annos

test_roomdata_replicate2
