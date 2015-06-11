function [ out ] = nn_class_hist(t,y)
%NN_CLASS_Hist plots histograms of how a network classifies a certain input
%
% nn_class_hist(T,Y) takes as inputs a 1xN row vector of targets T and a MxN
% matrix of network outputs Y, where N is the number of samples and M is
% the number of networks (from which the outputs are taken). It produces
% for each output a histogram of the output for the whole output and
% superimposed (not stacked!) a histogram of the output of the signal
% samples (as indicated by T).
%
% NOTE: to produce a suitable matrix Y the analyze_nets function can be
% used.

% by Thomas Madlener, 2015

%% input check
if ~isrow(t), error('the targets have to be passed as a row vector'), end % check if targets are row
if ~ismatrix(y), error('the outputs have to be passed as a matrix'), end % check if outputs are matrix
if length(t) ~= length(y) % check if both have the same length
    error('targets and outputs must have the same lenghts')
end

%% function body
mins = min(y,[],2); % get min and max values for every network output
maxs = max(y,[],2);

[nR, nC] = calc_layout(size(y,1));

pad = figure;
for i=1:length(mins)
    subplot(nR,nC,i);
    A = linspace(mins(i), maxs(i), 100);
    hall = histogram(y(i,:),A);
    hold on
    htrue = histogram(y(i,t==1),A);
    hold off
    title(sprintf('net %d', i));
    xlabel('network output');
    ylabel('entries');
    legend('all samples', 'signal samples', 'Location', 'Best');
end
end

function [nR,nC] = calc_layout(nPlots) % TODO: check if this does what I think it does
    nR = ceil(sqrt(nPlots));
    nC = ceil(sqrt(nPlots) - 0.5);
end