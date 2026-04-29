clc
clear
close all

%% Data
filename = "MPC_delta_u.csv";
T = readtable(filename);

t = (T.TEXP - T.TEXP(1)) / 1000;
k = 0:length(t)-1;

d       = T.DIST_FILT(:);
d_raw   = T.DIST_RAW(:);

v_raw   = T.V_RAW(:);
v_f     = T.V_FILT(:);

pwm_rx  = T.PWM_RX(:);
pwm_cmd = T.U_CMD_PWM(:);

u       = T.U_SHIFT(:);
loop    = T.LOOP_TIME_MS(:);

%% Constraints
d_ref_val = 50;
d_ref = d_ref_val * ones(size(d));

d_min = 5;
d_max = 300;

v_min = -80;
v_max = 80;

u_min = 0;
u_max = 80;

%% Matrices
U    = u.';                 % 1 x N
X    = [d.'; v_f.'];        % 2 x N
Y    = d.';                 % 1 x N
Yref = d_ref.';             % 1 x N

u_min_vec = u_min;
u_max_vec = u_max;

x_min_vec = [d_min; v_min];
x_max_vec = [d_max; v_max];

y_min_vec = d_min;
y_max_vec = d_max;

Nsim_u = size(U,2);
Nsim_x = size(X,2);
Nsim_y = size(Y,2);

%% Plotting

% INPUT: u = PWM shift
plotMPC_inputs(U, u_min_vec, u_max_vec, Nsim_u, 1, 'default');

% STATES: x1 = distance, x2 = filtered relative velocity
plotMPC_states(X, x_min_vec, x_max_vec, Nsim_x, 1, 'default');

plotMPC_states(X, x_min_vec, x_max_vec, Nsim_x, 2, 'default');

% OUTPUT: y = distance
plotMPC_outputs(Y, y_min_vec, y_max_vec, Nsim_y, 1, 'default', Yref);

plotMPC_all(U, X, Yref, u_min_vec, u_max_vec, x_min_vec, x_max_vec, d_min, d_max, 'default');