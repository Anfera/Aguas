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
        if mod(swmm.get_time,64) < 0.0084   
            valvula = de2bi(mod(i,8),3)
            swmm.modify_setting('R-4',valvula(1));
            swmm.modify_setting('R-5',valvula(2));
            swmm.modify_setting('R-6',valvula(3));
            i = i+1;
        end  
        u(j,:) = [valvula(1),valvula(2),valvula(3)];
        v(j,:) = [swmm.get('V-1',swmm.VOLUME,swmm.SI), ...
                  swmm.get('V-2',swmm.VOLUME,swmm.SI), ...
                  swmm.get('V-3',swmm.VOLUME,swmm.SI)];
        t(j,:) = swmm.get_time;
        j = j+1;
      end
end


[errors, duration] = swmm.finish;
disp('primera')    
%% RETRIEVING INFORMATION 181
[time, altura1] = swmm.read_results('V-1', swmm.NODE, swmm.DEPTH);
[time, altura2] = swmm.read_results('V-2', swmm.NODE, swmm.DEPTH);
[time, altura3] = swmm.read_results('V-3', swmm.NODE, swmm.DEPTH);

swmm.initialize(inp);
i = 1;
j = 1;

while ~swmm.is_over  
      swmm.run_step;
      if mod(swmm.get_time,0.25) < 0.0084          
        if mod(swmm.get_time,64) < 0.0084   
            valvula = de2bi(mod(i,8),3)
            swmm.modify_setting('R-4',valvula(2));
            swmm.modify_setting('R-5',valvula(1));
            swmm.modify_setting('R-6',valvula(3));
            i = i+1;
        end  
        u2(j,:) = [valvula(2),valvula(1),valvula(3)];
        v2(j,:) = [swmm.get('V-1',swmm.VOLUME,swmm.SI), ...
                  swmm.get('V-2',swmm.VOLUME,swmm.SI), ...
                  swmm.get('V-3',swmm.VOLUME,swmm.SI)];
        t(j,:) = swmm.get_time;
        j = j+1;
      end
end


[errors, duration] = swmm.finish;
disp('segunda')    

%% RETRIEVING INFORMATION 181
[time, altura4] = swmm.read_results('V-1', swmm.NODE, swmm.DEPTH);
[time, altura5] = swmm.read_results('V-2', swmm.NODE, swmm.DEPTH);
[time, altura6] = swmm.read_results('V-3', swmm.NODE, swmm.DEPTH);

%%
swmm.initialize(inp);
i = 1;
j = 1;

while ~swmm.is_over  
      swmm.run_step;
      if mod(swmm.get_time,0.25) < 0.0084          
        if mod(swmm.get_time,64) < 0.0084   
            valvula = de2bi(mod(i,8),3)
            swmm.modify_setting('R-4',valvula(3));
            swmm.modify_setting('R-5',valvula(2));
            swmm.modify_setting('R-6',valvula(1));
            i = i+1;
        end  
        u3(j,:) = [valvula(3),valvula(2),valvula(1)];
        v3(j,:) = [swmm.get('V-1',swmm.VOLUME,swmm.SI), ...
                  swmm.get('V-2',swmm.VOLUME,swmm.SI), ...
                  swmm.get('V-3',swmm.VOLUME,swmm.SI)];
        t(j,:) = swmm.get_time;
        j = j+1;
      end
end


[errors, duration] = swmm.finish;
disp('tercera')    

%% RETRIEVING INFORMATION 181
[time, altura7] = swmm.read_results('V-1', swmm.NODE, swmm.DEPTH);
[time, altura8] = swmm.read_results('V-2', swmm.NODE, swmm.DEPTH);
[time, altura9] = swmm.read_results('V-3', swmm.NODE, swmm.DEPTH);

%%
swmm.initialize(inp);
i = 1;
j = 1;

while ~swmm.is_over  
      swmm.run_step;
      if mod(swmm.get_time,0.25) < 0.0084          
        if mod(swmm.get_time,64) < 0.0084   
            valvula = de2bi(mod(i,8),3)
            swmm.modify_setting('R-4',1);
            swmm.modify_setting('R-5',1);
            swmm.modify_setting('R-6',1);
            i = i+1;
        end  
        u4(j,:) = [1,1,1];
        v4(j,:) = [swmm.get('V-1',swmm.VOLUME,swmm.SI), ...
                  swmm.get('V-2',swmm.VOLUME,swmm.SI), ...
                  swmm.get('V-3',swmm.VOLUME,swmm.SI)];
        t(j,:) = swmm.get_time;
        j = j+1;
      end
end


[errors, duration] = swmm.finish;
disp('cuarta')    

%% RETRIEVING INFORMATION 181
[time, altura10] = swmm.read_results('V-1', swmm.NODE, swmm.DEPTH);
[time, altura11] = swmm.read_results('V-2', swmm.NODE, swmm.DEPTH);
[time, altura12] = swmm.read_results('V-3', swmm.NODE, swmm.DEPTH);


U = [u;u2;u3;u4];
volumen = [v;v2;v3;v4];
%%
% tanques = iddata([altura1,altura2,altura3],u,0.25);
% 
% modelo_ = ssest(tanques,10,'DisturbanceModel','none','Form','canonical');
% 
% modelo = c2d(ss(modelo_),0.25);
% % 
% compare(tanques,modelo_)