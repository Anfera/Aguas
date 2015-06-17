%% inflow

%% Ejemplo red 3 tanques
%% INITIALIZE SWMM
clear all; 
close all;
inp = 'swmm_files/3tanks.INP';
swmm = SWMM;
clc;

%% RETRIEVING VARIABLE IDs FROM THE .INP
links = swmm.get_all(inp, swmm.NODE, swmm.NONE);
orificios = swmm.get_all(inp, swmm.ORIFICE, swmm.NONE);

%% RUNNING A SWMM SIMULATION 

swmm.initialize(inp);
i=1;    

while ~swmm.is_over  
      t(i,:) = swmm.get_time;
      v(i,:) = swmm.get('C-6',swmm.VOLUME,swmm.SI); %Canal a caracterizar
      f1(i,:) = swmm.get('N-13',swmm.INFLOW,swmm.SI); %Flujo de entrada
      f2(i,:) = swmm.get('C-6',swmm.FLOW,swmm.SI); %Flujo de salida
      swmm.run_step;
      i = i+1;
end

[errors, duration] = swmm.finish;
    
% %% RETRIEVING INFORMATION
% [time, altura1] = swmm.read_results('V-1', swmm.NODE, swmm.INFLOW);
% [time, altura2] = swmm.read_results('V-2', swmm.NODE, swmm.INFLOW);
% [time, altura3] = swmm.read_results('V-3', swmm.NODE, swmm.INFLOW);
[time, altura1] = swmm.read_results('N-9', swmm.NODE, swmm.INFLOW);

disp('Cosimulación completada')
%% Least squares con Yalmip

x = sdpvar(1,1);
k = sdpvar(1,1); 

%S_bar = k*(x*f1 + (1-x)*f2);
S_bar = x*f1 + k*f2;
objective = norm(v - S_bar,2);
%constraints = [0 <= x <= 1];
constraints = [];

optimize(constraints,objective);
[value(x),value(k)]
a = value(x);
b = value(k);

subplot(2,1,1)
plot(t,f1,'linewidth',2)
hold on
plot(t,f2,'r','linewidth',2)
legend('q_{in}','q_{out}')
subplot(2,1,2)
plot(t,v,'linewidth',2)
hold on
plot(t,value(S_bar),'r','linewidth',2)
legend('Real','Muskingum')
