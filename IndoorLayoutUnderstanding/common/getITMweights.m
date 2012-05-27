function w = getITMweights(ptn)

w = zeros(ptn.numparts * 3 + 8, 1);

ibase = 0;
for i = 1:length(ptn.parts)
    w(ibase + 1) = ptn.parts(i).wx;
    w(ibase + 2) = ptn.parts(i).wz;
    w(ibase + 3) = ptn.parts(i).wa;
    ibase = ibase + 3;
end
w(ibase+1:ibase+8) = ptn.biases;

end