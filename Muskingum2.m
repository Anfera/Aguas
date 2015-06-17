%% Muskingum "avanzado"
clear all; 
close all;

%% INITIALIZE SWMM
inp = 'swmm_files/prueba.INP';
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
      v(i,:) = [swmm.get('C-1',swmm.VOLUME,swmm.SI),...
                swmm.get('C-2',swmm.VOLUME,swmm.SI),...
                swmm.get('C-11',swmm.VOLUME,swmm.SI)]; %Canal a caracterizar
      f(i,:) = [swmm.get('C-1',swmm.FLOW,swmm.SI),...
                swmm.get('C-2',swmm.FLOW,swmm.SI),...
                swmm.get('C-11',swmm.FLOW,swmm.SI)]; %Flujo de salida
      u(i,:) =  swmm.get('N-6',swmm.INFLOW,swmm.SI);
      swmm.run_step;
      i = i+1;
end

[errors, duration] = swmm.finish;

disp('Cosimulación completada')
%% Least squares con Yalmip
k = sdpvar(1,size(v,2));

f_bar = v.*repmat(k,size(v,1));

objective = 0;
for i = 1:size(f,2)
    objective = objective + norm(f(:,i) - f_bar(:,i),2);
end

constraints = [];
 
disp('empieza optimizacion')
optimize(constraints,objective);
K = [value(k)]

% plot(t,f(:,1),'linewidth',2)
% hold on
% plot(t,value(f_bar(:,1)),'r','linewidth',2)
% legend('Real','Muskingum')
break
input = 0.5;
tf =  6*3600;
f = @(t,x) 0.5 - x*K(2); 

tspan=[0 tf]; 
x0=0;
[t2,x]=ode45(f,tspan,x0); 
plot(t2/3600,x,'r')
xlabel('t')
ylabel('m^3');
title('Volumen del canal')
hold on
plot(t,v(:,2))
