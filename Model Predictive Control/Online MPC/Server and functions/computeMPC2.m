function [u_shift, u_cmd_pwm, v_raw, v_f, state] = computeMPC2(d, u_prev, PWM_ZERO, state)

persistent MPCcontroller

%% 1) Inicializacia state

if nargin < 4 || isempty(state)
    state = struct();
end

if ~isfield(state, 'initialized')
    state.initialized = false;
end

if ~isfield(state, 'prev_d')
    state.prev_d = d;
end

if ~isfield(state, 'v_f')
    state.v_f = 0;
end

Ts = 0.05;
aV = 0.2;

%% 2) Postavenie MPC

if isempty(MPCcontroller)

    yalmip('clear');

    alpha = 0.97598559;
    beta  = 2.60070905e-02;
    gamma = -3.93189112e-02;

    %% State-space model
    % x = [d; v]
    A = [1   -Ts;
         0   alpha];

    B = [0;
         beta];

    g = [0;
         gamma];

    C = [1 0];

    %% Constraints
    d_min = 5;
    d_max = 300;

    v_min = -80;
    v_max = 80;

    x_min = [d_min; v_min];
    x_max = [d_max; v_max];

    u_min = 0;
    u_max = 80;

    du_min = -20;
    du_max =  20;

    y_min = d_min;
    y_max = d_max;

    % Safety constraints
    d_safe_hard = 50;
    d_safe_soft = 55;

    %% Sizes
    nx = size(A,1);
    nu = size(B,2);
    ny = size(C,1);

    %% Horizon
    N = 50;

    %% Normalized weights
    y_span   = d_max - d_min;
    u_span   = u_max - u_min;
    du_span  = du_max - du_min;
    eps_span = d_max - d_safe_soft;

    Qy    = 10 / (y_span^2);
    Ru    = 5 / (u_span^2);
    Rdu   = 1 / (du_span^2);
    Qsoft = 1e6 / (eps_span^2);

    %% Decision variables
    x0 = sdpvar(nx,1);

    u = sdpvar(repmat(nu,1,N),   repmat(1,1,N));
    x = sdpvar(repmat(nx,1,N+1), repmat(1,1,N+1));
    y = sdpvar(repmat(ny,1,N+1), repmat(1,1,N+1));
    r = sdpvar(repmat(ny,1,N+1), repmat(1,1,N+1));

    eps_soft = sdpvar(repmat(1,1,N+1), repmat(1,1,N+1));

    u_previous = sdpvar(nu,1);

    constraints = [];
    objective   = 0;

    %% Initial condition
    constraints = [constraints, x{1} == x0];

    %% Build MPC
    for k = 1:N

        % Output equation
        constraints = [constraints, y{k} == C*x{k}];

        % Delta-u
        if k > 1
            du = u{k} - u{k-1};
        else
            du = u{k} - u_previous;
        end

        % Objective
        objective = objective ...
            + Qy    * (y{k} - r{k})' * (y{k} - r{k}) ...
            + Ru    * (u{k}' * u{k}) ...
            + Rdu   * (du' * du) ...
            + Qsoft * (eps_soft{k}' * eps_soft{k});

        % Dynamics
        constraints = [constraints, x{k+1} == A*x{k} + B*u{k} + g];

        % Standard constraints
        constraints = [constraints, x_min <= x{k} <= x_max];
        constraints = [constraints, y_min <= y{k} <= y_max];
        constraints = [constraints, u_min <= u{k} <= u_max];
        constraints = [constraints, du_min <= du <= du_max];

        % Hard safety constraint
        constraints = [constraints, y{k} >= d_safe_hard];

        % Soft safety constraint
        constraints = [constraints, y{k} + eps_soft{k} >= d_safe_soft];
        constraints = [constraints, eps_soft{k} >= 0];
    end

    %% Terminal step
    constraints = [constraints, y{N+1} == C*x{N+1}];
    constraints = [constraints, x_min <= x{N+1} <= x_max];
    constraints = [constraints, y_min <= y{N+1} <= y_max];

    constraints = [constraints, y{N+1} >= d_safe_hard];
    constraints = [constraints, y{N+1} + eps_soft{N+1} >= d_safe_soft];
    constraints = [constraints, eps_soft{N+1} >= 0];

    objective = objective ...
        + Qy    * (y{N+1} - r{N+1})' * (y{N+1} - r{N+1}) ...
        + Qsoft * (eps_soft{N+1}' * eps_soft{N+1});

    %% Solver
    ops = sdpsettings('solver','gurobi','verbose',0);

    parameters_in = {x{1}, [r{:}], u_previous};
    solutions_out = {[u{:}], [y{:}], [eps_soft{:}]};

    MPCcontroller = optimizer(constraints, objective, ops, parameters_in, solutions_out);
end

%% 3) Vypocet rychlosti zo vzdialenosti

if ~state.initialized
    state.prev_d = d;
    state.v_f = 0;
    state.initialized = true;

    v_raw = 0;
    v_f   = 0;
else
    v_raw = (state.prev_d - d) / Ts;

    state.v_f = (1 - aV) * state.v_f + aV * v_raw;
    v_f = state.v_f;

    state.prev_d = d;
end

%% 4) Spustenie MPC

N = 50;
d_ref = 50;

PWM_MIN = 1090;
PWM_MAX = 1700;

x_now   = [d; v_f];
ref_vec = repmat(d_ref, 1, N+1);

try
    full_solution = MPCcontroller{x_now, ref_vec, u_prev};

    u_sequence = full_solution{1};
    u_shift = double(u_sequence(:,1));

    if isempty(u_shift) || ~isfinite(u_shift)
        u_shift = 0;
    end

catch
    u_shift = 0;
end

u_cmd_pwm = round(PWM_ZERO + u_shift);
u_cmd_pwm = min(max(u_cmd_pwm, PWM_MIN), PWM_MAX);

end