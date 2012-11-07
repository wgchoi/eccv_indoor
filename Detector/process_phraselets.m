function process_phraselets(imdir, resdir, exts)
if nargin < 3
    exts = {'jpg'};
end
addPaths;
load ./Phraselets/person_sitting_on_chair_final.mat
process_onedir( imdir, ...
                fullfile(resdir, 'person_chair/'), ...
                {model}, {'person_chair'}, exts);
            
load ./Phraselets/person_sitting_on_sofa_final.mat
process_onedir( imdir, ...
                fullfile(resdir, 'person_sofa/'), ...
                {model}, {'person_sofa'}, exts)
end