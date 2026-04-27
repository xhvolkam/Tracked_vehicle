clc; clear; close all;

%% Load data
filename = "Identification_profiles.csv";
T = readtable(filename);

t = T.TEXP / 1000;

pwm       = T.PWM;
dist_raw  = T.DIST_RAW;
dist_filt = T.DIST_FILT;

Ts = 0.05;
PWM_ZERO = 1150;

u = pwm(:) - PWM_ZERO;]
d = dist_filt(:);

% Remove NaNs
idx = ~(isnan(d) | isnan(u) | isnan(t));
d = d(idx);
u = u(idx);
t = t(idx);

idx2 = t >= 4;
d = d(idx2);
u = u(idx2);
t = t(idx2);

t = t - t(1);

% Estimate velocity
v = (d(1:end-1) - d(2:end)) / Ts;   % [cm/s]
t_v = t(1:end-1);

% EMA filter on velocity
aV = 0.2;
v_f = zeros(size(v));
v_f(1) = v(1);
for k = 2:length(v)
    v_f(k) = (1-aV)*v_f(k-1) + aV*v(k);
end

%% Plotting
c1 = [0.00 0.45 0.74];
c2 = [0.85 0.33 0.10];
c3 = [0.47 0.67 0.19];

lw = 2.5; fs = 13; bg = "w";

styleAx = @(ax) set(ax, ...
    "FontSize", fs, "LineWidth", 1.1, "Box", "off", ...
    "XMinorGrid", "on", "YMinorGrid", "on", ...
    "GridAlpha", 0.18, "MinorGridAlpha", 0.10);

% Distance
figure("Color", bg, "Name", "Distance");
ax = axes; hold on;
plot(t, d, "LineWidth", lw, "Color", c1);
grid on; styleAx(ax);
xlabel("$t~[\mathrm{s}]$");
ylabel("$d~[\mathrm{cm}]$");
title("Filtered Distance");

% PWM
figure("Color", bg, "Name", "PWM");
ax = axes; hold on;
plot(t, u, "LineWidth", lw, "Color", c2);
grid on; styleAx(ax);
xlabel("$t~[\mathrm{s}]$");
ylabel("$\Delta u~[\mathrm{PWM}]$");
title("PWM Shift");

% Estimated velocity
figure("Color", bg, "Name", "Estimated velocity");
ax = axes; hold on;
plot(t_v, v_f, "LineWidth", lw, "Color", c3);
grid on; styleAx(ax);
xlabel("$t~[\mathrm{s}]$");
ylabel("$v~[\mathrm{cm/s}]$");
title("Velocity estimated from distance (EMA filtered)");

%% Subplotting

figure('Color', 'w', 'Name', 'All Signals Summary');
tl = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

lw_main = 3.5;

u_min_val = 0;
u_max_val = 80;

d_min_val = 5;
d_max_val = 300;

v_min_val = -80;
v_max_val = 80;

% PWM
ax1 = nexttile; 
hold on; box on; grid on;

stairs(t, u_min_val * ones(size(t)), 'k-.', 'LineWidth', 1);
stairs(t, u_max_val * ones(size(t)), 'k-.', 'LineWidth', 1);
stairs(t, u, 'Color', c2, 'LineWidth', lw_main);

ylabel('$u~[\mathrm{PWM}]$', 'Interpreter', 'latex');
title('Input trajectory', 'Interpreter', 'latex');
ylim([0 80]);

ax1.XMinorGrid = 'off';
ax1.YMinorGrid = 'off';

% Distance-
ax2 = nexttile; 
hold on; box on; grid on;

stairs(t, 50 * ones(size(t)), '--', 'Color', c1, 'LineWidth', 1.5);
stairs(t, d_min_val * ones(size(t)), 'k-.', 'LineWidth', 1);
stairs(t, d_max_val * ones(size(t)), 'k-.', 'LineWidth', 1);
stairs(t, d, 'Color', c1, 'LineWidth', lw_main);

ylabel('$d~[\mathrm{cm}]$', 'Interpreter', 'latex');
title('Output trajectory', 'Interpreter', 'latex');

ax2.XMinorGrid = 'off';
ax2.YMinorGrid = 'off';

% Velocity
ax3 = nexttile; 
hold on; box on; grid on;

stairs(t_v, v_min_val * ones(size(t_v)), 'k-.', 'LineWidth', 1);
stairs(t_v, v_max_val * ones(size(t_v)), 'k-.', 'LineWidth', 1);
stairs(t_v, v_f, 'Color', c3, 'LineWidth', lw_main);

ylabel('$v~[\mathrm{cm/s}]$', 'Interpreter', 'latex');
xlabel('$t~[\mathrm{s}]$', 'Interpreter', 'latex');
title('State $x_2$ trajectory', 'Interpreter', 'latex');

ax3.XMinorGrid = 'off';
ax3.YMinorGrid = 'off';

linkaxes([ax1 ax2 ax3], 'x');
xlim([t(1) t(end)]);

%% IDENTIFICATION
% v_f(k+1) = alpha*v_f(k) + beta*u(k) + gamma

u_v = u(1:end-1);

Y   = v_f(2:end);
Phi = [v_f(1:end-1), u_v(1:end-1), ones(length(Y),1)];

theta = Phi \ Y;

alpha = theta(1);
beta  = theta(2);
gamma = theta(3);

fprintf("\nIdentified model (units: v in cm/s, u in PWM_shift):\n");
fprintf("v(k+1) = alpha*v(k) + beta*u(k) + gamma\n\n");
fprintf("alpha = %.8f\n", alpha);
fprintf("beta  = %.8e   [ (cm/s) / PWM ]\n", beta);
fprintf("gamma = %.8e   [ cm/s ]\n", gamma);