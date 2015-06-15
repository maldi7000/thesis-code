function [ out ] = nn_scatter_inout(net,x,t, var1, var2)
%NN_SCATTER_IN_OUT produces pairwise scatter plots and the predictions of
%of the neural net
%
% nn_scatter_inout(NET,X,T,D1,D2) takes as inputs a neural network NET, network
% inputs X and target values T and produces a scatterplot of X(D2) vs X(D1)
%
% X - NxM: N -> number of variables, M -> number of samples
% T - QxM: Q -> number of output variables, M -> see above
% TODO: finish documentation

% by Thomas Madlener, 2015

%% input handling and checks
if ~isa(net, 'network'), error('first argument is no network'), end
[Nx,Mx] = size(x);
[Nt,Mt] = size(t);
if Mx ~= Mt, error('need the same number of targets and input samples'), end
if var1 > Nx || var2 > Nx, error('dimension out of range'), end

%% main function body
y = (sim(net,x) >= 0.5); % using 0.5 as classification threshold for the moment
tt = (t == 1 & y == 1); % true true
tf = (t == 0 & y == 0); % true false
ft = (t == 0 & y == 1); % false true
ff = (t == 1 & y == 0); % false false

stt = scatter(x(var1,tt), x(var2,tt), 10, [0,0,0.75], 'filled', 'o'); % dark blue small circles for true trues
hold on
stf = scatter(x(var1,tf), x(var2,tf), 10, [0.75,0,0], 'filled', 'o'); % dark red small circles for true falses
sft = scatter(x(var1,ft), x(var2,ft), 75, [1,0,0], 'x'); % light red x'ses for false trues
sft.LineWidth = 1; % COULDDO: determine linewidth and symbol sizes from number of data points
sff = scatter(x(var1,ff), x(var2,ff), 75, [0,0,1], 'x'); % light blue x'ses for false false
sff.LineWidth = 1;
hold off
end
