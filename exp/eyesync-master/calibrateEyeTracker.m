% Calibration routine for SMI IViewX eyetracker and Psychtoolbox,
% using the serial port for communication.
%
% INPUTS
% window - Psychtoolbox window
% ET_serial - Matlab serial port instance, port open
% varargin - any named arguments as follows (if you change these, make sure
% you make corresponding changes in validateCalibration)
% 	npoints - (9) number of calibration points
% 	calibarea - ([screenx screeny] * .8) calibration area on screen
% 	bgcolour - ([128 128 128]) background colour (RGB)
% 	targcolour - ([255 255 255]) target colour (RGB)
% 	targsize - (5) target height/width in pixels
% 	acceptkey - ([spacebar]) key for forcing point acceptance
% 	quitkey - ([escapekey]) key for aborting calibration
% 		Use KbName('UnifyKeyNames') to get names for other keys
%   waitforvalid - (1) wait for valid data during calibration
%   randompointorder - (0) randomise point order during calibration
%   autoaccept - (1) Auto-accept points after some fixation dur.
%   checklevel - (2) Fussiness when accepting points (0-3). SMI recommends
%       2 for every-day use. Drop if subject is problematic.
%   timeout - (20) time to wait before returning if we get stuck (e.g.,
%       serial port communication failure, lost pupil tracking)
%
% OUTPUTS
% success - 1 if the routine finished, 0 if it failed
% points - coordinates of calibration targets
%
% 13/4/2010 J Carlin, heavily indebted to Maarten van Caasteren's
% VB script for E-Prime
% 31/8/2012 update - refactored with better arguments through varargin
% 31/1/2018 update - even better argument handling!
%
% [success,points] = calibrateEyeTracker(window,ET_serial,varargin)


function [ready,points] = calibrateEyeTracker(window,ET_serial,varargin)

% Screen settings
sc = Screen('Resolution',window);
schw = [sc.width sc.height];
KbName('UnifyKeyNames');

% These are the default settings
par = varargparse(varargin,struct(...
    'npoints',9,...
    'calibarea',schw * .8,... % Full screen size
    'bgcolour',[128 128 128],...
    'targcolour',[0 0 0],...
    'targsize',5, ...
    'acceptkey',KbName('space'), ...
    'quitkey',KbName('escape'), ...
    'waitforvalid',1,...
    'randompointorder',0,...
    'autoaccept',1,...
    'checklevel',2,...
    'timeout',20));

% Quick sanity check
assert(any(par.npoints==[2,5,9,13]),...
    'SMI eye trackers only support 2,5,9 or 13 point calibration')

% Start and stop calibration once. This somehow
% solves a lot of problems
%fprintf(ET_serial,sprintf('ET_CAL %d',par.npoints));
%fprintf(ET_serial,'ET_BRK');
% Read whatever is outstanding to start on a blank slate
readserial(ET_serial);

% Draw background
Screen(window,'FillRect',par.bgcolour);

% Various calibration settings
fprintf(ET_serial,sprintf('ET_CPA %d %d',0,par.waitforvalid));
fprintf(ET_serial,sprintf('ET_CPA %d %d',1,par.randompointorder));
fprintf(ET_serial,sprintf('ET_CPA %d %d',2,par.autoaccept));
fprintf(ET_serial,sprintf('ET_LEV %d',par.checklevel));

% Set calibration area (ie screen res)
fprintf(ET_serial,sprintf('ET_CSZ %d %d',schw(1),schw(2)));

% These are the default ET points for a 13 point calibration on
% a 1280x1024 screen. We can tweak this according to our needs...
standardpoints = [640 512;
    64 51;
    1216 51;
    64 973;
    1216 973;
    64 512;
    640 51;
    1216 512;
    640 973;
    352 282;
    928 282;
    352 743;
    928 743];

% Scale up/down to match calibration area
scaledpoints = bsxfun(@times,standardpoints,par.calibarea ./ [1280 1024]);
% Shift the calibration points to centre on the screen
shiftedpoints = round(bsxfun(@minus,...
    bsxfun(@plus,scaledpoints,schw/2),par.calibarea/2));

% Set to appropriate par.npoints
shiftedpoints = shiftedpoints(1:par.npoints,:);

% Send custom points to eye tracker
for p = 1:length(shiftedpoints)
    fprintf(ET_serial,sprintf('ET_PNT %d %d %d',p, ...
        shiftedpoints(p,1),shiftedpoints(p,2)));
end
% Start calibration
fprintf(ET_serial,sprintf('ET_CAL %d',par.npoints));


ready = 0;
lastcontact = GetSecs;

% Point coordinates go here - just to validate
points = zeros(par.npoints,2);

rc = 0;
while ~ready

    % If we get stuck, return anyway
    if GetSecs-lastcontact > par.timeout
        fprintf('timeout exceeded!\n')
        return
    end

    % Check for manual attempts to move things along
    [keyisdown, secs, keyCode] = KbCheck;
    if keyisdown
        k = find(keyCode);
        k = k(1);
        % Force acceptance of current point
        if k == par.acceptkey
            fprintf('Accepting point...\n')
            % Now stop execution until the key is released
            while KbCheck
                WaitSecs(.01);
            end
            fprintf(ET_serial,'ET_ACC');
            % Give up on calibration
        elseif k == par.quitkey
            fprintf('Calibration attempt aborted!\n')
            fprintf(ET_serial,'ET_BRK');
            return
        end
    end

    % Check if the eye tracker has something to say
    response = readserial(ET_serial);

    % What might the eye tracker have to say? (nb, never executes if
    % response is empty)
    for n = 1:numel(response)
        lastcontact = GetSecs;
        % Save each response - mainly for debugging
        rc = rc+1;
        resplog{rc} = response{n};
        % Split by spaces
        command_etc = textscan(regexprep(response{n},' ',' '),'%s');
        % For reasons known only by the Mathworks, textscan return is
        % wrapped in a cell.
        command_etc = command_etc{1};

        %%% What we do next depends on the command we got:
        % Calibration point change
        switch command_etc{1}
            case 'ET_CHG'
                % Coordinates for point
                xy = points(str2num(command_etc{2}),:)';
                Screen('DrawDots',window,xy,par.targsize,par.targcolour);
                Screen(window,'Flip');
                % Reset timeout counter
                ntries = 0;
            case 'ET_PNT'
                % Calibation point definition
                points(str2num(command_etc{2}),:) = ...
                    [str2num(command_etc{3}) str2num(command_etc{4})];
            case 'ET_FIN'
                % Calibration finished
                ready = 1;
            case {'ET_REC','ET_CLR','ET_CAL','ET_CSZ','ET_ACC','ET_CPA',...
                    'ET_LEV'}
                % Various commands we don't care about
                continue
            otherwise
                % Catch all
                fprintf(...
                    'Calibration failed. Unrecognised input: %s\n',...
                    response{n});
                fprintf(ET_serial,'ET_BRK');
                sca;
                error('bad eyetracker input');
        end % Resp interpretation
    end % loop over response
end % While
