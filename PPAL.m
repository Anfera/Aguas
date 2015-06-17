%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Programa caso chico     %%%
%%%     PD decentralizado      %%%
%%%             UPC            %%%
%%%    13 / Octubre / 2014     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% study

%close all
clear all
clc

global v
global u
global K
global A
global d
global v_max

global simplex1
global simplex2
global simplex3
global simplex4
global simplex5
global simplex6
global epsilon

epsilon = 0.001;
dd=0.09;
control = false;
n_it = 2.5*1400; % number of iterations

v_max = 1.145*[100 120 100 110 1.5*160 1.5*160 1.5*160 1.5*160 1.5*160 160 160 1.5*160 1.5*160 1.5*470 1.5*160 1.5*160]'; % maximum volumes

% Extracting K
K = [0.002332 0.003870 0.003170 0.008239 0.002217 0.008975 0.005185 0.004764 0.006147 0.005446 ...
     0.020703 0.001693 0.007026 0.000632 0.006319 0.005782]';
%K=0.03*ones(16,1); % constants for outflows

A=[-1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0;
    0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0  0;
    0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0  0;
    0  0  0 -1  0  0  0  0  0  0  0  0  0  0  0  0;
    1  1  0  0 -1  0  0  0  0  0  0  0  0  0  0  0;
    0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0  0;
    0  0  0  0  0  0 -1  0  0  0  0  0  0  0  0  0;
    0  0  1  1  0  0  0 -1  0  0  0  0  0  0  0  0;
    0  0  0  0  1  1  1  1 -1  0  0  0  0  0  0  0;
    0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0  0;
    0  0  0  0  0  0  0  0  0  0 -1  0  0  0  0  0;
    0  0  0  0  0  0  0  0  0  1  1 -1  0  0  0  0;
    0  0  0  0  0  0  0  0  0  0  0  0 -1  0  0  0;
    0  0  0  0  0  0  0  0  1  0  0  1  1 -1  0  0;
    0  0  0  0  0  0  0  0  0  0  0  0  0  0 -1  0;
    0  0  0  0  0  0  0  0  0  0  0  0  0  1  1 -1]; % matrix for simulation

n1=2; % control action control 1
n2=2; % control action control 2
n3=4; % control action control 3
n4=2; % control action control 4
n5=3; % control action control 5
n6=2; % control action control 6

v0=[10 60 20 30 9 9 9 9 9 20 30 9 9 9 9 9]'; % initial conditions for all volumes
u10=(1/n1*ones(n1,1)); % initial conditions for control 1
u20=(1/n2*ones(n2,1)); % initial conditions for control 2
u30=(1/n3*ones(n3,1)); % initial conditions for control 3
u40=(1/n4*ones(n4,1)); % initial conditions for control 4
u50=(1/n5*ones(n5,1)); % initial conditions for control 5
u60=(1/n6*ones(n6,1)); % initial conditions for control 6

tspan=[0,dd]; % sampling time for simulation 30s

v=v0; % load of volumes for fitness functions
u1=u10; % load of control actions for control 1
u2=u20; % load of control actions for control 2
u3=u30; % load of control actions for control 3
u4=u40; % load of control actions for control 4
u5=u50; % load of control actions for control 5
u6=u60; % load of control actions for control 6


for it=1:n_it

    it
    
