fhan = @(x)(2.*cdf('norm',-17.5,0,x)-cdf('norm',-16.5,0,x)).^2;
x=fmincon(fhan,5,[],[],[],[],5,6);
xR= 3:0.1:6;
plot(xR,cdf('norm',-17.5,0,xR));
hold on
plot(xR,cdf('norm',-16.5,0,xR)-cdf('norm',-17.5,0,xR));
%%
%xRange = 0:0.1:10;
xRange = 1:10;
for lambda = 1:6
plot(xRange,pdf('poisson',xRange,lambda));
hold on
end