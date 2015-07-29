function [ fig ] = make_corr_plot(X,T)
%MAKE_CORR_PLOT plots correlation matrix
%
% X - matrix to plot
% T - target vector
% TODO: documentation

% by Thomas Madlener

%% main
    fig = figure;
    subplot(2,2,1)
    plot_corr_matrix(corr(X), 'complete data set')
    subplot(2,2,3)
    plot_corr_matrix(corr(X(T==1,:)), 'signal samples')
    subplot(2,2,4)
    plot_corr_matrix(corr(X(T~=1,:)), 'background samples')
end

%% helper functions
function [out_args] = plot_corr_matrix(X, titlestr)
     colormap jet
     imagesc(X);
     caxis([-1 1]);
     colorbar
     title(titlestr)
     for i=1:size(X,1)
         for j=1:size(X,2)
            if(abs(X(i,j)) > 1e-2)
                col = 'k';
                if(abs(X(i,j)) > 0.7), col = 'w'; end
                text(i-0.2,j,num2str(X(i,j), '%.2f'), 'Color', col);
            end
         end
     end
end

