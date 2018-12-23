% Calibration routine for SMI IViewX eyetracker and Psychtoolbox,
% using the serial port for communication. This function validates
% a previous calibration.

% NB, MeanDevXY is in deg visual angle, so is completely dependent on
% you appropriately configuring IViewX settings to match your setup. The
% other values are in pixels.
% Currently only reports validation parameters for the left eye if tracking
% binocular. As near as I can tell, this information is never transmitted,
% so little can be done at this end.
%
% INPUTS
% window - Psychtoolbox window
% ET_serial - Matlab serial port instance, port open
% varargin - any named arguments as follows (if you change these, check
% that you set the same in calibrateEyeTracker for sanity)
% 	bgcolour - ([128 128 128]) background colour (RGB)
% 	targcolour - ([0 0 0]) target colour (RGB)
% 	targsize - (5) target height/width in pixels
% 	acceptkey - ([spacebar]) key for forcing point acceptance
% 	quitkey - ([escapekey]) key for aborting calibration
% 		Use KbName('UnifyKeyNames') to get names for other keys
%   timeout - (20) time to wait before returning if we get stuck (e.g.,
%       serial port communication failure, lost pupil tracking)
%
% 13/4/2010 J Carlin
% 31/1/2018 updated for better arg handling
%
% [ready,RMSdev, RMSdevdist, MeanDevXY] = validateCalibration(window,ET_serial,varargin)

function [ready,RMSdev, RMSdevdist, MeanDevXY] = validateCalibration(window,ET_serial,varargin)

KbName('UnifyKeyNames');
par = varargparse(varargin,struct(...
    'bgcolour',[128 128 128],...
    'targcolour',[0 0 0],...
    'targsize',5, ...
    'acceptkey',KbName('space'), ...
    'quitkey',KbName('escape'),...
    'timeout',20));

% Draw background
Screen(window,'FillRect',par.bgcolour);

% Start validation
fprintf(ET_serial,sprintf('ET_VLS'));
ready = 0;
readyonce = 0; % Extra check to catch second eye in bino mode
ntries = 0;
points = zeros(13,2);

% Initialise output vars for graceful errors
RMSdev = [];
RMSdevdist = [];
MeanDevXY = [];

rc = 0;
lastcontact = GetSecs;
while ~ready
    ntries = ntries+1;

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
            %WaitSecs(.2); % Time to let go of key...
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

    % Ensure a second run through after receiving the first
    % ET_VLS return, so that we catch the second eye too.
    if readyonce
        ready = 1;
    end

    % Check if the eye tracker has something to say
    response = readserial(ET_serial);

    % What might the eye tracker have to say?
    for n = 1:numel(response)
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
        if strcmp(command_etc{1},'ET_CHG')
            % Coordinates for point
            xy = points(str2num(command_etc{2}),:)';
            Screen('DrawDots',window,xy,par.targsize,par.targcolour);
            Screen(window,'Flip');
            % Reset timeout counter
            ntries = 0;

            % Calibation point definition
        elseif strcmp(command_etc{1},'ET_PNT')
            points(str2num(command_etc{2}),:) = ...
                [str2num(command_etc{3}) str2num(command_etc{4})];

            % Validation finished
            % The twist here is that ET_VLS returns twice if
            % in binocular mode... So need to go through a last
            % check after finishing this.
        elseif strcmp(command_etc{1},'ET_VLS')
            % Command_etc should now contain various numbers
            values = str2num(char(command_etc(3:5)))';
            % SMI for some reason insists on including a degree
            % symbol for the last 2, which complicates things...
            values(end+1) = str2num(command_etc{6}(1:end-1));
            values(end+1) = str2num(command_etc{7}(1:end-1));

            if ~readyonce
                RMSdev = values(1:2);
                RMSdevdist = values(3);
                MeanDevXY = values(4:5);
            else % Right eye
                RMSdev(2,:) = values(1:2);
                RMSdevdist(2,:) = values(3);
                MeanDevXY(2,:) = values(4:5);
            end
            readyonce = 1;


            % Various commands we don't care about
        elseif strcmp(command_etc{1},'ET_REC') || ...
                strcmp(command_etc{1},'ET_CLR') || ...
                strcmp(command_etc{1},'ET_CAL') || ...
                strcmp(command_etc{1},'ET_CSZ') || ...
                strcmp(command_etc{1},'ET_ACC') || ...
                strcmp(command_etc{1},'ET_CPA') || ...
                strcmp(command_etc{1},'ET_FIN') || ...
                strcmp(command_etc{1},'ET_LEV')
            continue

            % Catch all
        else
            fprintf(sprintf(['Validation failed - received unrecognised '...
                'input: %s\n'],response{n}));
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
