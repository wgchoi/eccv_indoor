function varargout = annotate_one_obj_pose(varargin)
% annotate_one_obj_pose(window, objmodel, i, elevation)

global POSE_FIG POSE_AX 
global OBJCUBE_H OBJFACE_H TEXT_H
global OBJMODEL IMSZ
global AZ ELV SUBID

if ((length(varargin) >= 1) && ischar(varargin{1}))
    % Callback invocation: 'KeyPress'
    feval(varargin{:});
    return;
end
assert(length(varargin) == 4);
% close all;
img = varargin{1};
IMSZ = size(img);
OBJMODEL = varargin{2}(varargin{3});

ELV = varargin{4}.el; AZ = varargin{4}.az; SUBID = varargin{4}.subid;

imshow(img);
xlimorigmode = xlim('mode');
ylimorigmode = ylim('mode');
xlim('manual');
ylim('manual');

POSE_AX = gca; POSE_FIG = ancestor(POSE_AX, 'figure');

% Remember initial figure state
state= uisuspend(POSE_FIG);
% Set up initial callbacks for initial stage
set(POSE_FIG, ...
    'KeyPressFcn', 'annotate_one_obj_pose(''KeyPress'');');
% Bring target figure forward
figure(POSE_FIG);
% Initialize the lines to be used for the drag
OBJCUBE_H = line('Parent', POSE_AX, ...
                  'XData', [], ...
                  'YData', [], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'm', ...
                  'LineStyle', '-');
OBJFACE_H = patch('Parent', POSE_AX, ...
                  'XData', [], ...
                  'YData', [], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'FaceAlpha', 0.1, ...
                  'FaceColor', 'm', ...
                  'LineStyle', '-');

TEXT_H = text(5, 10, ['Type ' num2str(SUBID) ', AZ : ' num2str(180*AZ/pi) ', EL : ' num2str(180/pi*ELV)], 'BackgroundColor', 'w');
draw_obj();

figure(POSE_FIG);
% We're ready; wait for the user to do the drag
% Wrap the call to waitfor in try-catch so we'll
% have a chance to clean up after ourselves.
errCatch = 0;
try
    waitfor(OBJCUBE_H, 'UserData', 'Completed');
catch
    errCatch = 1;
end

% After the waitfor, if GETLINE_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
    errStatus = 'trap';
    
elseif (~ishghandle(OBJCUBE_H) || ...
            ~strcmp(get(OBJCUBE_H, 'UserData'), 'Completed'))
    errStatus = 'unknown';
else
    errStatus = 'ok';
end

% Delete the animation objects
if (ishghandle(OBJCUBE_H))
    delete(OBJCUBE_H);
end

% Restore the figure's initial state
if (ishghandle(POSE_FIG))
   uirestore(state);
end

subid = SUBID; az = AZ; el = ELV;
CleanUp(xlimorigmode, ylimorigmode);

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
case 'ok'
    % Return the answer
    varargout{1} = struct('subid', subid, 'az', az, 'el', el);    
case 'trap'
    % An error was trapped during the waitfor
    error(message('images:getclosedpoly:interruptedMouseSelection'));
    
case 'unknown'
    % User did something to cause the polyline selection to
    % terminate abnormally.  For example, we would get here
    % if the user closed the figure in the middle of the selection.
    error(message('images:getclosedpoly:interruptedMouseSelection'));
end

function draw_obj()
global AZ ELV SUBID IMSZ
global OBJMODEL OBJCUBE_H TEXT_H OBJFACE_H

[poly, face] = getProjectedObjectPoly(IMSZ, OBJMODEL.width(SUBID), OBJMODEL.height(SUBID), OBJMODEL.depth(SUBID), ...
                                AZ, ELV);
                            
set(OBJCUBE_H, ...
        'XData', poly(1, :), ...
        'YData', poly(2, :), ...
        'Visible', 'on');
    
set(OBJFACE_H, ...
      'XData', face(1, :), ...
      'YData', face(2, :), ...
      'Visible', 'on');    

set(TEXT_H, ...
    'string', ...
    ['Type ' num2str(SUBID) ', AZ : ' num2str(180*AZ/pi) ', EL : ' num2str(180/pi*ELV)]);

%--------------------------------------------------
% Subfunction KeyPress
%--------------------------------------------------
function KeyPress %#ok

global POSE_FIG OBJCUBE_H
global AZ ELV SUBID OBJMODEL

key = get(POSE_FIG, 'CurrentCharacter');

% find(char(1:1000) == key)
% Keyleft 28, Keyright 29, keyup 30, keydown 31
% enter 13

switch key
    case char(13) % Enter
        set(OBJCUBE_H, 'UserData', 'Completed');   
    case char(28) % Keyleft
        AZ = AZ + 2 * pi / 24;
    case char(29) % Keyright
        AZ = AZ - 2 * pi / 24;
    case char(30) % Keyup
        ELV = ELV + 2 * pi / 24;
    case char(31) % Keydown
        ELV = ELV - 2 * pi / 24;
    case {'1','2','3','4','5','6','7','8','9'}
        SUBID = key - '1' + 1;
end

if(AZ <= -pi),      AZ = AZ + 2 * pi; end
if(AZ > pi),        AZ = AZ - 2 * pi; end
if(ELV < 0),        ELV = 0; end
if(ELV > pi / 2),   ELV = pi / 2; end
if(SUBID > length(OBJMODEL.width)), SUBID = length(OBJMODEL.width); end

