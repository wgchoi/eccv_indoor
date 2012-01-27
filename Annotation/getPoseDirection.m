function varargout = getPoseDirection(varargin)
global REF
global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y

xlimorigmode = xlim('mode');
ylimorigmode = ylim('mode');
xlim('manual');
ylim('manual');

if ((length(varargin) >= 1) && ischar(varargin{1}))
    % Callback invocation: 'ButtonDown',
    % 'NextButtonDown', or 'ButtonMotion'.
    feval(varargin{:});
    return;
end

if((length(varargin) >= 1) && isnumeric(varargin{1}))
    GETLINE_AX = gca;
    GETLINE_FIG = ancestor(GETLINE_AX, 'figure');
    
    assert(length(varargin{1}) == 2);
    
    GETLINE_X = varargin{1}(1);
    GETLINE_Y = varargin{1}(2);

    % Remember initial figure state
    state= uisuspend(GETLINE_FIG);

    % Set up initial callbacks for initial stage
    set(GETLINE_FIG, ...
        'Pointer', 'crosshair', ...
        'WindowButtonDownFcn', 'getPoseDirection(''ButtonDown'');', ...
        'WindowButtonMotionFcn', 'getPoseDirection(''ButtonMotion'');');

    % Bring target figure forward
    figure(GETLINE_FIG);

    % Initialize the lines to be used for the drag
    GETLINE_H1 = line('Parent', GETLINE_AX, ...
                      'XData', GETLINE_X, ...
                      'YData', GETLINE_Y, ...
                      'Visible', 'on', ...
                      'Clipping', 'off', ...
                      'Color', 'k', ...
                      'LineStyle', '-', 'LineWidth', 2);

    GETLINE_H2 = line('Parent', GETLINE_AX, ...
                      'XData', GETLINE_X, ...
                      'YData', GETLINE_Y, ...
                      'Visible', 'on', ...
                      'Clipping', 'off', ...
                      'Color', 'w', ...
                      'LineStyle', ':', 'LineWidth', 2);

    % We're ready; wait for the user to do the drag
    % Wrap the call to waitfor in try-catch so we'll
    % have a chance to clean up after ourselves.
    errCatch = 0;
    try
        waitfor(GETLINE_H1, 'UserData', 'Completed');
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

    elseif (~ishghandle(GETLINE_H1) || ...
                ~strcmp(get(GETLINE_H1, 'UserData'), 'Completed'))
        errStatus = 'unknown';

    else
        errStatus = 'ok';
        x = GETLINE_X(:);
        y = GETLINE_Y(:);
        % If no points were selected, return rectangular empties.
        % This makes it easier to handle degenerate cases in
        % functions that call getline_local.
        if (isempty(x))
            x = zeros(0,1);
        end
        if (isempty(y))
            y = zeros(0,1);
        end
    end

    % Delete the animation objects
    if (ishghandle(GETLINE_H1))
        delete(GETLINE_H1);
    end
    if (ishghandle(GETLINE_H2))
        delete(GETLINE_H2);
    end

    % Restore the figure's initial state
    if (ishghandle(GETLINE_FIG))
       uirestore(state);
    end

    CleanUp(xlimorigmode,ylimorigmode);

    % Depending on the error status, return the answer or generate
    % an error message.
    switch errStatus
    case 'ok'
        % Return the answer
        if (nargout >= 2)
            varargout{1} = x;
            varargout{2} = y;
        else
            % Grandfathered output syntax
            varargout{1} = [x(:) y(:)];
        end
    case 'trap'
        % An error was trapped during the waitfor
        error(message('images:getline_local:interruptedMouseSelection'));
    case 'unknown'
        % User did something to cause the polyline selection to
        % terminate abnormally.  For example, we would get here
        % if the user closed the figure in the middle of the selection.
        error(message('images:getline_local:interruptedMouseSelection'));
    end
end
end

%--------------------------------------------------
% Subfunction FirstButtonDown
%--------------------------------------------------
function ButtonDown %#ok

global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y

[x,y] = getcurpt(GETLINE_AX);

% check if GETLINE_X,GETLINE_Y is inside of axis
xlim = get(GETLINE_AX,'xlim');
ylim = get(GETLINE_AX,'ylim');
if (x>=xlim(1)) && (x<=xlim(2)) && (y>=ylim(1)) && (y<=ylim(2))
    % inside axis limits
    GETLINE_X(2) = x;
    GETLINE_Y(2) = y;
else
    % outside axis limits, ignore this FirstButtonDown
    return
end

set([GETLINE_H1 GETLINE_H2], ...
        'XData', GETLINE_X, ...
        'YData', GETLINE_Y, ...
        'Visible', 'on');

set(GETLINE_H1, 'Color', 'b', ...
                  'LineStyle', '-');
set(GETLINE_H2, 'Color', 'r', ...
                  'LineStyle', ':');
              
% Let the motion functions take over.
set(GETLINE_FIG, 'WindowButtonMotionFcn', 'getPoseDirection(''ButtonMotion'');', ... 
    'WindowButtonUpFcn', 'getPoseDirection(''ButtonUp'');');
end

%-------------------------------------------------
% Subfunction ButtonMotion
%-------------------------------------------------
function ButtonMotion %#ok

global GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y

[newx, newy] = getcurpt(GETLINE_AX);
GETLINE_X(2) =  newx;
GETLINE_Y(2) =  newy;

set([GETLINE_H1 GETLINE_H2], 'XData', GETLINE_X, 'YData', GETLINE_Y);
end

function ButtonUp

global GETLINE_AX GETLINE_H1 GETLINE_H2
global GETLINE_X GETLINE_Y

set(GETLINE_H1, 'UserData', 'Completed');

end

%---------------------------------------------------
% Subfunction CleanUp
%--------------------------------------------------
function CleanUp(xlimmode,ylimmode)

xlim(xlimmode);
ylim(ylimmode);
% Clean up the global workspace
clear global GETLINE_FIG GETLINE_AX GETLINE_H1 GETLINE_H2
clear global GETLINE_X GETLINE_Y
clear global GETLINE_ISCLOSED
end

function [x,y] = getcurpt(axHandle)
%GETCURPT Get current point.
%   [X,Y] = GETCURPT(AXHANDLE) gets the x- and y-coordinates of
%   the current point of AXHANDLE.  GETCURPT compensates these
%   coordinates for the fact that get(gca,'CurrentPoint') returns
%   the data-space coordinates of the idealized left edge of the
%   screen pixel that the user clicked on.  For IPT functions, we
%   want the coordinates of the idealized center of the screen
%   pixel that the user clicked on.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.9.4.1 $  $Date: 2003/01/26 05:59:31 $

pt = get(axHandle, 'CurrentPoint');
x = pt(1,1);
y = pt(1,2);
end