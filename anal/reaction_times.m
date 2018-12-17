% RT Model free
% subs = [18121401 18121402 18121601 18121602 18121604 18121605];
subs = [18111001,18111002,18111003,18111004,18111101,18111102,18111104];

%% for trial_id
subplot(4,length(subs),1)
ylabel('trial_id')
colors = {[1 0 0], [0 0 1]};
for i_sub = 1:length(subs)
    subTrials = getSubData(subs(i_sub));
    for i_time = 1:2
        if i_time == 1
            subSubTrials = subTrials([subTrials.n_gambles]==7);
        else
            subSubTrials = subTrials([subTrials.n_gambles]~=7);
        end
        x_rt = [[subSubTrials.trial_id]',[subSubTrials.reaction_time]'];
        x_rt = sortrows(x_rt,1);
        
        subplot(4, length(subs), i_sub)
        plot(x_rt(:,1)', x_rt(:,2)','color',colors{i_time});
        hold on
    end
end
% for gain-loss
subplot(4,length(subs),length(subs)*2+1)
ylabel('gain-loss')
for i_sub = 1:length(subs)
    subTrials = getSubData(subs(i_sub));
    for i_time = 1:2
        if i_time == 1
            subSubTrials = subTrials([subTrials.n_gambles]==7);
        else
            subSubTrials = subTrials([subTrials.n_gambles]~=7);
        end
        x_rt_raw = [sum(reshape([subSubTrials.key_gamble],2,length(subSubTrials)),1)',[subSubTrials.reaction_time]'];
        x_rt = [unique(x_rt_raw(:,1)),splitapply(@mean, x_rt_raw(:,2),findgroups(x_rt_raw(:,1)))];
        x_rt = sortrows(x_rt,1);
        
        subplot(4, length(subs),length(subs).*2 + i_sub)
        plot(x_rt(:,1)', x_rt(:,2)','color',colors{i_time});
        hold on
    end
end
% for ev-sr
subplot(4,length(subs),length(subs)+1)
ylabel('ev-sr')
for i_sub = 1:length(subs)
    subTrials = getSubData(subs(i_sub));
    for i_time = 1:2
        if i_time == 1
            subSubTrials = subTrials([subTrials.n_gambles]==7);
        else
            subSubTrials = subTrials([subTrials.n_gambles]~=7);
        end
        x_rt_raw = [(mean(reshape([subSubTrials.key_gamble],2,length(subSubTrials)),1)-[subSubTrials.sure_reward])',[subSubTrials.reaction_time]'];
        x_rt = [unique(x_rt_raw(:,1)),splitapply(@mean, x_rt_raw(:,2),findgroups(x_rt_raw(:,1)))];
        x_rt = sortrows(x_rt,1);
        
        subplot(4, length(subs),length(subs) + i_sub)
        plot(x_rt(:,1)', x_rt(:,2)','color',colors{i_time});
        hold on
    end
end
% for expected utility - sr
subplot(4,length(subs),length(subs)*3+1)
ylabel('utility_{gamble}-utility_{sr}')
xlabel('reaction time')
for i_sub = 1:length(subs)
    subTrials = getSubData(subs(i_sub));
    for i_time = 1:2
        if i_time == 1
            subSubTrials = subTrials([subTrials.n_gambles]==7);
        else
            subSubTrials = subTrials([subTrials.n_gambles]~=7);
        end
        xRange = reshape([subSubTrials.key_gamble],2,length(subSubTrials))';
        u_gamble = mean((xRange >= 0).*xRange.^alphas(i_sub,i_time) - lambdas(i_sub,i_time).*(xRange < 0).*(-xRange).^alphas(i_sub,i_time),2);
        xRange = [subSubTrials.sure_reward]';
        u_sr = (xRange >= 0).*xRange.^alphas(i_sub,i_time) - lambdas(i_sub,i_time).*(xRange < 0).*(-xRange).^alphas(i_sub,i_time);
        x_rt_raw = round([u_gamble-u_sr,[subSubTrials.reaction_time]'].*2)./2;
        x_rt = [unique(x_rt_raw(:,1)),splitapply(@mean, x_rt_raw(:,2),findgroups(x_rt_raw(:,1)))];
        x_rt = sortrows(x_rt,1);
        
        subplot(4, length(subs),length(subs).*3 + i_sub)
        plot(x_rt(:,1)', x_rt(:,2)','color',colors{i_time});
        hold on
    end
end
label({'normal','catch'})

%% RT GLM
subs = [18121401 18121402 18121601 18121602 18121604 18121605];
for i_sub = 1:length(subs)
    subSubTrials = getSubData(subs(i_sub));
    for i_time = 1:6
        subSubTrials = subSubTrials(ceil([subSubTrials.trial_id] ./ (192/6)) == i_time);
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
        subplot(6,length(subs),(i_time-1).*length(subs)+i_sub)
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