draw_obj();
% project model and show


%---------------------------------------------------
% Subfunction CleanUp
%--------------------------------------------------
function CleanUp(xlimmode,ylimmode)

xlim(xlimmode);
ylim(ylimmode);
% Clean up the global workspace
clear global POSE_FIG POSE_AX OBJCUBE_H
clear global OBJMODEL
clear global AZ ELV SUBID

% function pose = annotate_one_obj_pose(window, objmodel, objidx, elevation)
% pose = struct('subid', 1, 'az', cell(num, 1), 'el', cell(num, 1));
% end
% 
% function h = draw_poly()
% end
% 
% function poly = get_polygon(model, elevation, azimuth)
% end

% 
% margin = floor(size(img, 1) / 5);
% 
% img2 = uint8(zeros(size(img, 1) + 2 * margin, size(img, 2) + 2 * margin, size(img, 3)));
% img2(margin+1:margin+size(img, 1), margin+1:margin+size(img, 2), :) = img;
% img = img2;
% % 
% % patch = imread('pose_anno.bmp');
% % patch = imresize(patch, [margin margin]);
% % img(end-margin+1:end, end-margin+1:end, :) = patch;
% 
% imshow(img);
% set(gcf, 'position', [1 1 800 600]);
% 
% hobjs = {};
% if nargin < 4
%     objs = struct('id', cell(1, 0), 'pose', cell(1, 0), 'poly', cell(1, 0), 'bbs', cell(1, 0));
% else
%     for i = 1:length(objs)
%         objs(i).poly = objs(i).poly + margin;
%         objs(i).bbs(1:2) = objs(i).bbs(1:2) + margin;
%         objs(i).pose = objs(i).pose + margin;
%         
%         poly = objs(i).poly;        
%         hobj = showObj(gca, objs(i));
%         hobjs{i} = showPose(gca, hobj, objs(i));
%     end
% end
% 
% cnt = length(objs);
% while(1)
%     title(['Please annotate ' name 's, if done please press esc']);    
%     assert(cnt == length(objs));
%     
%     poly = getclosedpoly;
%     if(isempty(poly))
%         break;
%     end 
%     
%     [undo] = undoCode(poly);
%     if(undo)
%         if('y' == input('Undo last annotation? [y/n]', 's'))
%             if(cnt > 0)
%                 hideObj(hobjs{cnt});
%                 objs(cnt) = [];
%                 cnt = cnt - 1;
%             end
%         else
%             disp('WARNING: Annotation smaller than 10 pixle is not allowed (dedicated for undo code). Press ESC if you want to finish!');
%         end
%         continue;
%     end
%     
%     bbox = [min(poly(:, 1)), min(poly(:, 2)), ...
%                 max(poly(:, 1)) - min(poly(:, 1)) + 1, ...
%                 max(poly(:, 2)) - min(poly(:, 2)) + 1];
% 
%     cnt = cnt + 1;
%     
%     objs(cnt).id = id;
%     objs(cnt).poly = poly;
%     objs(cnt).bbs = bbox;
%                 
%     hobj = showObj(gca, objs(cnt));
%     cpt = [objs(cnt).bbs(1) + objs(cnt).bbs(3) / 2, objs(cnt).bbs(2) + objs(cnt).bbs(4) / 2];
%     
%     objs(cnt).pose = getPoseDirection(cpt);
%     hobjs{cnt} = showPose(gca, hobj, objs(cnt));
% end
% 
% for i = 1:length(objs)
%     objs(i).poly = objs(i).poly - margin;
%     objs(i).bbs(1:2) = objs(i).bbs(1:2) - margin;
%     objs(i).pose = objs(i).pose - margin;
% end
% clf;
% 
% end
% 
% function hobj = showObj(p, obj)
% bbs = obj.bbs;
% poly = obj.poly;
% % pose = obj.pose;
% xdata = [bbs(1); bbs(1) + bbs(3) - 1; bbs(1) + bbs(3) - 1; bbs(1); bbs(1)];
% ydata = [bbs(2); bbs(2); bbs(2) + bbs(4) - 1; bbs(2) + bbs(4) - 1; bbs(2)];
% hobj.bbs = line('Parent', p, ...
%           'XData', xdata, ...
%           'YData', ydata, ...
%           'Visible', 'on', ...
%           'Clipping', 'off', ...
%           'Color', 'r', ...
%           'LineStyle', '--', ...
%           'LineWidth', 2);
%       
% xdata = [poly(:,1);poly(1,1)];
% ydata = [poly(:,2);poly(1,2)];
% hobj.poly = line('Parent', p, ...
%           'XData', xdata, ...
%           'YData', ydata, ...
%           'Visible', 'on', ...
%           'Clipping', 'off', ...
%           'Color', 'w', ...
%           'LineStyle', '-', ...
%           'LineWidth', 4);
% end
% 
% function hobj = showPose(p, hobj, obj)
% xdata = obj.pose(:,1);
% ydata = obj.pose(:,2);
% hobj.pose = line('Parent', p, ...
%           'XData', xdata, ...
%           'YData', ydata, ...
%           'Visible', 'on', ...
%           'Clipping', 'off', ...
%           'Color', 'g', ...
%           'LineStyle', '-', ...
%           'LineWidth', 2);
% end
% 
% function hobj = hideObj(hobj)
% set(hobj.bbs, 'Visible', 'off');
% set(hobj.poly, 'Visible', 'off');
% set(hobj.pose, 'Visible', 'off');
% end