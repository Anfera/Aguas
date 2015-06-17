%% INITIALIZE SWMM

    clear all; 
    close all;
    inp = 'swmm_files/3tanks.INP';
    swmm = SWMM;
    clc;

%% RETRIEVING VARIABLE IDs FROM THE .INP

    links = swmm.get_all(inp, swmm.NODE, swmm.NONE);

%% RUNNING A SWMM SIMULATION 
    i = 1;

    swmm.initialize(inp);
    swmm.modify_setting('R-5',0);
    swmm.modify_setting('R-6',0);
    while ~swmm.is_over
        swmm.run_step;
        if swmm.get('V-2',swmm.DEPTH,swmm.SI) > 2
            swmm.modify_setting('R-5',0);
        else
            swmm.modify_setting('R-5',1);
        end
        if swmm.get('V-3',swmm.DEPTH,swmm.SI) > 2
            swmm.modify_setting('R-6',0);
        else
            swmm.modify_setting('R-6',1);
        end
        a(i) = swmm.get('R-6',swmm.SETTING,swmm.SI);
        i = i+1;
    end

    [errors, duration] = swmm.finish;
    
%% RETRIEVING INFORMATION
    fprintf('Total flooding = %.3f m3\n', swmm.total_flooding);
    [time, fn5] = swmm.read_results('V-3', swmm.NODE, swmm.DEPTH);
    plot(time,fn5)
