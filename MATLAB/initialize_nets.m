function [nets, s_rng] = initialize_nets(nets, init_rng)
%INITIALIZE_NETS reproducibly initializes networks
%
% [NETS, S_RNG] = initialize_nets(NETS, INIT_RNG)
% takes a cell-array (or a single network) of neural networks (patternnet)
% NETS and initializes them via the initlay function. NOTE: the nets have
% to be configured (use configure)
% 
% For reproducibility a struct INIT_RNG for setting the rng can
% be passed (optional). S_RNG is the state of the rng before the first
% initialization.
%
% more to come

% by Thomas Madlener, 2015

if nargin < 1, error('Requires at least one input argument.'); end

% check if all inputs are neural networks and if they are configured
if ~iscell(nets)
    if ~isa(nets, 'network')
        error('first argument is no cell-array and no network')
    end
else
    if any(cellfun(@(x) ~isa(x, 'network'), nets))
        error('there is at least one entry in the first argument that is not a network')
    end
    if any(cellfun(@(x) ~isconfigured(x), nets))
        error('at least one of the networks is not yet configured')
    end
end

% get/set the rng state
if nargin < 2, s_rng = rng;
else
    rng(init_rng);
    s_rng = rng;
end

% for reproducibility not using cellfun here as there the order of access
% is not fixed and should not be relied on (see help cellfun). Using loop
% instead
for i = 1:size(nets,1)
    for j = 1:size(nets,2)
        nets{i,j} = initlay(nets{i,j});
    end
end