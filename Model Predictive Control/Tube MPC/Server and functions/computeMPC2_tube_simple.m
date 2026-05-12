function [u_shift, u_cmd_pwm, v_raw, v_f, state] = computeMPC2_tube_simple(iMPC, d, u_prev, PWM_ZERO, state)
% computeMPC2_tube_simple prepares the measured state for Tube MPC evaluation.
% It estimates velocity from distance, evaluates the prebuilt robust controller,
% and converts the shifted input to an ESC PWM command.

%% Inicialization

if nargin < 5 || isempty(state)
    state = struct();
end

if ~isfield(state, 'initialized')
    state.initialized = false;
end

if ~isfield(state, 'prev_d')
    % Stored distance enables velocity estimation from consecutive samples.
    state.prev_d = d;
end

if ~isfield(state, 'v_f')
    % Filtered velocity is kept between calls as part of the controller state.
    state.v_f = 0;
end

Ts = 0.05;
% EMA coefficient for smoothing velocity derived from noisy distance data.
aV = 0.2;

%% Velocity Computation

if ~state.initialized
    state.prev_d = d;
    state.v_f = 0;
    state.initialized = true;

    v_raw = 0;
    v_f   = 0;
else
    % Positive velocity means the vehicle is moving toward the obstacle.
    v_raw = (state.prev_d - d) / Ts;

    % Smooth the differentiated signal before using it in the Tube MPC state.
    state.v_f = (1 - aV) * state.v_f + aV * v_raw;
    v_f = state.v_f;

    state.prev_d = d;
end

%% Current state
% z = [d-50; v]
% The Tube MPC model is centered at 50 cm, so measured distance is shifted.

z_now = [d - 50;
         v_f];

%% Online MPC Computation
try
    % u.previous activates the controller's delta-u constraint using the last
    % applied shifted PWM command.
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

% Negative shifted inputs are not applied to the vehicle in this experiment.
u_shift_applied = max(0, u_shift);

PWM_MIN = 1090;
PWM_MAX = 1700;

u_cmd_pwm = round(PWM_ZERO + u_shift_applied);
% Final saturation protects the ESC command range even if the optimizer fails.
u_cmd_pwm = min(max(u_cmd_pwm, PWM_MIN), PWM_MAX);

end