%     u10=(1/n1*ones(n1,1)); % initial conditions for control 1
%     u20=(1/n2*ones(n2,1)); % initial conditions for control 2
%     u30=(1/n3*ones(n3,1)); % initial conditions for control 3
%     u40=(1/n4*ones(n4,1)); % initial conditions for control 4
%     u50=(1/n5*ones(n5,1)); % initial conditions for control 5
%     u60=(1/n6*ones(n6,1)); % initial conditions for control 6
    
    
    % d1=56*exp(-(it-100)^2/(2*20^2));
    % d2=45*exp(-(it-160)^2/(2*41^2));
    % d3=50*exp(-(it-105)^2/(2*32^2));
    % d4=40*exp(-(it-102)^2/(2*30.5^2));
    % d5=65*exp(-(it-202)^2/(2*30.5^2));
    % d6=52*exp(-(it-90)^2/(2*51.1^2));
    % d7=59*exp(-(it-110)^2/(2*52.1^2));
    % d8=0;
    % d9=1.05*exp(-(it-108)^2/(2*30^2));
    % d10=34*exp(-(it-100)^2/(2*20^2));
    % d11=45.1*exp(-(it-110)^2/(2*20^2));
    % d12=60.1*exp(-(it-215)^2/(2*30^2));
    % d13=47.1*exp(-(it-115)^2/(2*20^2));
    % d14=47.1*exp(-(it-215)^2/(2*20^2));
    % d15=81.1*exp(-(it-120)^2/(2*20^2));
    % d16=95*exp(-(it-118)^2/(2*30^2));
    
    d1=0.56*exp(-(it-2*200).^2./(2*(2.5*20)^2));
    d2=0.45*exp(-(it-2*240).^2./(2*(2.5*36)^2));
    d3=0.50*exp(-(it-2*255).^2./(2*(2.5*32)^2));
    d4=0.40*exp(-(it-2*202).^2./(2*(2.5*30.5)^2));
    d5=0.65*exp(-(it-2*202).^2./(2*(2.5*30.5)^2));
    d6=0.52*exp(-(it-2*190).^2./(2*(2.5*21.1)^2));
    d7=0.59*exp(-(it-2*210).^2./(2*(2.5*22.1)^2));
    d8=0;
    d9=1.05*exp(-(it-2*208).^2./(2*(2.5*30)^2));
    d10=0.34*exp(-(it-2*200).^2./(2*(2.5*20)^2));
    d11=0.451*exp(-(it-2*210).^2./(2*(2.5*20)^2));
    d12=0.601*exp(-(it-2*215).^2./(2*(2.5*30)^2));
    d13=0.471*exp(-(it-2*215).^2./(2*(2.5*20)^2));
    d14=0;
    d15=0.811*exp(-(it-2*220).^2./(2*(2.5*20)^2));
    d16=0.95*exp(-(it-2*218).^2./(2*(3*30)^2));
    
    h1_(it)=d1;
    h2_(it)=d2;
    h3_(it)=d3;
    h4_(it)=d4;
    h5_(it)=d5;
    h6_(it)=d6;
    h7_(it)=d7;
    h8_(it)=d8;
    h9_(it)=d9;
    h10_(it)=d10;
    h11_(it)=d11;
    h12_(it)=d12;
    h13_(it)=d13;
    h14_(it)=d14;
    h15_(it)=d15;
    h16_(it)=d16;
   
    d=0.3*[d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16]';
    
    hist_v_(:,it)=v0./v_max; % saving history of volumes
    hist_u1_(:,it)=u10; % saving history of control actions 1
    hist_u2_(:,it)=u20; % saving history of control actions 2
    hist_u3_(:,it)=u30; % saving history of control actions 3
    hist_u4_(:,it)=u40; % saving history of control actions 4
    hist_u5_(:,it)=u50; % saving history of control actions 5
    hist_u6_(:,it)=u60; % saving history of control actions 6

    
    
    if control==true
        [tu1,u1]=ode45('replicator_dyna1',tspan,u10);
        u10=u1(size(u1,1),:)';
        u10=[u10(1) 1-u10(1)]';
        uf10=u10/max(u10);

        [tu2,u2]=ode45('replicator_dyna2',tspan,u20);
        u20=u2(size(u2,1),:)';
        u20=[u20(1) 1-u20(1)]';
        uf20=u20/max(u20);
        
        [tu3,u3]=ode45('replicator_dyna3',tspan,u30);
        u30=u3(size(u3,1),:)';
        u30=[u30(1) u30(2) u30(3) 1-u30(1)-u30(2)-u30(3)]';
        uf30=u30/max(u30);
        
        [tu4,u4]=ode45('replicator_dyna4',tspan,u40);
        u40=u4(size(u4,1),:)';
        u40=[u40(1) 1-u40(1)]';
        uf40=u40/max(u40);

        [tu5,u5]=ode45('replicator_dyna5',tspan,u50);
        u50=u5(size(u5,1),:)';
        u50=[u50(1) u50(2) 1-u50(1)-u50(2)]';
        uf50=u50/max(u50);
        
        [tu6,u6]=ode45('replicator_dyna6',tspan,u60);
        u60=u6(size(u6,1),:)';
        u60=[u60(1) 1-u60(1)]';
        uf60=u60/max(u60);
        
        u=[u10(1)*simplex1 u10(2)*simplex1 u20(1)*simplex2 u20(2)*simplex2 u30(1)*simplex3 u30(2)*simplex3 u30(3)*simplex3 u30(4)*simplex3 u50(1)*simplex5 ...
           u40(1)*simplex4 u40(2)*simplex4 u50(2)*simplex5 u50(3)*simplex5 u60(1)*simplex6 u60(2)*simplex6 1]';
        
    else    
        u=[ones(16,1)];
    end
    
    u=min(ones(16,1),u);
    u=max(zeros(16,1),u);
    
    tspan=[0,dd];
    [tv,vs]=ode45('tanks_dyna',tspan,v0);
    v0=vs(size(vs,1),:)';
    
    v=v0;
    u_=u;
    warning('off')

end


time = 1:n_it;
time = time.*tspan(2)./60;

figure
subplot(3,2,1)
plot(time, hist_v_(1:2,:)')
legend('1','2')
%figure
subplot(3,2,2)
plot(time, hist_v_(3:4,:)')
legend('3','4')
%figure
subplot(3,2,3)
plot(time, hist_v_(5:8,:)')
legend('5','6','7','8')
%figure
subplot(3,2,4)
plot(time, hist_v_(9,:)','r')
hold on 
plot(time, hist_v_(12:13,:)')
legend('9','12','13')
%figure
subplot(3,2,5)
plot(time, hist_v_(10:11,:)')
legend('10','11')
%figure
subplot(3,2,6)
%plot(time, hist_v(14:15,:)')
%legend('14','15')
%figure
%subplot(4,2,7)
%plot(time, hist_v(16,:)')
plot(time, hist_v_(14:16,:)')
legend('14','15','16')
figure
plot(time, (1/60)*[h1_;h2_;h3_;h4_;h5_;h6_;h7_;h8_;h9_;h10_;h11_;h12_;h13_;h14_;h15_;h16_]')
legend('d1','d2','d3','d4','d5','d6','d7','d8','d9','d10','d11','d12','d13','d14','d15','d16')
title('Direct Run-off Hydrograph - Disturbances');
ylabel('Q (m3/s)');
xlabel('Time (hr)');

% OVERFLOW CALCULATION

total_overflow = 0;
figure; hold on;
for i=1 : size(hist_v_, 1)
    overflow(i,:) = max(0, (1/60)*(hist_v_(i,:) - 1) * v_max(i) * K(i)); % Overflow i [m3/s]
    plot(time, overflow(i,:));
    title('Overflow');
    ylabel('Q (m^3/s)');
    xlabel('Time (hr)');
    total_overflow = total_overflow + trapz(time*3600, overflow(i,:));
    fprintf('Peak Overflow x%d = %.2f\n', i, max(overflow(i,:)));
end

fprintf('Total overflow (L) = %f\n', total_overflow*1000);
%time = 0::size(overflow, 2);
%total_overflow=sum(sum(overflow));
%display('The overflow is = ')
%total_overflow
