function train_itms_room(itmidx)
addPaths
addVarshaPaths
load ./cvpr13data/room/itmtrainsets.mat
train_dpm_for_itms(sets(itmidx), ['itm' num2str(ptns(itmidx).type, '%03d')], allimlists);
