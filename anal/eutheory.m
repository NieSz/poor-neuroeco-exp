function [logPrChooseSureSum] = eutheory(trialin, parameters)
%EUTHEORY Summary of this function goes here
%   Detailed explanation goes here
logPrChooseSureSum = 0;
for i_trial = 1:length(trialin)
    values = [trialin(i_trial).sure_reward, trialin(i_trial).gambles(end,:)];
    %     disp(values)
    weightedUtilities = ((values >= 0) - parameters(2).*(values < 0)).*abs(values).^parameters(1).*[1 -0.5 -0.5];
    if trialin(i_trial).choose_sure == 0
        logPrChooseSure =  -log(1-1/(1+exp(-sum(weightedUtilities).*parameters(3))));
    elseif trialin(i_trial).choose_sure == 1
        logPrChooseSure = -log(1/(1+exp(-sum(weightedUtilities).*parameters(3))));
    end
    logPrChooseSureSum = logPrChooseSureSum + logPrChooseSure;
end
if isnan(logPrChooseSureSum) || abs(logPrChooseSureSum) == inf
%     error('error')
    logPrChooseSureSum = 1000;
end
% if length(trialin) == 1
% else
%     logPrChooseSure = eutheory(trialin(end),parameters) + eutheory(trialin(1:end-1),parameters);
% end
end