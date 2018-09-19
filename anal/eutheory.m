function [logPrChooseSure] = eutheory(trialin, parameters)
%EUTHEORY Summary of this function goes here
%   Detailed explanation goes here
if length(trialin) == 1
    values = [trialin.sure_reward, trialin.gambles(end,:)];
    weightedUtilities = real((values >= 0).*values.^parameters(1) - parameters(2).*(values < 0).*(-values).^parameters(1)).*[1 -0.5 -0.5];
    logPrChooseSure = log(1/(1+exp(-sum(weightedUtilities).*parameters(3)))).*trialin.choose_sure + log(1-1/(1+exp(-sum(weightedUtilities).*parameters(3)))).*(1-trialin.choose_sure);
else
    logPrChooseSure = eutheory(trialin(end),parameters) + eutheory(trialin(1:end-1),parameters);
end
end