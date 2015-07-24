function [ cut ] = calculate_cut(targets,outputs,efficiency )
%CALCULATE_CUT calculates the appropriate cut to reach a given efficiency
%
% TODO: DOCUMENTATION
% targets: targtet values (binary)
% outputs: classifier outputs
% efficiency (optional, defaults to 0.99)

% by Thomas Madlener, 2015

%% input checks
if nargin < 2, error('not enough input arguments'), end
if nargin < 3, efficiency = 0.99; end
if length(targets) ~= length(outputs), error('targets and output must be of the same length'), end
if ~isvector(targets) || ~isvector(outputs), error('targets and outputs have to be passed as vectors'), end

lb = min(outputs);
ub = lb + (max(outputs) - lb) / 2;
[~,R,C] = analyze_class_out(targets,outputs,lb,ub);
gtr = R >= efficiency;
c = C(gtr); % get all possible cut values (yielding a good enough efficiency)
cut = c(end); % choose the loosest cut
end

