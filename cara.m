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
i = 1;
j = 1;

while ~swmm.is_over  
      swmm.run_step;
      if mod(swmm.get_time,0.25) < 0.0084          
        if mod(swmm.get_time,32) < 0.0084   
            swmm.modify_setting('R-4',mod(i,2));
            swmm.modify_setting('R-5',mod(i+1,2));
            swmm.modify_setting('R-6',mod(i+2,2));
            i = i+1;
        end  
        u(j,:) = [mod(i,2),mod(i+1,2),mod(i+2,2)];
        t(j,:) = swmm.get_time;
        j = j+1;
      end
end


[errors, duration] = swmm.finish;
    
%% RETRIEVING INFORMATION 181
[time, altura1] = swmm.read_results('V-1', swmm.NODE, swmm.DEPTH);
[time, altura2] = swmm.read_results('V-2', swmm.NODE, swmm.DEPTH);
[time, altura3] = swmm.read_results('V-3', swmm.NODE, swmm.DEPTH);

tanques = iddata([altura1,altura2,altura3],u,0.25);

modelo_ = ssest(tanques,10,'DisturbanceModel','none','Form','canonical');

modelo = c2d(ss(modelo_),0.25);
% 
compare(tanques,modelo_)