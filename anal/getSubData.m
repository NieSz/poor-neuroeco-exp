function [trials] = getSubData(subs_id)
%GETSUBDATA extract data from file
%   Input ids output trials (formal trials, reacting punctually)
if evalin('base', 'exist(''trials'', ''var'') && isa(trials, ''trial'')')
    trials = evalin('base', 'trials');
else
    trialTable = readtable('data_181223.csv');
%     trialTable = readtable('data_181216.csv');
    trials(height(trialTable),1) = trial();
    for i_trial = 1:length(trials)
        trials(i_trial).read(trialTable(i_trial,:));
    end
end
if nargin ==0
    subs_id = unique([trials.sub_id]);
end
trials = trials([trials.block_id] > 0);
trials = trials(any([trials.sub_id]' == subs_id, 2));
trials = trials([trials.reaction_time] > 0.0);
%if nargout == 0
%     if evalin('base', 'exist(''trials'', ''var'')')
%         if ~evalin('base','isa(trials, ''trial'')')
%             fprintf('WARNING: var name ''trials'' repeated');
%             assignin('base', 'trials', trials);
%         end
%     else
%         assignin('base', 'trials', trials);
%     end
%end
end

