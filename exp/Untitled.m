% fhan = @(x)(2.*cdf('norm',-17.5,0,x)-cdf('norm',-16.5,0,x)).^2;
% x=fmincon(fhan,5,[],[],[],[],5,6);
% xR= 3:0.1:6;
% plot(xR,cdf('norm',-17.5,0,xR));
% hold on
% plot(xR,cdf('norm',-16.5,0,xR)-cdf('norm',-17.5,0,xR));
% %%
% %xRange = 0:0.1:10;
% xRange = 1:10;
% for lambda = 1:6
% plot(xRange,pdf('poisson',xRange,lambda));
% hold on
% end
% %
wPtr = Screen('OpenWindow',2);
timeStamp = 0;
for i=1:10
    timeStamp2 = Screen('Flip',wPtr);
    disp(timeStamp2-timeStamp);
    timeStamp = timeStamp2;
end
disp('\n');
for i=1:10
    timeStamp2 = Screen('Flip',wPtr,timeStamp + 0.002*i);
    disp(timeStamp2-timeStamp);
    timeStamp = timeStamp2;
end
sca;