function net = setup_default_pnet(nHidden, varargin)
%SETUP_DEFAULT_PNET creates a feedforwardnet with default settings
%
% NET = setup_default_pnet(NHIDDEN) creates a feedforwardnet NET with NHIDDEN
% hidden neurons with predefined settings (from here on referred to as
% default) that differ from the MATLAB default. 
%
% NOTE: net is neither configured nor initialized on return!
%
% Function is essentially a convenience wrapper for easier setup of a
% common default.

% by Thomas Madlener, 2015
if length(varargin) > 1
    warning('at the moment only two arguments are supported. Ignoring all others!')
end
% COULDDO: check nHidden for some properties (e.g. only 1-dim matrix, ...)

% TODO: make thorough checks for this at the moment quick hack
tmpnet = feedforwardnet(nHidden);
if ~isempty(varargin)
    if strcmpi('pnet', varargin{1}) % if second argument is 'pnet' setup patternnet instead
        tmpnet = patternnet(nHidden, 'performFcn', 'mse');
    end
end


tmpnet.divideMode = 'sample'; % at the moment no clear explanation of this can be found! should work however
tmpnet.divideFcn = 'dividerand'; % divide data randomly
% NOTE: consider switching to divideind and providing the indices for
% better reproducibility

tmpnet.divideParam.trainRatio = 85/100;
tmpnet.divideParam.valRatio = 15/100;
tmpnet.divideParam.testRatio = 0/100; %% testing with other sample

tmpnet.trainFcn = 'trainscg';

tmpnet.performFcn = 'mse';
tmpnet.trainParam.epochs = 10000;
% tmpnet.trainParam.epochs = 10; % to avoid extremely long training times

net = tmpnet;