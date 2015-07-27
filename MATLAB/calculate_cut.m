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

[lb, ub] = calc_boundaries(outputs,targets, efficiency);
[~,R,C] = analyze_class_out(targets,outputs,lb,ub);
gtr = R >= efficiency;
c = C(gtr); % get all possible cut values (yielding a good enough efficiency)
cut = c(end); % choose the loosest cut
end

%% helper function
% calculate the lower and upper boundary to be used to calculate the
% cut value (via the analyze_class_out function)
function [lb, ub] = calc_boundaries(y,t,r)
    lb = min(y);
    [c,e] = histcounts(y(t==1),100);
    ind = cumsum(c) > (1 -r ) * length(y(t==1));
    ub = min(e(ind));
end
