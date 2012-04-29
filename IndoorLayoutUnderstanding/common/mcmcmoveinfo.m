% 'move' :  1. add, 2. delete, 3. switch, 4. combine, 5. break, 
%           no need to precompute below
%           6. scene,
%           7. layout selection and 8. cam height diffusion
% 'sid' : set of source cluster ids
% 'did' : set of dest cluster ids
% 'lkcache' : can be useful
function info = mcmcmoveinfo(num)
info = struct('move', cell(num, 1), 'sid', cell(num, 1), 'did', cell(num, 1), 'lkcache', cell(num, 1));
end