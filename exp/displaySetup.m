%% General setup
display_info = jsondecode(fread(fopen('configs.json'),'*char'));
display_info = display_info.display_info;

Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');

screens = Screen('Screens');
screen_id = max(screens);
[screen_width, screen_height] = Screen('DisplaySize', screen_id);
[screen_x_size, screen_y_size] = Screen('WindowSize', screen_id);
pix_per_cm = [screen_x_size, screen_y_size]/[screen_width, screen_height].*10;
test = 0;

% Open window
if test == 1
    window_position = [screen_x_size./2, screen_y_size./4, screen_x_size, 3.*screen_y_size./4];
    [wPtr, window_rect] = PsychImaging('OpenWindow', screen_id, display_info.background_color, window_position);
    ListenChar(-1);
else
    window_position = [0, 0, screen_x_size, screen_y_size];
    [wPtr, window_rect] = PsychImaging('OpenWindow', screen_id, display_info.background_color);
    HideCursor();
    ListenChar(-1);
end

Screen('TextSize', wPtr, deg2pix(display_info.sure_reward_size));

display_info.background_color = display_info.background_color';
display_info.fixation_color = display_info.fixation_color';
display_info.fixation_radius = deg2pix(display_info.fixation_radius)';

display_info.fig_color = display_info.fig_color';
display_info.sure_reward_rect = deg2pix(display_info.sure_reward_rect)';
display_info.sure_reward_size = deg2pix(display_info.sure_reward_size)';
display_info.sure_reward_locus = display_info.sure_reward_locus';

display_info.rect_color = display_info.rect_color';
display_info.gamble_rect = deg2pix(display_info.gamble_rect)';
display_info.gamble_size = deg2pix(display_info.gamble_size);
display_info.gamble_durations = display_info.gamble_durations';
display_info.gamble_locus = display_info.gamble_locus';

display_info.rect_pen_width = deg2pix(display_info.rect_pen_width);

display_info.ready_to_choose_color = display_info.ready_to_choose_color';
display_info.fail_to_choose_color = display_info.fail_to_choose_color';

display_info.wPtr = wPtr;
display_info.window_rect = window_rect;

function pix = deg2pix(deg)
pack = evalin('base','[display_info.seat_distance, pix_per_cm]');
seat_distance = pack(1);
pix_per_cm = pack(2);
pix = round(2.*tand(deg./2).*seat_distance.*pix_per_cm);
end