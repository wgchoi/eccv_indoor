clear
close all

corrector = 'wongun';

setname = 'set10';

imbase = ['bedroom/' setname '/'];
annobase = ['annotation/bedroom_temp/' setname '/'];
verifiedbase = ['annotation/bedroom/' setname '/'];

imfiles = dir(fullfile(imbase, '*.jpg'));

if(~exist(verifiedbase, 'dir'))
    mkdir(verifiedbase);
end

%%%%%%%
for i = 1:length(imfiles)
    idx = find(imfiles(i).name == '.', 1, 'last');
    
    annofile = [imfiles(i).name(1:idx-1) '_labels.mat'];
    
    orgfile = fullfile(annobase, [imfiles(i).name(1:end-4) '_labels.mat']);
    if ~exist(orgfile, 'file')
        disp(['missing ' orgfile]);
        continue;
    end
    
    destfile = fullfile(verifiedbase, annofile);
    if exist(destfile, 'file')
        orgfile = destfile;
    end
    
    draw_annotation(fullfile(imbase, imfiles(i).name), orgfile);
    if('y' == input('Correct annotation? [y/n]', 's'))
        correct_annotation(fullfile(imbase, imfiles(i).name), orgfile, destfile, corrector);
    else
        data = load(orgfile);
        data.gtPolyg = rearrangePolyg(data.gtPolyg);
        if ~strcmp(orgfile, destfile)
            save(destfile, '-struct', 'data');
            % copyfile(orgfile, destfile);
        end
    end
end