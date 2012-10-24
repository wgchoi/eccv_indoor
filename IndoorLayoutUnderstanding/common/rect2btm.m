function btm = rect2btm(rect)
btm = [ rect(1, :) + rect(3, :) ./ 2; ...
		rect(2, :) + rect(4, :); ...
		rect(4, :) ];
end

