function plotMPC_states(X, x_min, x_max, Nsim, state_index, palette, Yref, C)

    if nargin < 6 
        palette = 'default'; % default palette
    end

    my_colors = my_color_palette(palette); % Loading color palette
    color_idx = mod(state_index - 1, size(my_colors, 1)) + 1;
    
    figure_handle = gcf;
    figure_number = figure_handle.Number; 
    figure(figure_number + 1), 
    
    hold on, box on, grid on


    % Plot constraints
    stairs([0, size(X,2)-1], [x_min(state_index), x_min(state_index)], 'k-.')
    stairs([0, size(X,2)-1], [x_max(state_index), x_max(state_index)], 'k-.')

    % Plot state trajectory
    stairs(0:size(X,2)-1, X(state_index, :), 'Color', my_colors(color_idx, :), 'LineWidth', 3.5)

    % Axis settings
    axis([0, Nsim - 1, 1.1 * x_min(state_index), 1.1 * x_max(state_index)])

    % Labels
    xlabel('$k$')
    ylabel(['$x_{', num2str(state_index), '}$'])
    title(['State trajectory of $x_{', num2str(state_index), '}$'])
end
