function [ configs ] = configs()
%CONFIGS 此处显示有关此函数的摘要
%   此处显示详细说明
configs = struct( ...
'display_info', struct( ...
	'seat_distance', 86, ...
     ...
	'background_color', [90, 90, 90], ...
    'prepare_color', [150, 150, 150], ...
	'fixation_color', [0, 0, 0], ...
	'fixation_radius', 0.2, ...
	'fixation_duration', 1, ...
	'intertrial_duration', 1.5, ... % not used
     ...
	'sure_reward_rect', [-3, -3, 3, 3], ...
	'sure_reward_size', 1, ... % fontsize
	'sure_reward_duration', 1.25, ...
	'sure_reward_locus', [0.5, 0.5], ...
     ...
	'gamble_rect', [-3, -3, 0, 3, -0, -3, 3, 3], ...
	'gamble_size', 2, ...
	'gamble_durations', [1.5], ...
    'interstimulus_interval', 0.25, ...
	'gamble_locus', [0.5, 0.5], ...
     ...
	'fig_color', [0, 0, 0], ...
    'payoff_color', [225 0 0; 0 200  0], ...
	'rect_pen_width', 0.2, ...
	'rect_color', [150, 150, 150], ...
	 ...
	'ready_to_choose_color', [200, 200, 200], ...
	'fail_to_choose_color', [200, 200, 200], ...
	 ...
	'exit_key', 'Escape', ...
	'sure_reward_key', 'UpArrow', ...
	'gamble_key', 'DownArrow', ...
	'time_limit', 1.5 ...
), ...
'design_info', struct( ...
	'max_payoff', 8, ...
	'payoff_unit', 1, ...
	'sure_rewards_per_gamble', 3, ...
	'gambles_per_trial', [1], ...
	'gambles_per_norm_trial', [7], ...
	'norm_trial_pr', 0.8, ...
	'max_n_gambles', 7, ...
	'blocks_per_duration', 2, ...
    'n_practice_1', 3, ...
    'n_practice_2', 10, ...
    'sure_reward_sigma', 5.45 ...
) ...
);
end

