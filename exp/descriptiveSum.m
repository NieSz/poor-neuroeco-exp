trialTable = readtable('data\data.csv');
trials(height(trialTable),1) = trial();
for i_trial = 1:length(trials)
    trials(i_trial).read(trialTable(i_trial,:));
end
pretrials = trials([trials.block_id] > 0);

subs = [18090301, 18090302, 18090303, 18090304, 18090403, 18090404];
reactTooEarly = nan(length(subs),1);
for i_sub = 1:length(subs)

trials = pretrials([pretrials.sub_id] == subs(i_sub));
    
reactTooEarly(i_sub) = sum([trials.reaction_time] <= 0, 'omitnan') ./ length(trials);

trials = trials([trials.reaction_time] > 0);
end