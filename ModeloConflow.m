%% Modelo de la red
% Este código requiere de la función node2position.m!!! Si se encuentra
% algo que pueda ser vectorizado u optimizado, por favor, proseguir!
%% INITIALIZE SWMM
clear all; 
close all;
inp = 'swmm_files/3tanks.INP';
%inp = 'swmm_files/prueba.INP';
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

while ~swmm.is_over
    swmm.run_step;
end

[errors, duration] = swmm.finish;
disp('Cosimulación completada')

%% RETRIEVING INFORMATION
for i = 1:length(links)
    [time,inflow(:,i)] = swmm.read_results(from{i}, swmm.NODE, swmm.INFLOW);
    [time,outflow(:,i)] = swmm.read_results(links{i}, swmm.LINK, swmm.FLOW);
end

aux = sum(grafo,2);
j = 1;
%qin tiene los flujos de entrada a la red. Solo mediremos los flujos de 
%los canales en las cabeceras de la red, i.e.,
%canales asociados a nodos de entrada.
for i = 1:length(links)
    if aux(i) == 0
        qin(:,j) = outflow(:,i);
        inputs{j} = links{i};
        j = j+1;
    end
end

aux = diff(time);
dt = aux(end);      %Esta variable tiene el tiempo de muestreo de SWMM, 
                    %(reporting en horas)

%% DETERMING DELAYS AND ATTENUATION ON EACH CHANNEL
%Este for determina los delays y factores a de todos los canales. Recordar
%tesis de Bernat eq 3.8 que debe ser sintonizada usando mínimos cuadrados.
%Se recomienda agregar una señal de lluvia en swmm que no inunde ningún
%nodo para mejores resultados.

for i = 1:length(links)
    [xData, yData] = prepareCurveData( time, inflow(:,i) );
    ft = 'pchipinterp';
    fitresult = fit( xData, yData, ft, 'Normalize', 'on' );
    f = @(x) norm(x(1)*feval(fitresult,time-x(2)) + ...
             (1-x(1))*feval(fitresult,time-x(2)-dt) ...
              - outflow(:,i),2);
    consA = [1 0;-1 0;0 -1];
    consB = [1;0;0];
    sol = fmincon(f,[0,0],consA,consB);
    [i,length(links)]
    a(i) = sol(1);
    tau(i) = sol(2);
end

%Buscamos que por default a sea 1.
for i = 1:length(a)
    if a(i) == 0
        a(i) = 1;
    end
end

disp('Delays y atenuaciones obtenidas')

%% PROPAGATION OF INFLOWS THROUGH THE NETWORK
%La variable tau obtenida anteriormente se encuentra en las unidades de dt.
%Para obtener una representación en espacio de estados debemos traducirla a
%cantidad de delay. Por ejemplo, un tau de 0.0333 si dt es 1 minuto, 
%implica 2 unidades delay. Preferimos aproximar hacia arriba pues es más lógico que un canal tenga
%una unidad de delay a que no tenga ninguna.
delay = ceil(tau/dt);

%Solo para curarnos en salud, si por alguna extraña razón algun canal
%termina con 0 unidades de delay, le asignamos una unidad automáticamente.
%Esto puede generar problemas en tiempo de muestreos grandes pero se
%corregirá luego.
for i = 1:length(delay)
    if delay(i) == 0
        delay(i) = 1;
    else
        delay(i) = delay(i) + 1;
    end
end

%delay = delay + 1; %Como requerimos q_in tanto en tau como en tau
                            %- dt, agregamos un delay adicional que no 
                            %siempre será usado.

%Primero determinamos la dinámica autonoma de los canales, i.e., como se
%cargan y descargas sus "tanques" internos. A_ esos bloques autónomos y A
%los indexa en una sola matriz.
A = [];

for i = 1:length(links)
    A_{i} = [zeros(1,delay(i));eye(delay(i)-1) zeros(delay(i)-1,1)];
end
A = blkdiag(A_{:});

[q,w] = max(grafo,[],1); %Esta variable indica donde hay 1's en el "grafo"

%Procedemos a la parte más importante del código. Requerimos determinar la
%interacción entre canales en la red. La combinación convexa de las salidas
%de los dos últimos tanques de cada canal son la entrada del siguiente.
%Recordar eq 3.8 de Bernat. Un tanque con 3 unidades de delay tendrá una
%matriz autónoma de 3x3, es decir que la combinación convexa de las columas
%2 y 3 son la entrada del siguiente canal. La matriz grafo ya tiene la
%información de la conexión entre canales.
for i = 1:length(links)
    if(q(i) ~= 0)
        if delay(i) ~= 1 %Esto corrige el error del delay + 1
            A(sum(delay(1:w(i)-1)) + 1,sum(delay(1:i))) = 1-a(i);
            A(sum(delay(1:w(i)-1)) + 1,sum(delay(1:i))-1) = a(i);
        else
            A(sum(delay(1:w(i)-1)) + 2,sum(delay(1:i))) = 1;
        end
    end 
end

disp('matriz A determinada')

%% INPUT AND OUTPUT MATRICES
%Los flujos qin previamente obtenidos entran a la red directamente a los
%canales a los que su input este conectado en la matriz grafo. Por ejemplo,
%si la fila 1 de la matriz grafo esta vacia, el qin de ese canal irá a
%donde la columa 1 de la matriz grafo sea diferente de 0.

B = zeros(size(A,1),length(inputs));

for i = 1:length(inputs)
    B(sum(delay(1:node2position(to{node2position(inputs(i), ... 
        links')},from)- 1)) + 1,i) = dt;
end

%Seleccionamos un canal sobre el cual queremos evaluar el desempeño.
output = 'PMP92951';
%output = 'DES-1';
C = zeros(1,size(A,2));
C(1,sum(delay(1:node2position(output,to)))) = (1- a(node2position(output,to)))/dt;
C(1,sum(delay(1:node2position(output,to)))-1) = (a(node2position(output,to)))/dt;

%% RETRIEVING INFORMATION FROM THE MODEL AND PLOTS
% Siendo una representación en espacio de estados, la salida será la matriz
% C por el vector de estados.

V = zeros(size(A,1),length(time));

for i = 1:length(time) - 1
    V(:,i+1) = A*V(:,i) + B*qin(i,:)';
    [i,length(time) - 1]
end

plot(C*V)
hold on
plot(outflow(:,node2position(output,to)),'r')
legend('Modelo','Real')
grid on