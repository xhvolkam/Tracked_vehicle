function my_colors = my_color_palette(palette_name)
% Return of color palette
    switch lower(palette_name)
        case 'default'
            my_colors = [
                0.0000, 0.4470, 0.7410;    % 1. Blue (Distance / d)
                0.8500, 0.3250, 0.0980;    % 2. Orange (Input / u)
                0.4660, 0.6740, 0.1880;    % 3. Green (Velocity / v_r)
                0.4940, 0.1840, 0.5560;    % 4. Purple
                0.9290, 0.6940, 0.1250;    % 5. Yellow
                0.3010, 0.7450, 0.9330;    % 6. Aqua
                0.6350, 0.0780, 0.1840;    % 7. Dark Red
                0.4660, 0.6740, 0.1880;    % 8. Green (repeat)
                0.4940, 0.1840, 0.5560;    % 9. Purple (repeat)
                0.0000, 0.4470, 0.7410];   % 10. Blue (repeat)
        case 'pastel'
            % ... (ponechané bez zmeny)
            my_colors = [
                0.984, 0.705, 0.682;
                0.702, 0.803, 0.890;
                0.800, 0.921, 0.773;
                0.870, 0.796, 0.894;
                0.996, 0.851, 0.651;
                0.651, 0.847, 0.901;
                0.957, 0.776, 0.886;
                0.792, 0.698, 0.839;
                0.749, 0.862, 0.698;
                0.905, 0.816, 0.756];
        case 'bold'
            % ... (ponechané bez zmeny)
            my_colors = [
                0.000, 0.447, 0.741;
                0.850, 0.325, 0.098;
                0.929, 0.694, 0.125;
                0.494, 0.184, 0.556;
                0.466, 0.674, 0.188;
                0.301, 0.745, 0.933;
                0.635, 0.078, 0.184;
                0.600, 0.600, 0.600;
                0.333, 0.658, 1.000;
                0.700, 0.300, 0.600];
        otherwise
            error('Neznáma paleta: %s', palette_name)
    end
end