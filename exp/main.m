%% startup
diary
sub_argin = input('Please input subject id\n');
if ischar(sub_argin)
    sub_id = str2num(sub_argin);
elseif ~isnan(sub_argin)
    sub_id = sub_argin;
else
    sub_id = 9999;
end
sub_argin = input('Please input subject sex\n','s');
sub_sex = sub_argin(1);
sub_argin = input('Please input subject age\n');
sub_age = sub_argin;
%subject_info = [num2str(subject_number),',',subject_sex,',',num2str(subject_age)];

%% Settings
rng(sub_id);
%PsychDefaultSetup(1);
caller = 'base';
displaySetup;

% instruction & data file
if ~exist('data\data.csv', 'file')
    mkdir('data');
    fid = fopen('data\data.csv', 'a');
    fprintf(fid, 'sub_id, sub_sex, sub_age, block_id, trial_id, gain_on_left, gamble_duration, gambles, sure_reward, choose_sure, reaction_time');
else
    fid = fopen('data\data.csv', 'a');
end
formerData = readtable('data\data.csv');
subSeq = length(unique([formerData.sub_id; sub_id]));
clear formerData

%% run
% instruct

insFiles = dir('instruction\instruction (*).bmp');
insTexture = nan(length(insFiles), 1);
for i_ins = 1:length(insFiles)
    insTexture(sscanf(insFiles(i_ins).name, 'instruction (%d).bmp')) = Screen('MakeTexture', display_info.wPtr, imread(['instruction\', insFiles(i_ins).name]));
end
clear insFiles
markerFiles = dir('instruction\markers\*.jpg');
markers = struct();
for i_marker = 1:length(markerFiles)
    eval(sprintf('markers.%s = Screen(''MakeTexture'', display_info.wPtr, imread(''instruction\\markers\\%s.jpg''));', markerFiles(i_marker).name(1:end-4), markerFiles(i_marker).name(1:end-4)));
end
clear markerFiles
i_ins = 1;
while i_ins <= length(insTexture)
    Screen('DrawTexture', display_info.wPtr, insTexture(i_ins), [], display_info.window_rect)
    Screen('Flip', display_info.wPtr);
    while 1
        [~, reactKey] = KbWait([],3);
        if reactKey(KbName(display_info.exit_key))
            sca;
            break
        elseif reactKey(KbName('leftArrow'))
            i_ins = i_ins - 1;
            if i_ins <= 0
                i_ins = 1;
            end
            break
        elseif reactKey(KbName('rightArrow'))
            i_ins = i_ins + 1;
            if i_ins >= length(insTexture)
                i_ins = length(insTexture);
            end
            break
        elseif reactKey(KbName('space')) && i_ins == length(insTexture)
            i_ins = i_ins + 1;
            break
        end
    end
end

trials = generateTrials();

% practice 1
waitForSpace('prac_1');
for i_practice = 1:design_info.n_practice_1
    tempTrial = copy(trials(randi(length(trials))));
    tempDisplayInfo = display_info;
    tempDisplayInfo.time_limit = 9999;
    tempTrial.block_id = -1;
    tempTrial.show(tempDisplayInfo);
    tempTrial.write(fid);
end
% practice 2
waitForSpace('prac_2');
for i_practice = 1:design_info.n_practice_2
    tempTrial = copy(trials(randi(length(trials))));
    tempDisplayInfo = display_info;
    tempTrial.block_id = -2;
    tempTrial.show(tempDisplayInfo);
    tempTrial.write(fid);
end

% trial
waitForSpace('prac_end');
for i_trial = 1:length(trials)
    trials(i_trial).show(display_info);
    trials(i_trial).write(fid);
    if mod(i_trial, round(length(trials)/6)) == 0 && i_trial ~= length(trials)
        Screen('DrawTexture', display_info.wPtr, markers.rest, [], display_info.window_rect)
        Screen('Flip', display_info.wPtr);
        WaitSecs(30);
        waitForSpace('rest_end');
    end
end
waitForSpace('exp_end');

fclose(fid);
sca;

function waitForSpace(texture)
display_info = evalin('caller', 'display_info');
Screen('DrawTexture', display_info.wPtr, evalin('caller', ['markers.', texture]), [], display_info.window_rect)
Screen('Flip', display_info.wPtr);
while 1
    [~, reactKey] = KbWait([], 3);
    if reactKey(KbName(display_info.exit_key))
        sca
        break
    elseif reactKey(KbName('space'))
        break
    end
end
end