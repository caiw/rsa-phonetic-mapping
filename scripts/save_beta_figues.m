function save_beta_figues(beta_responses, userOptions)

    figures_dir = fullfile(userOptions.rootPath, 'Figures');
    rsa.util.gotoDir(figures_dir);
    
    features = fieldnames(beta_responses)';
    
    %% Get the limits across all figures
    
    % Initial values.
    min_beta = Inf;
    max_beta = -Inf;
    
    % no higher than zero
    min_time_graph = 0;
    max_time_graph = -Inf;
    
    min_frequency_graph = 0;
    max_frequency_graph = -Inf;
    
    for feature = features
       feature = feature{1}; %#ok<FXSET> % unwrap
       for chi = fieldnames(beta_responses.(feature))'
           chi = chi{1}; %#ok<FXSET> % unwrap
           
           beta_matrix = beta_responses.(feature).(chi);
           min_beta = min(min_beta, min(beta_matrix(:)));
           max_beta = max(max_beta, max(max_beta(:)));
           
           time_graph = get_time_graph(beta_matrix);
           min_time_graph = min(min_time_graph, min(time_graph(:)));
           max_time_graph = max(max_time_graph, max(time_graph(:)));
           
           frequency_graph = get_frequency_graph(beta_matrix);
           min_frequency_graph = min(min_frequency_graph, min(frequency_graph(:)));
           max_frequency_graph = max(max_frequency_graph, max(frequency_graph(:)));
       end
    end
    
    % Limits
    abs_max = max(max_beta, abs(min_beta));
    clims = [-abs_max, abs_max];
    time_lims = [min_time_graph, max_time_graph];
    frequency_lims = [min_frequency_graph, max_frequency_graph];
    
    
    %% Show the figures
    
    for feature = features
       feature = feature{1}; %#ok<FXSET> % unwrap
       
       for chi = fieldnames(beta_responses.(feature))'
           chi = chi{1}; %#ok<FXSET> % unwrap
           
           %% make the figure
           
           this_figure = figure;
           
           % set background colour to white, not grey
           set(gcf, 'color', [1 1 1]);
           
           %% time-frequency plot
           
           subplot(2, 2, 3);
           
           beta_matrix = beta_responses.(feature).(chi);
           
           % plot the figure
           imagesc(beta_matrix, clims);
           
           % make it look nice
           axis off;
           
           % Use parula because it's good at being symmetric about its
           % middle.
           colormap(parula);
           
           
           %% Plot the distribution over time
           
           subplot(2, 2, 1);
           
           time_graph = get_time_graph(beta_matrix);
           
           plot(time_graph, ...
               'LineWidth', 4);
           
           xlim([1, numel(time_graph)]);
           ylim(time_lims);
           
           % make it look nice
           axis off;
           
           % plot line through zero
           hold on;
           plot([1, numel(time_graph)], [0, 0], 'k-');
           
           
           %% Plot the distribution over frequencies
           
           subplot(2, 2, 4);
           
           frequency_graph = get_frequency_graph(beta_matrix);
           
           plot(frequency_graph, ...
               'LineWidth', 4);
           
           xlim([1, numel(frequency_graph)]);
           ylim(frequency_lims);
           
           % make it look nice
           axis off;
           
           % plot line through zero
           hold on;
           plot([1, numel(frequency_graph)], [0, 0], 'k-');
           
           % rotate
           view(90, 90);
           
           % remove bounding box
           set(gca, 'box', 'off');
           
           % set background colour to white, not grey
           set(gcf, 'color', [1 1 1]);
           
           %% label it
           
           subplot(2, 2, 2);
           
           % plot an empty imagesc so we can add a colorbar
           imagesc([], clims);
           axis off;
           
           text( ...
               ...% position
               0.5, 0.5, ...
               ...% string
               sprintf('%s (%sh)', lower(feature), lower(chi)), ...
               'FontSize', 24, ...
               'HorizontalAlignment', 'center');
           
           colorbar('SouthOutside');
           
           
           %% Save and close
           
           saveas(this_figure, lower(sprintf('beta_plot_%s-%sh.png', feature, chi)));
           
           close(this_figure);
           
       end
    end

end%function

function time_graph = get_time_graph(beta_matrix)
    time_graph = squeeze(mean(beta_matrix, 1));
end%function


function frequency_graph = get_frequency_graph(beta_matrix)
    frequency_graph = squeeze(mean(beta_matrix, 2));
end%function

