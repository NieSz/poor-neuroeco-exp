classdef trial < matlab.mixin.Copyable
    properties
        sub_id
        sub_sex
        sub_age
        
        block_id % (0 = test block, -1 = practice block)
        trial_id
        
        n_gambles
        gambles % matrix [gain loss; gain loss; ... gain loss]
        sure_rewards
        
        gamble_duration
        gain_on_left
        
        choose_sure
        reaction_time
        
    end
    methods
        function obj = trial(trialInfo)
            if nargin == 1
                if isa(trialInfo,'table')
                    obj = read(trialInfo);
                end
            end
        end
        
        function add_gambles(obj, gambleMatrix)
            obj.n_gambles = size(gambleMatrix, 1);
            obj.gambles = gambleMatrix;
        end
        
        function react(obj, choose_sure, reaction_time)
            obj.choose_sure = choose_sure;
            obj.reaction_time = reaction_time;
        end
        
        function write(obj, fid)
            gamblesStr = '';
            for iGamble = 1:obj.n_gambles
                gamblesStr = strcat(gamblesStr, sprintf('%d %d;', obj.gambles(iGamble, 1), obj.gambles(iGamble, 2)));
            end
            gamblesStr = ['[',gamblesStr,']'];
            sureRewardStr = '';
            for iGamble = 1:obj.n_gambles
                sureRewardStr = strcat(gamblesStr, sprintf('%d, ', obj.sure_rewards(iGamble)));
            end
            sureRewardStr = ['[',sureRewardStr,']'];
            fprintf(fid,'\n%d,%s,%d,%d,%d,%d,%.1f,%s,%d,%d,%.3f', obj.sub_id, obj.sub_sex, obj.sub_age, ...
                obj.block_id, obj.trial_id, obj.gain_on_left, obj.gamble_duration, gamblesStr,sureRewardStr, obj.choose_sure, obj.reaction_time);
        end
        
        function obj = read(obj, trialInfo)
            
            obj.sub_id = trialInfo.sub_id;
            obj.sub_sex = trialInfo.sub_sex;
            obj.sub_age = trialInfo.sub_age;
            
            obj.block_id = trialInfo.block_id;
            obj.trial_id = trialInfo.trial_id;
            
            obj.gamble_duration = trialInfo.gamble_duration;
            obj.gain_on_left = trialInfo.gain_on_left;
            
            if any(strcmp(trialInfo.Properties.VariableNames(:),'gambles'))
                obj.gambles = eval(trialInfo.gambles{:});
                obj.n_gambles = size(obj.gambles, 1);
                obj.sure_reward = trialInfo.sure_reward;
            end
            
            if any(strcmp(trialInfo.Properties.VariableNames(:),'choose_sure'))
                obj.choose_sure = trialInfo.choose_sure;
                obj.reaction_time = trialInfo.reaction_time;
            end
            
        end
        
        function show(obj, display_info)
            sureRewardList = obj.sure_rewards;
            % prepare
            %             Screen('FillOval', display_info.wPtr, display_info.prepare_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
            %             Screen('Flip', display_info.wPtr);
            
            % fixation
            Screen('FillOval', display_info.wPtr, display_info.fixation_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
            %             while 1
            %                 [~, reactKey] = KbWait([], 3);
            %                 if reactKey(KbName(display_info.exit_key))
            %                     sca
            %                     break
            %                 elseif reactKey(KbName('space'))
            %                     break
            %                 end
            %             end
            timeStamp = Screen('Flip', display_info.wPtr); % time marker of the trial
            
            % sure reward
            %             reactTooEarly = 0;
            %             Screen('FrameRect', display_info.wPtr, display_info.rect_color, display_info.sure_reward_locus([1 2 1 2]).*display_info.window_rect([3 4 3 4]) + display_info.sure_reward_rect, display_info.rect_pen_width);
            %             if obj.sure_reward > 0
            %                 sureRewardStr = sprintf('+%d', obj.sure_reward);
            %             else
            %                 sureRewardStr = num2str(obj.sure_reward);
            %             end
            %             DrawFormattedText(display_info.wPtr, sureRewardStr, 'center', 'center', display_info.fig_color, [], [], [], [], [], display_info.window_rect([3 4 3 4]).*display_info.sure_reward_locus([1 2 1 2]) + display_info.sure_reward_rect);
            % %             Screen('FillOval', display_info.wPtr, display_info.fixation_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
            %             Screen('Flip', display_info.wPtr, timeStamp + display_info.fixation_duration, [], 1);
            %             while GetSecs - timeStamp < display_info.fixation_duration
            %                 [~, ~, reactKey] = KbCheck;
            %                 if any(reactKey)
            %                     if reactKey(KbName(display_info.sure_reward_key))
            %                         obj.choose_sure = 1;
            %                     elseif reactKey(KbName(display_info.gamble_key))
            %                         obj.choose_sure = 0;
            %                     else
            %                         obj.choose_sure = -1;
            %                     end
            %                     obj.reaction_time = 0;
            %                     Screen('FillOval', display_info.wPtr, display_info.fail_to_choose_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
            %                     timeStamp = Screen('Flip', display_info.wPtr);
            %                     Screen('Flip', display_info.wPtr, timeStamp + display_info.fixation_duration);
            %                     reactTooEarly = 1;
            %                     break
            %                 end
            %             end
            
            % gambles
            reactTooEarly = 0;
            for i_gamble = 1:obj.n_gambles
                if reactTooEarly == 1
                    break
                end
                %                 Screen('FrameRect', display_info.wPtr, display_info.rect_color, display_info.sure_reward_locus([1 2 1 2]).*display_info.window_rect([3 4 3 4]) + display_info.sure_reward_rect, display_info.rect_pen_width);
                %                 DrawFormattedText(display_info.wPtr, sureRewardStr, 'center', 'center', display_info.fig_color, [], [], [], [], [], display_info.window_rect([3 4 3 4]).*display_info.sure_reward_locus([1 2 1 2]) + display_info.sure_reward_rect);
                if obj.gain_on_left == 1
                    payoff1Str = sprintf('+%d', obj.gambles(i_gamble, 1));
                    payoff2Str = num2str(obj.gambles(i_gamble, 2));
                else
                    payoff1Str = num2str(obj.gambles(i_gamble, 2));
                    payoff2Str = sprintf('+%d', obj.gambles(i_gamble, 1));
                end
                
                Screen('FrameRect', display_info.wPtr, display_info.rect_color, display_info.sure_reward_locus([1 2 1 2]).*display_info.window_rect([3 4 3 4]) + display_info.sure_reward_rect, display_info.rect_pen_width);
                
                if sureRewardList(i_gamble) > 0
                    sureRewardStr = sprintf('+%d', sureRewardList(i_gamble));
                else
                    sureRewardStr = num2str(sureRewardList(i_gamble));
                end
                DrawFormattedText(display_info.wPtr, sureRewardStr, 'center', 'center', display_info.fig_color, [], [], [], [], [], display_info.window_rect([3 4 3 4]).*display_info.sure_reward_locus([1 2 1 2]) + display_info.sure_reward_rect);
                Screen('FillOval', display_info.wPtr, display_info.fixation_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
                Screen('FrameRect', display_info.wPtr, display_info.rect_color, display_info.gamble_locus([1 2 1 2]).*display_info.window_rect([3 4 3 4]) + display_info.gamble_rect([1 2 7 8]), display_info.rect_pen_width);
                DrawFormattedText(display_info.wPtr, payoff1Str, 'center', 'center', display_info.fig_color, [], [], [], [], [], display_info.window_rect([3 4 3 4]).*display_info.gamble_locus([1 2 1 2]) + display_info.gamble_rect(1:4));
                DrawFormattedText(display_info.wPtr, payoff2Str, 'center', 'center', display_info.fig_color, [], [], [], [], [], display_info.window_rect([3 4 3 4]).*display_info.gamble_locus([1 2 1 2]) + display_info.gamble_rect(5:8));
                Screen('FillOval', display_info.wPtr, display_info.fixation_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
                Screen('Flip', display_info.wPtr, timeStamp + display_info.fixation_duration + display_info.sure_reward_duration + (i_gamble - 1).*obj.gamble_duration, [], 1);
                
                while GetSecs - timeStamp < display_info.fixation_duration + i_gamble*obj.gamble_duration
                    [~, ~, reactKey] = KbCheck;
                    if any(reactKey)
                        if reactKey(KbName(display_info.sure_reward_key))
                            obj.choose_sure = 1;
                        elseif reactKey(KbName(display_info.gamble_key))
                            obj.choose_sure = 0;
                        else
                            obj.choose_sure = -1;
                        end
                        obj.reaction_time = -i_gamble;
                        Screen('FillOval', display_info.wPtr, display_info.fail_to_choose_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
                        timeStamp = Screen('Flip', display_info.wPtr);
                        Screen('Flip', display_info.wPtr, timeStamp + display_info.fixation_duration);
                        reactTooEarly = 1;
                        break
                    end
                end
            end
            % wait for react
            if ~reactTooEarly == 1
                Screen('FillOval', display_info.wPtr, display_info.ready_to_choose_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
                Screen('Flip', display_info.wPtr, timeStamp + display_info.fixation_duration + obj.n_gambles.*obj.gamble_duration, [], 1);
                while 1
                    [~, timeGetKey, reactKey] = KbCheck;
                    if  timeGetKey - timeStamp > display_info.time_limit + display_info.fixation_duration + obj.n_gambles*obj.gamble_duration
                        obj.choose_sure = nan;
                        obj.reaction_time = nan;
                        Screen('FillOval', display_info.wPtr, display_info.fail_to_choose_color, display_info.window_rect([3 4 3 4])./2 + display_info.fixation_radius.*[-1 -1 1 1]);
                        timeStamp = Screen('Flip', display_info.wPtr);
                        Screen('Flip', display_info.wPtr, timeStamp + display_info.fixation_duration);
                        break
                    end
                    if any(reactKey(KbName({display_info.exit_key, display_info.sure_reward_key, display_info.gamble_key})))
                        if reactKey(KbName(display_info.sure_reward_key))
                            obj.choose_sure = 1;
                        elseif reactKey(KbName(display_info.gamble_key))
                            obj.choose_sure = 0;
                        elseif reactKey(KbName(display_info.exit_key))
                            sca
                        end
                        obj.reaction_time = timeGetKey - timeStamp - display_info.fixation_duration - obj.n_gambles.*obj.gamble_duration;
                        break
                    end
                end
            end
            Screen('Flip', display_info.wPtr);
            WaitSecs(display_info.intertrial_duration);
        end
    end
end

