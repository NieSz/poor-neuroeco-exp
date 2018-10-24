function waitForSpace(texture)
display_info = evalin('caller', 'display_info');
Screen('DrawTexture', display_info.wPtr, evalin('caller', ['markers.', texture]), [], display_info.window_rect)
Screen('Flip', display_info.wPtr);
while 1
    [~, reactKey] = KbWait([], 3);
    if reactKey(KbName(display_info.exit_key))
        sca
        break
    elseif reactKey(KbName('space'))
        break
    end
end