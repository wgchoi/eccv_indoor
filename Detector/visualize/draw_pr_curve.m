function draw_pr_curve(resnames, objname)

cols = 'brkmgcy';
names = cell(100, 1);
cnt = 1;

figure(1); clf
hold on;
for i = 1:length(resnames)
    data = load(resnames{i});
    idx = 1;
    
    for j = 1:length(data.names)
        if(strcmpi(data.names{j}, objname))
            names{cnt} = [data.expname ' : ' data.names{j} '_' num2str(idx)];
            plot(data.pr(j, :)', data.recall(j, :)', [cols(cnt) '.-'], 'linewidth', 2);
            cnt = cnt + 1;
            idx = idx + 1;
        end
    end
end
hold off;

names(cnt:end) = [];

grid on;
xlabel('precision'); ylabel('recall');
legend(names);
title([objname ' PR curve'])
axis([0 1 0 1])


end