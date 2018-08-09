function config = read_config()    
    config.font_size = 16;

    config.x_min = -5.0;
    config.x_max = +5.0;
    config.y_min = -5.0;
    config.y_max = +5.0;
    config.x_step = 0.2;
    config.y_step = 0.2;

    config.data_colors = [0.0, 0.0, 1.0; 1.0, 0.0, 0.0; 1.0, 0.0, 1.0; 0.6, 0.6, 0.6; 0.0, 0.6, 0.6];
    config.data_markers = ['+'; 'x'; '^'; 'v'; '*'];
    config.data_size = 12;
    config.data_width = 2;
    
    config.support_colors = [0.0, 0.0, 0.0; 0.0, 0.0, 0.0; 0.0, 0.0, 0.0; 0.0, 0.0, 0.0; 0.0, 0.0, 0.0];
    config.support_markers = ['o'; 'o'; 'o'; 'o'; 'o'];
    config.support_size = 14;
    config.support_width = 2;
    
    config.discriminant_color = [0.6, 0.6, 0.0];
    config.discriminant_style = '-';
    config.discriminant_width = 4;
    
    config.fit_color = [0.6, 0.6, 0.0];
    config.fit_style = '-';
    config.fit_width = 3;
    
    config.margin_color = [0.6, 0.6, 0.0];
    config.margin_style = '--';
    config.margin_width = 2; 
    
    config.gating_color = [1.0, 0.0, 1.0];
    config.gating_style = '-';
    config.gating_width = 3;
end