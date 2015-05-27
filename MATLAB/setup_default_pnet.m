function net = setup_default_pnet(nHidden, varargin)
%SETUP_DEFAUTL_PNET creates a patternnet with default settings
%
% NET = setup_default_pnet(NHIDDEN) creates a patternnet NET with NHIDDEN
% hidden neurons with predefined settings (from here on referred to as
% default) that differ from the MATLAB default. 
%
% Function is essentially a convenience wrapper for easier setup of a
% common default.

% by Thomas Madlener, 2015
if ~isemtpy(varargin)
    warning('at the moment only one argument is supported. Ignoring all others!')
end
% COULDDO: check nHidden for some properties (e.g. only 1-dim matrix, ...)

tmpnet = patternnet(nHidden);

% TODO: define default

net = tmpnet;