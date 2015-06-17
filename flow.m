%% Ejemplo Muskingum
%% INITIALIZE SWMM
clear all; 
close all;
inp = 'swmm_files/prueba.INP';
swmm = SWMM;
clc;

%% RETRIEVING VARIABLE IDs FROM THE .INP
links = swmm.get_all(inp, swmm.LINK, swmm.NONE);
%orificios = swmm.get_all(inp, swmm.ORIFICE, swmm.NONE);

%% RUNNING A SWMM SIMULATION 

swmm.initialize(inp);
i=1;    

while ~swmm.is_over  
      swmm.run_step;
      t(i,:) = swmm.get_time;
      v(i,:) = swmm.get('C-5',swmm.VOLUME,swmm.SI); %Canal a caracterizar
      f1(i,:) = swmm.get('N-14',swmm.INFLOW,swmm.SI); %Flujo de entrada
      f2(i,:) = swmm.get('C-5',swmm.FLOW,swmm.SI); %Flujo de salida
      i = i+1;
end

[errors, duration] = swmm.finish;

%% Least squares con Yalmip

x = sdpvar(1,1);
k = sdpvar(1,1);
n = sdpvar(1,1);

S_bar = k*(x*f1(1:end-1,1) + (1-x)*f2(1:end-1,1));
%S_bar = x*f1(1:end-1,1) + k*f2(1:end-1,1);
objective = norm(v(1:end-1,1) - S_bar,2);
constraints = [0 <= x <= 1];

optimize(constraints,objective);

musk = [value(x),value(k),value(n)]
%k_ = musk(1) + musk(2)
%x_ = (musk(1)/musk(2))/(1 + (musk(1)/musk(2)))

subplot(2,1,1)
plot(t(1:end-1,:),f1(1:end-1,:),'linewidth',2)
hold on
plot(t(1:end-1,:),f2(1:end-1,:),'r','linewidth',2)
legend('I','O')
subplot(2,1,2)
plot(t(1:end-1,:),v(1:end-1,:),'linewidth',2)
hold on
plot(t(1:end-1,:),value(S_bar),'r','linewidth',2)
legend('Real','Muskingum')
