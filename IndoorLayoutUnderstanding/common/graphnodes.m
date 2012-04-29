function nodes = graphnodes(num)
if nargin == 0, num = 1; end

nodes = struct( 'isterminal', 0, 'ittype', 0, ...
                'angle', 0, 'loc', zeros(3, 1), ...
                'chindices', cell(num, 1), 'feats', cell(num, 1));

end