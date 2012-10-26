function [labels, p] = classify_poselet(model, train_data, test_data)

addpath('../3rdParty/libsvm-3.12/matlab/');

n = size(test_data, 1);
Ktest = hist_isect(test_data, train_data);
Ktest_svm = [(1:n)', Ktest];
[labels, ~, p] = svmpredict(ones(n, 1), Ktest_svm, model, '-b 1');

end