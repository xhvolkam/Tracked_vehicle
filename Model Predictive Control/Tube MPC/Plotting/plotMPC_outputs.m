function plotMPC_outputs(Y, y_min, y_max, Nsim, output_index, palette, Yref)
    if nargin < 6
        palette = 'default'; % default palette
    end

    my_colors = my_color_palette(palette); % Loading color palette
    color_idx = mod(output_index - 1, size(my_colors, 1)) + 1;

    figure_handle = gcf;
    figure_number = figure_handle.Number;
    figure(figure_number + 1),

    hold on, box on, grid on

    % Plot reference trajectory if Yref is provided
    if nargin >= 7 && ~isempty(Yref)
        stairs(0:size(Yref,2)-1, Yref(output_index, :), '--', 'Color', my_colors(color_idx, :), 'LineWidth', 1.5)
    end

    % Plot constraints
    stairs([0, size(Y,2)-1], [y_min(output_index), y_min(output_index)], 'k-.')
    stairs([0, size(Y,2)-1], [y_max(output_index), y_max(output_index)], 'k-.')

    % Plot output trajectory
    stairs(0:size(Y,2)-1, Y(output_index, :), 'Color', my_colors(color_idx, :), 'LineWidth', 3.5)

    % Axis settings
    axis([0, Nsim - 1, 1.1 * y_min(output_index), 1.1 * y_max(output_index)])

    % Labels
    xlabel('$k$')
    ylabel(['$y_{', num2str(output_index), '}$'])
    title(['Output trajectory of $y_{', num2str(output_index), '}$'])
end