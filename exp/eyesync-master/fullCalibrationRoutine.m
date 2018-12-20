% Calibration routine for SMI IViewX eyetracker and Psychtoolbox,
% using the serial port for communication.
%
% Run through calibration and validation with feedback for accepting
% and rejecting calibrations (wraps calibrateEyeTracker and
% validateCalibration). Press spacebar to start, and to accept the first
% (central) point whenever it appears. At the end of the routine (or
% whenever you press the quitkey [default esc]), you will be prompted to
% accept the calibration with the 'y' or 'n' keys. If you reject it, you
% will have the option to try again ('y' or 'n' keys again).
%
% INPUTS
% window - Psychtoolbox window
% ET_serial - Matlab serial port instance, port open
% varargin - any named arguments as follows (nb, we leave a few blanks here
% to defer to calibrateEyeTracker defaults in the absence of user input)
% struct(...
% 	'npoints',[],...
% 	'calibarea',[],...
% 	'bgcolour',[128 128 128],...
% 	'targcolour',[0 0 0],...
% 	'targsize',5,...
% 	'acceptkey',KbName('space'),...
% 	'quitkey',KbName('escape'),...
%   'skipkey',KbName('s'),...
%   'waitforvalid',[],...
%   'randompointorder',[],...
%   'autoaccept',[],...
%   'checklevel',[]);
%
% OUTPUT
% success - true if calibration completed successfully, false otherwise
%
% J Carlin, MRC CBU, 2018 revision
%
% success = fullCalibrationRoutine(window,ET_serial,varargin);
function success = fullCalibrationRoutine(window,ET_serial,varargin)

KbName('UnifyKeyNames');
% nb, we leave a few blanks here to defer to calibrateEyeTracker defaults
% in the absence of user input
par = varargparse(varargin,struct(...
	'npoints',[],...
	'calibarea',[],...
	'bgcolour',[128 128 128],...
	'targcolour',[0 0 0],...
	'targsize',5,...
	'acceptkey',KbName('space'),...
	'quitkey',KbName('escape'),...
    'skipkey',KbName('s'),...
    'waitforvalid',[],...
    'randompointorder',[],...
    'autoaccept',[],...
    'checklevel',[]));

txtwrap = 50;
vspacing = 1.5;
respy = KbName('y');
respn = KbName('n');

Screen(window,'FillRect',par.bgcolour);
DrawFormattedText(window,['Follow the target as it moves around '...
    'the screen.'],'center','center',par.targcolour,txtwrap,0,0, ...
    vspacing);
Screen(window,'Flip');
success = 0;
response = waitRespAlts([par.acceptkey,par.skipkey]);
if response==2
    return
end
% to release key
WaitSecs(.2);
ready = 0;
while ~ready
    success = calibrateEyeTracker(window,ET_serial,...
        'npoints',par.npoints,...
        'calibarea',par.calibarea,...
        'bgcolour',par.bgcolour,...
        'targcolour',par.targcolour,...
        'targsize',par.targsize,...
        'acceptkey',par.acceptkey,...
        'quitkey',par.quitkey,...
        'waitforvalid',par.waitforvalid,...
        'randompointorder',par.randompointorder,...
        'autoaccept',par.autoaccept,...
        'checklevel',par.checklevel);
    if success
        validateCalibration(window,ET_serial,...
            'bgcolour',par.bgcolour,...
            'targcolour',par.targcolour,...
            'targsize',par.targsize,...
            'acceptkey',par.acceptkey,...
            'quitkey',par.quitkey);
    end
	DrawFormattedText(window,'Calibration ok?','center','center',...
		par.targcolour,txtwrap,0,0,vspacing);
	Screen(window,'Flip');
	response = waitRespAlts([respy respn]);
	if response == 1
		ready = 1;
		success = 1;
	else
		DrawFormattedText(window,'Try again?','center','center',...
			par.targcolour,txtwrap,0,0,vspacing);
		Screen(window,'Flip');
		resp2 = waitRespAlts([respy respn]);
		if resp2 == 2
			ready = 1;
			success = 0;
		end
	end
end
% finish on blank screen
Screen(window,'Flip');