function plotMPC_inputs(U, u_min, u_max, Nsim, input_index, palette)

    if nargin < 5
        palette = 'default'; % default palette
    end

    my_colors = my_color_palette(palette); % Loading color palette
    color_idx = mod(input_index - 1, size(my_colors, 1)) + 1;
    
    figure_handle = gcf;
    figure_number = figure_handle.Number; 
    figure(figure_number),
    
    hold on, box on, grid on
    
    % Reference lines (commented out, if needed in future)
    % stairs([0, size(U,2)], [0, 0], 'b-')

    % Constraints
    stairs([0, size(U,2) - 1], [u_min(input_index, 1), u_min(input_index, 1)], 'k-.')
    stairs([0, size(U,2) - 1], [u_max(input_index, 1), u_max(input_index, 1)], 'k-.')
    
    % Input trajectory
    stairs(0:size(U,2)-1, U(input_index, :), 'Color', my_colors(color_idx, :), 'LineWidth', 3.5)
   
    % Axis settings
    axis([0, Nsim - 1, 1.1 * u_min(input_index), 1.1 * u_max(input_index)])

    % Labels
    xlabel('$k$')
    ylabel(['$u_{', num2str(input_index), '}$'])
    title(['Input trajectory of $u_{', num2str(input_index), '}$'])
end