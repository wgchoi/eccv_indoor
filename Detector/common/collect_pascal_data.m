function collect_pascal_data(cls)
% change this path if you install the VOC code elsewhere
addpath(['VOCdevkit/VOCcode']);
% initialize VOC options
VOCinit;
set = get_data(VOCopts,cls);                            % train detector


for i = 1:length(set)
    imshow(fullfile('VOCdevkit', set(i).imfile));
    rectangle('position', [set(i).bbox(1:2) set(i).bbox(3:4) - set(i).bbox(1:2)]);
    pause
end


% train detector
function set = get_data(VOCopts,cls)
% load training set
cp=sprintf(VOCopts.annocachepath,VOCopts.trainset);
if exist(cp,'file')
    fprintf('%s: loading training set\n',cls);
    load(cp,'gtids','recs');
else
    tic;
    gtids=textread(sprintf(VOCopts.imgsetpath,VOCopts.trainset),'%s');
    for i=1:length(gtids)
        % display progress
        if toc>1
            fprintf('%s: load: %d/%d\n',cls,i,length(gtids));
            drawnow;
            tic;
        end

        % read annotation
        recs(i)=PASreadrecord(sprintf(VOCopts.annopath,gtids{i}));
    end
    save(cp,'gtids','recs');
end

% extract features and bounding boxes
N = 1000;
set = struct('imfile', cell(N, 1), 'bbox', cell(N, 1), 'cls', cell(N, 1));

tic;
N = 1;
for i=1:length(gtids)
    % display progress
    if toc>1
        fprintf('%s: train: %d/%d\n',cls,i,length(gtids));
        drawnow;
        tic;
    end
    
    % find objects of class and extract difficult flags for these objects
    clsinds=strmatch(cls,{recs(i).objects(:).class},'exact');
    diff=[recs(i).objects(clsinds).difficult];
    
    % assign ground truth class to image
    if isempty(clsinds)
        gt=-1;          % no objects of class
    elseif any(~diff)
        gt=1;           % at least one non-difficult object of class
    else
        gt=0;           % only difficult objects
    end

    if gt == 1
        % extract features for image
        for j = 1:length(clsinds)
            set(N).imfile = recs(i).imgname;
            set(N).bbox = recs(i).objects(clsinds(j)).bbox;
            N = N + 1;
        end
    end
end

set(N:end) = [];