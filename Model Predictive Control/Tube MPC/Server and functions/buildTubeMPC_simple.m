function iMPC = buildTubeMPC_simple()

    yalmip('clear');

    %% Model
    Ts = 0.05;

    alpha = 0.97598559;
    beta  = 2.60070905e-02;
    gamma = -3.93189112e-02;

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
    model = ULTISystem('A', A, 'B', B, 'E', E, 'f', f);

    model.d.min = [-0.5; -1e-5];
    model.d.max = [ 0.5;  1e-5];

    %% Constraints in deviation coordinates
    model.x.min = [ -10; -80];
    model.x.max = [250;  80];

    model.u.min = -10;
    model.u.max = 80;

    model.u.with('deltaMin');
    model.u.with('deltaMax');
    model.u.deltaMin = -20;
    model.u.deltaMax =  20;

    model.x.penalty = QuadFunction(diag([2, 15]));
    model.u.penalty = QuadFunction(15);

    %% Horizon + options
    N = 10;
    option = {'TubeType','implicit','solType',1,'LQRstability',0};

    %% Build controller
    iMPC = TMPCController(model, N, option);

end