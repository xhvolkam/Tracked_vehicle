function iMPC = buildTubeMPC_simple()
% buildTubeMPC_simple constructs the robust Tube MPC controller used online.
% The controller operates in deviation coordinates around the 50 cm distance
% reference and accounts for bounded additive disturbances.

    yalmip('clear');

    %% Model
    Ts = 0.05;

    alpha = 0.97598559;
    beta  = 2.60070905e-02;
    gamma = -3.93189112e-02;

    % Identified affine discrete-time model:
    % d(k+1) = d(k) - Ts*v(k), v(k+1) = alpha*v(k) + beta*u(k) + gamma.
    A = [1   -Ts;
         0   alpha];

    B = [0;
         beta];

    f = [0;
         gamma];

    E = eye(2);

    %% Reference state
    x_ref = [50; 0]; %#ok<NASGU>

    %% Deviation model
    % z = x - x_ref = [d-50; v]
    % Tube MPC propagates uncertainty around this nominal model using E*d.
    model = ULTISystem('A', A, 'B', B, 'E', E, 'f', f);

    % Disturbance bounds represent small modeling and measurement errors.
    model.d.min = [-0.5; -1e-5];
    model.d.max = [ 0.5;  1e-5];

    %% Constraints in deviation coordinates
    % Distance limits are shifted by the 50 cm reference: z_d = d - 50.
    model.x.min = [ -10; -80];
    model.x.max = [250;  80];

    model.u.min = -10;
    model.u.max = 80;

    model.u.with('deltaMin');
    model.u.with('deltaMax');
    % Input-rate constraints reduce abrupt PWM changes between samples.
    model.u.deltaMin = -20;
    model.u.deltaMax =  20;

    model.x.penalty = QuadFunction(diag([2, 15]));
    % Higher velocity penalty encourages slower approach near the reference.
    model.u.penalty = QuadFunction(15);

    %% Horizon + options
    N = 10;
    % implicit Tube MPC keeps the robust invariant tube inside the controller
    % formulation instead of manually tightening constraints in this script.
    option = {'TubeType','implicit','solType',1,'LQRstability',0};

    %% Build controller
    iMPC = TMPCController(model, N, option);

end
