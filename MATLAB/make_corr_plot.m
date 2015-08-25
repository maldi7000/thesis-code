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
