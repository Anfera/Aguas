yalmip('clear')

% Model data
A = modelo.a;
B = modelo.b; 
C = modelo.c;
nx = 10;    % Number of states
nu = 3;     % Number of inputs
ny = 3;     % Number of outputs

% Prediction horizon
N = 10;
% States x(k), ..., x(k+N)
x = sdpvar(repmat(nx,1,N),repmat(1,1,N));
% Inputs u(k), ..., u(k+N) (last one not used)
u = sdpvar(repmat(nu,1,N),repmat(1,1,N));
% outputs y(k), ..., y(k+N) (last one not used)
y = sdpvar(repmat(ny,1,N),repmat(1,1,N));

J{N} = 0;

for k = N-1:-1:1    

    % Feasible region
    constraints = [ 0 <= u{k}     <= 1,
                    0 <= C*x{k}   <= 4,
                   -99<= x{k}   <= 99,
                    0 <= C*x{k+1} <= 4,
                   -99 <= x{k+1}   <= 99];

    % Dynamics
    constraints = [constraints, x{k+1} == A*x{k}+B*u{k}];

    % Cost in value iteration
    objective = norm(x{k},2) + norm(u{k},2) + J{k+1}

    % Solve one-step problem    
    [sol{k},dgn{k},Uz{k},J{k},uopt{k}] = solvemp(constraints,objective,[],x{k},u{k});
end