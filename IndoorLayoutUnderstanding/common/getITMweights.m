function w = getITMweights(rule)

w = zeros(rule.numparts * 3 + 8, 1);

ibase = 0;
for i = 1:length(rule.parts)
    w(ibase + 1) = rule.parts(i).wx;
    w(ibase + 2) = rule.parts(i).wz;
    w(ibase + 3) = rule.parts(i).wa;
    ibase = ibase + 3;
end
w(ibase+1:ibase+8) = rule.biases;

end