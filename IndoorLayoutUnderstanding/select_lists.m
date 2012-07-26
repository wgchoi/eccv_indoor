%% train
clear

addPaths
addVarshaPaths
% 
% try
%     matlabpool open 8
% catch em
%     disp(em);
% end

params = initparam(3, 6);
cnt = 1;
rooms = {'bedroom' 'livingroom' 'diningroom'};
for i = 1:length(rooms)
    datadir = fullfile('finaldata', rooms{i});
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
%%
close all
invidx = [];
for i = 1:length(data)
    try
        if(isempty(data(i).gpg.childs))
            invidx(end+1) = i;
            continue;
        end
        
        pg = findConsistent3DObjects(data(i).gpg, data(i).x, data(i).iclusters);
        show2DGraph(pg, data(i).x, data(i).iclusters);
        show3DGraph(pg, data(i).x, data(i).iclusters);
        
        key = input('valid example? [y/n]', 's');
        if(key == 'n')
            invidx(end+1) = i;
        end
    catch
        invidx(end+1) = i;
    end
end
orgdir = 'finaldata';
save('filtereddata/invalididx', 'invidx', 'orgdir');
%%
valididx = setdiff(1:length(data), invidx);
st = zeros(3, 1);
for j = 1:length(valididx)
    i = valididx(j);
    st(data(i).gpg.scenetype) = st(data(i).gpg.scenetype) + 1;
end
%%
rooms = {'bedroom' 'livingroom' 'diningroom'};
scenedist = st;

trainsplit = [1:180, st(1)+1:st(1)+180, sum(st(1:2))+1:sum(st(1:2))+180];
save('filtereddata/info', 'rooms', 'scenedist', 'trainsplit'); % , 'testsplit);

if(~exist('filtereddata/data', 'dir'))
    mkdir('filtereddata/data');
end
for i = 1:length(valididx)
    temp = data(valididx(i));
    save(['filtereddata/data/data' num2str(i, '%03d')], '-struct', 'temp');
end