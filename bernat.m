%% Flow bernat joseph duran
%% INITIALIZE SWMM
clear all; 
close all;
inp = 'swmm_files/01_Lluvia Actual.INP';
swmm = SWMM;
clc;

% %% RETRIEVING VARIABLE IDs FROM THE .INP
% links = swmm.get_all(inp, swmm.NODE, swmm.NONE);
% orificios = swmm.get_all(inp, swmm.ORIFICE, swmm.NONE);

%% RUNNING A SWMM SIMULATION 

swmm.initialize(inp);    

while ~swmm.is_over  
      swmm.run_step;
end

[errors, duration] = swmm.finish;
    
%% RETRIEVING INFORMATION
[time, flow1] = swmm.read_results('PMP93095', swmm.NODE, swmm.INFLOW);
[time, flow2] = swmm.read_results('PMP93029', swmm.NODE, swmm.INFLOW);
[time, depth] = swmm.read_results('PLT85941', swmm.LINK, swmm.DEPTH);

disp('Cosimulación completada')
    
[xData, yData] = prepareCurveData( time, flow1 );
ft = 'pchipinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );

f = @(x) norm(x(1)*feval(fitresult,time-x(2)) + ...
         (1-x(1))*feval(fitresult,time-x(2)-(1/60)) ...
            - flow2,2);
consA = [-1 0;1 0];
consB = [0;1];
sol = fmincon(f,[0,0],consA,consB);
a = sol(1);
tau = sol(2);

% f = @(x) norm(feval(fitresult,time-x) - flow2,2);
% sol = fminunc(f,[1]);
% tau = sol;

subplot(2,1,1)
plot(flow2)
hold on
plot(sol(1)*feval(fitresult,time-sol(2)) + (1-sol(1))*feval(fitresult,time-sol(2)-1/60),'r')
title('flow bernat')
%%

delay = ceil(tau*60);
A = [zeros(1,delay);eye(delay-1) zeros(delay-1,1)];
B = [1/60;zeros(delay-1,1)];
V = zeros(delay,length(time)-1);

for i = 1:length(time)-1
    V(:,i+1) = A*V(:,i) + B*flow1(i);
end

flow2_bar = 60*V(end,:);
subplot(2,1,2)
plot(flow2)
hold on
plot(flow2_bar,'r')
title('tanks bernat')