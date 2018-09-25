% trialTable = readtable('data\data.csv');
% trials(height(trialTable),1) = trial();
% for i_trial = 1:length(trials)
%     trials(i_trial).read(trialTable(i_trial,:));
% end
% pretrials = trials([trials.block_id] > 0);
%
% reactTooEarly = nan(length(subs),1);
%
% for i_sub = 1:length(subs)
%
%     trials = pretrials([pretrials.sub_id] == subs(i_sub));
%
%     reactTooEarly(i_sub) = sum([trials.reaction_time] <= 0, 'omitnan') ./ length(trials);
%
%     trials = trials([trials.reaction_time] > 0);
% end

%%
subs = [18092201,18092203,18092204,18092301,18092302,18092304,18092402];

%%
alphas = nan(length(subs),3);
lambdas = nan(length(subs),3);
temperatures = nan(length(subs),3);
logLs = nan(length(subs),3);
times = [0.5, 1.0, 2.0];
itTimes = 48;
% parpool(feature('numcores'))
for i_sub = 1:length(subs)
    subTrials = getSubData(subs(i_sub));
    for i_time = 1:length(times)
        subSubTrials = subTrials([subTrials.gamble_duration] == times(i_time));
        funOpt = @(parameters)-eutheory(subSubTrials, parameters);
        tempParaList = nan(itTimes,3);
        tempLogL = nan(itTimes,1);
        parfor i_it = 1:itTimes
            [parameters, logL] = fminsearch(funOpt, rand(1,3).*[1,10,1]);
            tempParaList(i_it,:) = parameters;
            tempLogL(i_it) = logL;
            fprintf('.');
        end
        logLs(i_sub,i_time) = min(tempLogL);
        alphas(i_sub,i_time) = tempParaList(tempLogL == min(tempLogL),1);
        lambdas(i_sub,i_time) = tempParaList(tempLogL == min(tempLogL),2);
        temperatures(i_sub,i_time) = tempParaList(tempLogL == min(tempLogL),3);
        fprintf('\n%d.%d:%.2f,%.1f,%.2f\n',i_sub,i_time,alphas(i_sub,i_time),lambdas(i_sub,i_time),logLs(i_sub,i_time));
    end
end

%% plot utility function
lineColor = {[1,0,0], [0,1,0], [0,0,1]};
subs = [18092201:18092204,18092301:18092304,18092402];
xRange = -20:0.1:20;
for i_sub = 1:length(subs)
    for i_time = 1:length(times)
        subplot(2,4,i_sub)
        plot(xRange, real((xRange >= 0).*xRange.^alphas(i_sub,i_time) - lambdas(i_sub,i_time).*(xRange < 0).*(-xRange).^alphas(i_sub,i_time)),'Color',lineColor{i_time},'LineWidth',1.5);
        hold on
    end
    xlim([-20, 20]);
    ylim([-20, 20]);
    line([-20, 20], [0, 0], 'Color','black','LineStyle','--');
    xlabel('value');
    axis square
    ylabel('utility');
end
legend({'0.5','1.0','2.0'});

%% plot averaged
lineColor = {[1,0,0], [0,1,0], [0,0,1]};
subs = [18090301, 18090302, 18090303, 18090304, 18090403, 18090404];
xRange = -20:0.1:20;
utilities = nan(length(xRange),length(times),length(subs));
for i_sub = 1:length(subs)
    for i_time = 1:length(times)
        utilities(:,i_time,i_sub) = real((xRange >= 0).*xRange.^alphas(i_sub,i_time) - lambdas(i_sub,i_time).*(xRange < 0).*(-xRange).^alphas(i_sub,i_time));
    end
