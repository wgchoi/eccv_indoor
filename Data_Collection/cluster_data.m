function ret = cluster_data(imgbase, annobase, dname, models)

imdir = fullfile(imgbase, dname);
annodir = fullfile(annobase, dname);

imfiles = dir(fullfile(imdir, '*.jpg'));

clusterimage = uint8(zeros(920, 920, 3));
xmap = [1 311 621 1 311 621 1 311 621];
ymap = [1 1 1 311 311 311 621 621 621];

for i = 1:9
	clusters{i} = {};
end

for i = 1:length(imfiles)
	annofile = [imfiles(i).name(1:find(imfiles(i).name == '.', 1, 'last') - 1) '_labels.mat'];
	load(fullfile(annodir, annofile));
	draw_all(imdir, imfiles(i).name, models, obj_annos, 600);
	figure(2);
	imshow(clusterimage);
	key = input('Which cluster does it belongs? (x : exit, 0:N/A, 1~9)', 's');
    
    if(key == 'x'), break; end
    
	key = parse_key(key);
	if(key > 0)
		clusters{key}{end+1} = imfiles(i).name;
		idx = length(clusters{key});
		if(idx <= 4)
			xmap2 = [0 150 0 150];
			ymap2 = [0 0 150 150];
			figure(1); 
			f = getframe();
			smallim = imresize(f.cdata, [150 150]);
			%%%
			x1 = xmap(key) + xmap2(idx);
			y1 = ymap(key) + ymap2(idx);
			x2 = x1 + 150 - 1;
			y2 = y1 + 150 - 1;

			clusterimage(y1:y2, x1:x2, :) = smallim;
		end
	end
end

ret.clusterimage = clusterimage;
ret.clusters = clusters;

end

function cluster = parse_key(key)
cluster = 0;
if(isempty(key))
	return;
end
if(key >= '1' && key <= '9')
	cluster = key - '1' + 1;
end
end

function draw_all(imdir, imfile, models, obj_annos, maxwidth)
%%% draw all
figure(1);
im = imread(fullfile(imdir, imfile));
ratio = 1;
if (size(im, 2) > maxwidth)
    ratio = maxwidth / size(im, 2); 
    im = imresize(im, ratio);
end
imshow(im);

for i = 1:length(obj_annos)
    bbs = [obj_annos(i).x1, obj_annos(i).y1, obj_annos(i).x2 - obj_annos(i).x1, obj_annos(i).y2 - obj_annos(i).y1] * ratio;
    rectangle('position', bbs, 'linewidth', 2, 'edgecolor', get_obj_color(obj_annos(i).objtype));
    if(obj_annos(i).objtype > 0)
        text(bbs(1), bbs(2), models(obj_annos(i).objtype).name, 'BackgroundColor', get_obj_color(obj_annos(i).objtype));
    else
        text(bbs(1), bbs(2), 'N/A', 'BackgroundColor', get_obj_color(0));
    end
end
end

function col = get_obj_color(id)
cols = 'wrgbcmk';
col = cols(mod(id, length(cols)) + 1);
end
