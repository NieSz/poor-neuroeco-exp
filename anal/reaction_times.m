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
        x_rt_raw = round(zscore([u_gamble-u_sr,[subSubTrials.reaction_time]']).*5)./5;
        x_rt = [unique(x_rt_raw(:,1)),splitapply(@mean, x_rt_raw(:,2),findgroups(x_rt_raw(:,1)))];
        x_rt = sortrows(x_rt,1);
        
        subplot(4, length(subs),length(subs).*3 + i_sub)
        plot(x_rt(:,1)', x_rt(:,2)','color',colors{i_time});
        hold on
    end
end
label({'normal','catch'})

%% RT GLM
% subs = [18111001,18111002,18111003,18111004,18111101,18111102,18111104];
subs = [18121401 18121402 18121601 18121602 18121604 18121605];
times = [1 2];
betas = nan(length(subs),length(times), 3);
devs = nan(length(subs),length(times), 1);
for i_sub = 1:length(subs)
    subTrials = getSubData(subs(i_sub));
    for i_time = 1:2
        if i_time == 1
            subSubTrials = subTrials([subTrials.n_gambles] == 7);
        else
            subSubTrials = subTrials([subTrials.n_gambles] ~= 7);
        end
%         subSubTrials = subTrials(ceil([subTrials.trial_id] ./ (192/6)) == i_time);
        dif_raw = abs(mean(reshape([subSubTrials.key_gamble],2,length(subSubTrials)),1)-[subSubTrials.sure_reward])';
        [tempBetas, tempDevs] = glmfit(zscore([dif_raw, [subSubTrials.trial_id]']), [subSubTrials.reaction_time]');
        betas(i_sub,i_time,:) = tempBetas./sum(abs(tempBetas));
        devs(i_sub,i_time,:) = tempDevs;
    end
end
%% plot
subplot(2,1,1)
bar(reshape(betas(:,1,2:3),length(subs),2)');
xticklabels({'difference','trial No.'});
legend({'s1','s2','...'})
ylabel('normal trial');
subplot(2,1,2)
bar(reshape(betas(:,2,2:3),length(subs),2)');
xticklabels({'difference','trial No.'});
ylabel('catch trial');
%%
h = bar(permute([mean(betas(:,1,1:3)),mean(betas(:,2,1:3))],[3,2,1]));
hold on
errorbar((1:3)-0.15,permute(mean(betas(:,1,1:3),1),[3 2 1]),permute(std(betas(:,1,1:3),[],1)./sqrt(length(subs)),[3 2 1]),'.k','LineWidth',1.5);
errorbar((1:3)+0.15,permute(mean(betas(:,2,1:3),1),[3 2 1]),permute(std(betas(:,2,1:3),[],1)./sqrt(length(subs)),[3 2 1]),'.k','LineWidth',1.5);
% errorbar(0.75:0.5:5.25,[mean(betas(1:7,:));mean(betas(8:14,:))]',[std(betas(1:7,:),[],1);std(betas(8:14,:),[],1)]'./sqrt(7),'.k','LineWidth',1.5);
xticklabels({'constant','value difference','trial No.'});
legend(h,{'normal','catch'})
% ylabel('normal trial');

%% rt ~ is_catch + dif + trial_no.
subs = [18111001,18111002,18111003,18111004,18111101,18111102,18111104];
% subs = [18121401 18121402 18121601 18121602 18121604 18121605];
betas = nan(length(subs), 4);
devs = nan(length(subs), 1);
for i_sub = 1:length(subs)
    subTrials = getSubData(subs(i_sub));
    is_catch = [subTrials.n_gambles]' ~= 7;
    %         subSubTrials = subTrials(ceil([subTrials.trial_id] ./ (192/6)) == i_time);
    dif_raw = abs(mean(reshape([subTrials.key_gamble],2,length(subTrials)),1)-[subTrials.sure_reward])';
    [tempBetas, tempDevs] = glmfit(zscore([is_catch, dif_raw, [subTrials.trial_id]']), [subTrials.reaction_time]');
    betas(i_sub,:) = tempBetas./sum(abs(tempBetas));
    devs(i_sub,:) = tempDevs;
end
%% plot
bar(betas(1:length(subs),2:end)');
xticklabels({'is catch','difference','trial No.'});
legend({'s1','s2','...'})
%% averaged
h = bar(mean(betas(:,2:4)));
hold on
errorbar((1:3),mean(betas(:,2:4),1),std(betas(:,2:4),[],1)./sqrt(length(subs)),'.k','LineWidth',1.5);
% errorbar(0.75:0.5:5.25,[mean(betas(1:7,:));mean(betas(8:14,:))]',[std(betas(1:7,:),[],1);std(betas(8:14,:),[],1)]'./sqrt(7),'.k','LineWidth',1.5);
xticklabels({'is catch','value difference','trial No.'});
% legend(h,{'normal','catch'})