end
meanUtilities = nanmean(utilities,3);
seUtilities = nanstd(utilities,[],3)./sqrt(length(subs));
for i = 1:3
    tempA = area(xRange',[meanUtilities(:,i)-seUtilities(:,i),2.*seUtilities(:,i)],'LineStyle','none');
    tempA(1).FaceColor = [1,1,1];
    tempA(1).FaceAlpha = 0;
    tempA(2).FaceColor = lineColor{i}.*0.5;
    tempA(2).FaceAlpha = 0.2;
    hold on
end
lh = nan(3,1);
for i = 1:3
    lh(i) = plot(xRange,meanUtilities(:,i)','Color',lineColor{i},'LineWidth',1.5);
end
legend(lh,{'0.5','1.0','2.0'})
xlabel('value');
ylabel('utility');

%% anova of eu model
betaTable = table(alphas(1:6,1),alphas(1:6,2),alphas(1:6,3),lambdas(1:6,1),lambdas(1:6,2),lambdas(1:6,3),temperatures(1:6,1),temperatures(1:6,2),temperatures(1:6,3),'VariableNames',{'alpha_0dot5','alpha_1dot0','alpha_2dot0','lambda_0dot5','lambda_1dot0','lambda_2dot0','temperature_0dot5','temperature_1dot0','temperature_2dot0'});
betaNames = {'alpha','lambda','temperature'};
for i = 1:3
    tempModel = fitrm(betaTable,sprintf('%s_0dot5,%s_1dot0,%s_2dot0~1',betaNames{i},betaNames{i},betaNames{i}),'WithinDesign',[0.5 1 2]);
    ranova(tempModel)
end


%% GLM
subs = [18092201,18092203,18092204,18092301,18092302,18092304,18092402];
%subs = [18092201:18092204,18092301:18092304,18092402];
times = [0.5, 1.0, 2.0];
betas = nan(length(subs).*length(times), 5);
devs = nan(length(subs).*length(times), 1);
slopes = nan(length(subs), length(times))';
constant = nan(length(subs), length(times))';
for i_sub = 1:length(subs)
    subTrials = getSubData(subs(i_sub));
    for i_time = 1:length(times)
        subSubTrials = subTrials([subTrials.gamble_duration] == times(i_time));
        [tempBetas, tempDevs] = glmfit(zscore([([subSubTrials.sure_reward]' > 0).*[subSubTrials.sure_reward]',([subSubTrials.sure_reward]' < 0).*[subSubTrials.sure_reward]',-reshape([subSubTrials.key_gamble],2,length(subSubTrials))']), [subSubTrials.choose_sure]','binomial');
        betas((i_time-1).*length(subs)+i_sub,:) = tempBetas./sum(abs(tempBetas));
        devs((i_time-1).*length(subs)+i_sub,:) = tempDevs;
        
        chooseSqr = zeros(37);
        allSqr = zeros(37);
        for i_trial = 1:length(subSubTrials)
            chooseSqr(round(subSubTrials(i_trial).sure_reward) + 19, round(sum(subSubTrials(i_trial).key_gamble)/2) + 19) = chooseSqr(round(subSubTrials(i_trial).sure_reward) + 19, round(sum(subSubTrials(i_trial).key_gamble)/2) + 19) + subSubTrials(i_trial).choose_sure;
            allSqr(round(subSubTrials(i_trial).sure_reward) + 19, round(sum(subSubTrials(i_trial).key_gamble)/2) + 19) = allSqr(round(subSubTrials(i_trial).sure_reward) + 19, round(sum(subSubTrials(i_trial).key_gamble)/2) + 19) + 1;
        end
        imSqr = chooseSqr./allSqr;
        imSqr(allSqr == 0) = -1;
        subplot(3,length(subs),(i_time-1).*length(subs)+i_sub)
        colormap([ones(100,1).*[0.5 0.5 0.5];parula(101)]);
        axis square
        imagesc(imSqr);
        axis xy
        xticks(1:6:37);
        xticklabels({-18:6:18})
        yticks(1:6:37);
        yticklabels({-18:6:18})
        
        [tempBetas, tempDevs] = glmfit(zscore([[subSubTrials.sure_reward]',mean(reshape([subSubTrials.key_gamble],2,length(subSubTrials)))']), [subSubTrials.choose_sure]','binomial');
        line([0, 39],-(tempBetas(3).*([0, 39]-19)+tempBetas(1))./tempBetas(2) + 19,'Color','red');
        slopes(i_time,i_sub) = -tempBetas(3)./tempBetas(2);
        constant(i_time,i_sub) = tempBetas(1);
        axis square
    end
end

%% anova of GLM betas
betaTable = table(betas(1:6,1),betas(7:12,1),betas(13:18,1),betas(1:6,2),betas(7:12,2),betas(13:18,2),betas(1:6,3),betas(7:12,3),betas(13:18,3),'VariableNames',{'sure_reward_0dot5','sure_reward_1dot0','sure_reward_2dot0','gain_0dot5','gain_1dot0','gain_2dot0','loss_0dot5','loss_1dot0','loss_2dot0'});
betaNames = {'sure_reward','gain','loss'};
for i = 1:3
    tempModel = fitrm(betaTable,sprintf('%s_0dot5,%s_1dot0,%s_2dot0~1',betaNames{i},betaNames{i},betaNames{i}),'WithinDesign',[0.5 1 2]);
    ranova(tempModel)
end

%% sr
betaTable = table(betas(1:length(subs),2),betas(1+length(subs):2*length(subs),2),betas(1+2*length(subs):3*length(subs),2),betas(1:length(subs),3),betas(1+length(subs):2*length(subs),3),betas(1+2*length(subs):3*length(subs),3),'VariableNames',{'sure_reward_plus_0dot5','sure_reward_plus_1dot0','sure_reward_plus_2dot0','sure_reward_minus_0dot5','sure_reward_minus_1dot0','sure_reward_minus_2dot0'});
%betaTable = betaTable(1:end-1,:);
Meas = table([0.5 1 2 0.5 1 2]',categorical({'+', '+', '+', '-', '-', '-'})', 'VariableNames',{'time','sign'});
tempModel = fitrm(betaTable,'sure_reward_plus_0dot5,sure_reward_plus_1dot0,sure_reward_plus_2dot0,sure_reward_minus_0dot5,sure_reward_minus_1dot0,sure_reward_minus_2dot0~1','WithinDesign',Meas, 'WithinModel', 'time+sign+time*sign');
ranova(tempModel, 'WithinModel', 'time+sign+time*sign')
%% gamble
betaTable = table(betas(1:length(subs),4),betas(1+length(subs):2*length(subs),4),betas(1+2*length(subs):3*length(subs),4),betas(1:length(subs),5),betas(1+length(subs):2*length(subs),5),betas(1+2*length(subs):3*length(subs),5),'VariableNames',{'sure_reward_plus_0dot5','sure_reward_plus_1dot0','sure_reward_plus_2dot0','sure_reward_minus_0dot5','sure_reward_minus_1dot0','sure_reward_minus_2dot0'});
%betaTable = betaTable(1:end-1,:);
Meas = table([0.5 1 2 0.5 1 2]',categorical({'+', '+', '+', '-', '-', '-'})', 'VariableNames',{'time','sign'});
tempModel = fitrm(betaTable,'sure_reward_plus_0dot5,sure_reward_plus_1dot0,sure_reward_plus_2dot0,sure_reward_minus_0dot5,sure_reward_minus_1dot0,sure_reward_minus_2dot0~1','WithinDesign',Meas, 'WithinModel', 'time+sign+time*sign');
ranova(tempModel, 'WithinModel', 'time+sign+time*sign')