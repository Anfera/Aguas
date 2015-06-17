%% INITIALIZE SWMM
clear all; 
close all;
inp = 'swmm_files/RedChicoSur_con_Pareto.INP';
swmm = SWMM;
clc;
%% RETRIEVING VARIABLE IDs FROM THE .INP
links = swmm.get_all(inp, swmm.NODE, swmm.NONE);
subcatchments = swmm.get_all(inp, swmm.SUBCATCH, swmm.NONE);

%% RUNNING A SWMM SIMULATION 
swmm.initialize(inp);


  while ~swmm.is_over
        swmm.run_step;
  end

[errors, duration] = swmm.finish;
    
%% RETRIEVING INFORMATION 
fprintf('Total flooding = %.3f m3\n', swmm.total_flooding);
[time, altura1] = swmm.read_results('PMP92954', swmm.NODE, swmm.FLOODING);

%[time, fn5] = swmm.read_results(links(1), swmm.NODE, swmm.FLOODING);
%plot(time, fn5);