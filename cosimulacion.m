%% Control red 3 tanques
%% INITIALIZE SWMM
inp = 'swmm_files/3tanks.INP';
swmm = SWMM;
clc;

%% RETRIEVING VARIABLE IDs FROM THE .INP
links = swmm.get_all(inp, swmm.NODE, swmm.NONE);
orificios = swmm.get_all(inp, swmm.ORIFICE, swmm.NONE);

%% RUNNING A SWMM SIMULATION 
Q = 10*eye(3);
R = eye(3);

swmm.initialize(inp);
i=1;

u = sdpvar(repmat(nu,1,N),repmat(1,1,N));

while ~swmm.is_over  
      swmm.run_step;
      
      if mod(swmm.get_time,0.25) < 0.0084        
        constraints = [];
        objective = 0;
        x = [swmm.get('V-1',swmm.DEPTH,swmm.SI);...
             swmm.get('V-2',swmm.DEPTH,swmm.SI);...
             swmm.get('V-3',swmm.DEPTH,swmm.SI)];
         
        for k = 1:N
         x = A*x + B*u{k};
         objective = objective + norm(Q*(x-0.2),2) + norm(R*u{k},2);
         constraints = [constraints, 0 <= u{k}<= 0.25, 0<=x<=5];
        end

        optimize(constraints,objective);
        U = round(100*value(u{1}))/100       
        swmm.modify_setting('R-4',U(1));
        swmm.modify_setting('R-5',U(2));
        swmm.modify_setting('R-6',U(3));
        i = i+1
      end
end

[errors, duration] = swmm.finish;
    
%% RETRIEVING INFORMATION
[time, altura1] = swmm.read_results('V-1', swmm.NODE, swmm.DEPTH);
[time, altura2] = swmm.read_results('V-2', swmm.NODE, swmm.DEPTH);
[time, altura3] = swmm.read_results('V-3', swmm.NODE, swmm.DEPTH);

plot(altura1)
