function [moves, cache] = preprocessJumpMoves(x, iclusters, cache)
% moves : for each jump type : 
%       add, delete,
%       switch, combine, break
%       layout change : jump among the candidates
%       camera height change : additive gaussian
%       scene label switching
moves = cell(8, 1);
%%% scene, layout, height
for movetype = 1:3
    moves{movetype} = mcmcmoveinfo(0);
end
%%% add moves
movetype = 4;
moves{movetype} = mcmcmoveinfo(length(iclusters));
for i = 1:length(iclusters)
    moves{movetype}(i).move = movetype;
    moves{movetype}(i).sid = [];
    moves{movetype}(i).did = i;
    % prcompute caches if necessary
end

%%% delete moves
movetype = 5;
moves{movetype} = mcmcmoveinfo(length(iclusters));
for i = 1:length(iclusters)
    moves{movetype}(i).move = movetype;
    moves{movetype}(i).sid = i;
    moves{movetype}(i).did = [];
    % prcompute caches if necessary
end

%%% switch moves
count = 0;
movetype = 6;
moves{movetype} = mcmcmoveinfo(length(iclusters)*length(iclusters));
for i = 1:length(iclusters)
    swset = [];
    for j = 1:length(iclusters)
        if(i == j), continue; end
        % if switching is necessary
        % competing elements
        if(iclusters(i).isterminal && iclusters(j).isterminal)
            % conflicting
            if(x.orpolys(i, j) > 0.3 || x.orarea(i, j) > 0.5)
                count = count + 1;
                moves{movetype}(count).move = movetype;
                moves{movetype}(count).sid = i;
                moves{movetype}(count).did = j;
                % prcompute caches if necessary
                % swset(end + 1) = count;
                swset(end + 1) = j;
            end
        else
            continue;
            assert(0, 'implement compatibility check code');
        end
    end
    cache.swset{i} = swset;
    cache.szswset(i) = length(swset);
end
moves{movetype}((count+1):end) = [];

%%% combine moves
count = 0;
movetype = 7;
moves{movetype} = mcmcmoveinfo(10000);
for i = 1:length(iclusters)
end
moves{movetype}((count+1):end) = [];

%%% break moves
count = 0;
movetype = 8;
moves{movetype} = mcmcmoveinfo(10000);
for i = 1:length(iclusters)
end
moves{movetype}((count+1):end) = [];

end