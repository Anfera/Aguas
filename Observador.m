A =[1.8097 -0.8187; 1 0];
B = [0.5; 0];
C =[0.1810 -0.1810];
D = 0;
L=place(A',C',[.5 .7])';

x=[-1;1]; % initial state
xhat=[0;0]; % initial estimate
XX=x;
XXhat=xhat;
T=40;
UU=.1*ones(1,T); % input signal
for k=0:T-1,
    u=UU(k+1);
    y=C*x+D*u;
    yhat=C*xhat+D*u;
    x=A*x+B*u;
    xhat=A*xhat+B*u+L*(y-yhat);
    XX=[XX,x];
    XXhat=[XXhat,xhat];
end
plot(0:T,[XX(1,:);XXhat(1,:)]);

