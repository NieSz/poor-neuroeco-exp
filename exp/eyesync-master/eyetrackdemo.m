% a simple demo script to illustrate basic functionality for SMI serial
% port communication combined with psychtoolbox.
%
% 31/1/2018 J Carlin
%
% eyetrackdemo()
function eyetrackdemo

% find any lingering serial port connections
f = instrfind;
badind = strcmp(get(f,'Status'),'open');
if any(badind)
    fprintf('closing open serial port connection...\n');
    fclose(f(badind));
end

ET_serial = serial('COM1','BaudRate',115200,'Databits',8,'RequestToSend','off');
err = [];
try
    set(ET_serial,'timeout',0.1);
    fopen(ET_serial);
    warning('off','MATLAB:serial:fgetl:unsuccessfulRead');
    screen = Screen('OpenWindow',0);
    HideCursor;
    success = fullCalibrationRoutine(screen,ET_serial,'npoints',5,'randompointorder',1);
    fprintf('calibration succeeded (1/0): %d\n',success);
    % 2 seconds of data
    fprintf(ET_serial,'ET_REC');
    fprintf(ET_serial,'ET_REM test start');
    WaitSecs(2);
    fprintf(ET_serial,'ET_REM test finished');
    % stop and save
    fprintf(ET_serial,'ET_STP');
    % appears under C:\Program Files\SMI\iView X\ on the eye track PC. Time
    % stamp is a good idea because saving will fail if the filename already
    % exists!
    fprintf(ET_serial,...
        ['ET_SAV testdata_' datestr(now,'yyyymmdd_HHMM_SS') '.idf']);
catch err
    fprintf('CRASH\n');
end
% clean up
fclose(ET_serial);
sca;
warning('on','MATLAB:serial:fgetl:unsuccessfulRead');
% rethrow any error
if isempty(err)
    fprintf('test finished successfully\n');
else
    rethrow(err);
end