function [u_shift, u_cmd_pwm, v_raw, v_f, state] = computeMPC2_tube_simple(iMPC, d, u_prev, PWM_ZERO, state)

%% Inicialization

if nargin < 5 || isempty(state)
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

%% Velocity Computation

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

%% Current state
% z = [d-50; v]

z_now = [d - 50;
         v_f];

%% Online MPC Computation
try
    [u_opt, feasible] = iMPC.evaluate(z_now, 'u.previous', u_prev);

    if feasible && ~isempty(u_opt) && all(isfinite(u_opt))
        u_shift = double(u_opt(1));
    else
        u_shift = 0;
    end

catch
    u_shift = 0;
end

%% Aplication for a vehicle

u_shift_applied = max(0, u_shift);

PWM_MIN = 1090;
PWM_MAX = 1700;

u_cmd_pwm = round(PWM_ZERO + u_shift_applied);
u_cmd_pwm = min(max(u_cmd_pwm, PWM_MIN), PWM_MAX);

end