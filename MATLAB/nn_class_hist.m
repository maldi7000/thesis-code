function [ out ] = nn_class_hist(t,y)
%NN_CLASS_Hist plots histograms of how a network classifies a certain input
%
% TODO: documentation
% input: t -> row-vector (targets) of dimension N
% input: y -> MxN matrix, where M is the number of different networks
% (analyze_nets provides such a matrix)

% by Thomas Madlener, 2015

mins = min(y,[],2); % get min and max values for every network output
maxs = max(y,[],2);

nP = ceil(sqrt(size(y,1)));

pad = figure;
for i=1:length(mins)
    subplot(nP,nP,i);
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

