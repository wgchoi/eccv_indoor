function [ dets ] = readYuDeteion( prefile, numfiles)
%READYUDETEION Summary of this function goes here
%   Detailed explanation goes here

fp = fopen(prefile, 'r');
for i = 1:numfiles
    dets{i} = readOneImageResult(fp);
end
fclose(fp);

end

function det = readOneImageResult(fp)

num = fscanf(fp, '%d', 1);
det = zeros(num, 6);
for i =1:num
    det(i, :) = fscanf(fp, '%f', 6);
end

end