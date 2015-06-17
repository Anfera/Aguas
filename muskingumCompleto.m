%% Ejemplo red 3 tanques
%% INITIALIZE SWMM
clear all; 
close all;
inp = 'swmm_files/01_Lluvia Actual.INP';
swmm = SWMM; 
clc;

%% RETRIEVING VARIABLE IDs FROM THE .INP AND GRAPH
[links,from] = swmm.get_all(inp, swmm.LINK, swmm.FROM_NODE);
[links,to] = swmm.get_all(inp, swmm.LINK, swmm.TO_NODE);
nodos = swmm.get_all(inp, swmm.NODE, swmm.NONE);

from = [from]';
to = [to]';

% Esto no es en realidad un grafo. En esta matriz las columnas son canales
% origen, y las filas son canales destino. Si hay un 1 en la posicion (2,1)
% indica que links{1} envia agua al links{2}. Si una columa está vacia
% indica que el canal no envia a ningún otro, i.e., termina un nodo
% terminal. Si una fila esta vacia indica que ese canal no recibe de ningún
% otro, i.e., empieza en una cabeza de la red.
grafo = zeros(size(links,2));
for i = 1:length(links)
    grafo(node2position(to{i},from),i) = 1;
end

disp('"grafo" obtenido')

%% RUNNING A SWMM SIMULATION 

swmm.initialize(inp);
i=1;    

while ~swmm.is_over  
      swmm.run_step;
end

[errors, duration] = swmm.finish;

disp('Cosimulación completada')

%% RETRIEVING INFORMATION
% Requerimos la información del inflow, outflow y volume para realizar
% muskingum.
for i = 1:length(links)
    [time,inflow(:,i)] = swmm.read_results(from{i}, swmm.NODE, swmm.INFLOW);
    [time,outflow(:,i)] = swmm.read_results(links{i}, swmm.LINK, swmm.FLOW);
    [time,volume(:,i)] = swmm.read_results(links{i},swmm.LINK, swmm.VOLUME);
end

disp('Datos de inflow,outflow y volume obtenidos')

%% MUSKINGUM
% Estos dos vectores tienen los A y B de todos los canales en el orden del
% vector "links"
A = sdpvar(1,size(volume,2));
B = sdpvar(1,size(volume,2));

% Para solo realizar la optimzación 1 vez, metemos todos las variables en
% un solo vector.
volume_bar = inflow.*repmat(A,size(volume,1)) + ...
             outflow.*repmat(B,size(volume,1));

% Sumamos el error cuadrático sobre todos los canales de la red.
objective = 0;
for i = 1:size(volume,2)
    objective = objective + norm(volume(:,i) - volume_bar(:,i),2);
end

constraints = [];
disp('Empieza optimización')
optimize(constraints,objective);
disp('Terminó optimización')

a = value(A);
b = value(B);

%% STATE SPACE MODEL OF THE SYSTEM
% Primero determinamos la parte autónoma del sistema i.e., la diagonal.
A = diag([-1./b]);

% Luego necesitamos hallar las interacciones entra canales. Para esto
% utilizamos el pseudo-grafo.

[q,w] = max(grafo,[],1); %Esta variable indica donde hay 1's en el "grafo"

for i = 1:length(links)
    if(q(i) ~= 0)
        A(w(i),i) = (a(w(i)) + b(w(i)))/(b(i)*b(w(i)));
    end
end