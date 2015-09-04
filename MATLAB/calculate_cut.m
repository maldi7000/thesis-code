function [ cut ] = calculate_cut(targets,outputs,efficiency )
%CALCULATE_CUT calculates the appropriate cut to reach a given efficiency
%
% TODO: DOCUMENTATION
% targets: targtet values (binary) as a vector of length M
% outputs: classifier outputs (a NxM matrix of classifier outputs)
% efficiency (optional, defaults to 0.99)
% returns cut a Nx1 vector

% by Thomas Madlener, 2015

%% input checks
if nargin < 2, error('not enough input arguments'), end
if nargin < 3, efficiency = 0.99; end
if length(targets) ~= size(outputs,2), error('targets and output must be of the same length'), end
if ~isvector(targets), error('targets have to be passed as a vector'), end

% sort signal outputs in descending order in every row
y = sort(outputs(:,targets == 1), 2, 'descend');
% return the value which has 99 % of all values above it
cut = y(:,ceil(size(y,2) * 0.99));

end
