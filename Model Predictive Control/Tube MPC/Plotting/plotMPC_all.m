function plotMPC_all(U, X, Yref, u_min, u_max, x_min, x_max, d_min, d_max, palette)
    if nargin < 8, palette = 'default'; end
    my_colors = my_color_palette(palette);
    
    % Definícia k (indexy vzoriek) namiesto času t
    N = size(X, 2);
    k = 0:N-1;
    
    % Nastavenie farieb podľa obrázka:
    % Modrá je v tvojej palete index 1, Oranžová index 2, Zelená index 3
    c_d  = my_colors(1, :); % Modrá
    c_u  = my_colors(2, :); % Oranžová
    c_vr = my_colors(3, :); % Zelená
    
    lw_main = 3.5; 
    
    figure('Color', 'w', 'Name', 'MPC: All Signals Summary');
    tl = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

    % --- 1. INPUT (u) ---
    ax1 = nexttile; hold on; box on; grid on;
    % Constraints
    stairs(k, u_min(1) * ones(size(k)), 'k-.');
    stairs(k, u_max(1) * ones(size(k)), 'k-.');
    % Trajectory - ORANŽOVÁ
    stairs(k, U(1, :), 'Color', c_u, 'LineWidth', lw_main);
    ylabel('$u~[\mathrm{PWM}]$');
    ylim([-15 85]); 
    title('Input trajectory');

    % --- 2. STATE/OUTPUT (d) ---
    ax2 = nexttile; hold on; box on; grid on;
    % Reference (ak existuje)
    if ~isempty(Yref)
        stairs(k, Yref(1, :), '--', 'Color', c_d, 'LineWidth', 1.5);
    end
    % Constraints
    stairs(k, d_min(1) * ones(size(k)), 'k-.');
    stairs(k, d_max(1) * ones(size(k)), 'k-.');
    % Trajectory - MODRÁ
    stairs(k, X(1, :), 'Color', c_d, 'LineWidth', lw_main);
    ylabel('$d~[\mathrm{cm}]$');
    title('Output trajectory');
    ylim([0 305])

    % --- 3. STATE (v_r) ---
    ax3 = nexttile; hold on; box on; grid on;
    % Constraints
    stairs(k, x_min(2) * ones(size(k)), 'k-.');
    stairs(k, x_max(2) * ones(size(k)), 'k-.');
    % Trajectory - ZELENÁ
    stairs(k, X(2, :), 'Color', c_vr, 'LineWidth', lw_main);
    ylabel('$v~[\mathrm{cm/s}]$');
    xlabel('$k$'); % Zmenené na index k
    title('State $x_2$ trajectory');

    % Synchronizácia a limity
    linkaxes([ax1 ax2 ax3], 'x');
    xlim([k(1) k(end)]);
    
    % styleAx(ax1); styleAx(ax2); styleAx(ax3);
end