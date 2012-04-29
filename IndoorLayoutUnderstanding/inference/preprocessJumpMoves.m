function moves = preprocessJumpMoves(x, iclusters)
% moves : for each jump type : 
%       add, delete,            % no cahce required.
%       switch, combine, break
%       layout change : jump among the candidates
%       camera height change : additive gaussian
%       scene label switching
moves = cell(5, 1);

%%% add moves
moves{1} = mcmcmoveinfo(length(iclusters));
for i = 1:length(iclusters)
    moves{1}(i).move = 1;
    moves{1}(i).sid = [];
    moves{1}(i).did = i;
    % prcompute caches if necessary
end

%%% delete moves
moves{2} = mcmcmoveinfo(length(iclusters));
for i = 1:length(iclusters)
    moves{1}(i).move = 2;
    moves{1}(i).sid = i;
    moves{1}(i).did = [];
    % prcompute caches if necessary
end

%%% switch moves
count = 0;
moves{3} = mcmcmoveinfo(length(iclusters)*length(iclusters));
for i = 1:length(iclusters)
    for j = 1:length(iclusters)
        % if switching is necessary
        % competing elements
        if(0)        
            assert(0, 'implement compatibility check code');
            count = count + 1;
            moves{3}(count).move = 3;
            moves{3}(count).sid = i;
            moves{3}(count).did = j;
            % prcompute caches if necessary
        end
    end
end
moves{3}((count+1):end) = [];

%%% combine moves
count = 0;
moves{4} = mcmcmoveinfo(10000);
for i = 1:length(iclusters)
end
moves{4}((count+1):end) = [];

%%% break moves
count = 0;
moves{5} = mcmcmoveinfo(10000);
for i = 1:length(iclusters)
end
moves{5}((count+1):end) = [];

end