%% IMPORT CSV DATA
filename = '17_PI_ident3_20251217_155314.csv';
data = readmatrix(filename);

time_ms   = data(:,2);
pwm_left  = data(:,3)-1090;
pwm_right = data(:,4)-1090;
distance  = data(:,5);

time_s = time_ms / 1000;

distance_ref = 50 * ones(size(distance));

%% Plotting
figure;
plot(time_s, pwm_left, 'LineWidth', 3, 'Color', '[1, 0.647, 0]'); hold on;
grid on;
xlabel('Time [s]');
ylabel('PWM value');
title('PWM');

figure;
plot(time_s, distance, 'LineWidth', 3); hold on;
grid on;
xlabel('Time [s]');
ylabel('Distance [cm]');
title('Measured Distance');


%% Subplotting
figure;

tl = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

c_d = [0, 0.447, 0.741];
c_u = [0.8500, 0.3250, 0.0980];

lw_main = 3.5;

% PWM
ax1 = nexttile; hold on; box on; grid on;

plot(time_s, pwm_left, 'LineWidth', lw_main, 'Color', c_u);
%ylim([0 200])

ylabel('$u~[\mathrm{PWM}]$','Interpreter','latex');
title('Input trajectory');

% DISTANCE
ax2 = nexttile; hold on; box on; grid on;

plot(time_s, distance, 'LineWidth', lw_main, 'Color', c_d);
plot(time_s, distance_ref, '--', 'LineWidth', 1.5, 'Color', c_d);
ylim([0 300])
ylabel('$d~[\mathrm{cm}]$','Interpreter','latex');
xlabel('Time [s]');
title('Output trajectory');

linkaxes([ax1 ax2],'x');
xlim([time_s(1) time_s(end)]);