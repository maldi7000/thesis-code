function [y,EFF,SNR] = analyze_nets(varargin)
%ANALYZE_NETS analyzes the performance of the given nets
%
% [Y, EFF, SNR] = analyze_nets(NETS, X, T, ...) takes a cell-array of neural networks
% (feed-forward) NETS, network inputs X and targets T and analyzes them. It
% returns an NxM matrix Y, where N is the number of input networks and M is
% the number of input samples. Furthermore returns Nx1 vectors EFF, the efficiency and
% SNR, the signal-to-noise ratio of the output, both values for a threshold
% value (dividing the output into signal and background) of 0.5;
%
% [Y, EFF, SNR] = analyze_nets(NETS_W_X, T, ...) takes a cell-array
% NETS_W_X where each entry consists of a combination of NETS and inputs X,
% which all share the same targets T. This makes it possible to assess
% different networks with different inputs (but same targets) against each
% other. Y will be a NxM matrix in this case where N is the total number of
% nets passed (in all entries), and M is the length of T. EFF and SNR
% remain unchanged (see above).
%
% [Y, EFF, SNR] = analyze_nets(NETS_W_X_T, ...) takes a cell-array
% NETS_W_X_T where each entry is a 'combination' of networks together with
% inputs and targets. THis makes it possible to assess different nets with
% different inputs and different targets against each other. Y will be a
% Nx1 cell-array, where N is the number of input combinations. Every entry
% of the cell-array will of the same type as if only one network was passed
% (see first mode of input). EFF and SNR remain unchanged.
%
% If the input NETS is a SxQ input cell array it is rearranged internally
% into a "column cell-array" such that the final order of nets will be from
% top left to bottom right (row wise rearrangement). This is true for all
% the above presented input modes.
%
% The function can be given one additional input KEYNAMES, which is a
% cell-array with K entries of type string. K is the total number of passed
% nets. The entries of KEYNAMES will be used in the legend of the plots. If
% the number K does not match the number of passed nets, the cell array
% will be either cropped or filled with dummy names ('unlabeled x').
%
% NOTE: plots will only be produced if more than one output argument is
% desired.

% by Thomas Madlener, 2015

%% input checks and handling
if isempty(varargin), error('no inputs'), end

nargs = length(varargin); % get number of arguments
if nargs > 4, error('too many input arguments'), end

if iscellstr(varargin{end}) % if names for keys are passed remove it from discrimination
    nargs = nargs - 1; % reduce nargs to number of network related entries
    keyentries = varargin{end}; % check later if there are enough entries
else
    keyentries = {}; % fill later if there are no passed key names
end

if nargs == 3, allnets = {varargin{1}, varargin{2}, varargin{3}}; end % checks are done later
if nargs == 2
    ncell = length(varargin{1});
    allnets = {}; % create empty net and add
    for i=1:ncell % fill -> checks are done later
        allnets{i,1} = varargin{1}{i,1};
        allnets{i,2} = varargin{1}{i,2};
        allnets{i,3} = varargin{2};
    end
end
if nargs == 1, allnets = varargin{1}; end

% checks
for i=1:size(allnets,1)
    if length(allnets{i,2}) ~= length(allnets{i,3})
        error('network inputs X and tartes T do not have the same length for one of the inputs')
    end
    if isa(allnets{i,1}, 'cell')
        if any(any(cellfun(@(net) ~isa(net, 'network'), allnets{i,1})))
           error('at least one of the inputs that is supposed to be a net is not a net') 
        end
        if ~isvector(allnets{i,1}) % check if nets is a column vector
            fprintf('rearranging networks to be a "vector"\n')
            % bring into vector like shape: the order is: elements of row 1,
            % elements of row 2 and so on
            allnets{i,1} = reshape(allnets{i,1}',[],1); % also reshapes row-vectors to column-vectors
        end
    else
        if isa(allnets{i,1}, 'network')
            allnets{i,1} = {allnets{i,1}}; % convert to cell-array with one entry
        else
            error('input that is supposed to be a network is not a net')
        end
    end
end
% calculate the total number of networks that have been passed
nnets = 0;
for i=1:size(allnets,1), nnets = nnets + length(allnets{i,1}); end

if length(keyentries) < nnets && nargout > 1 % fill up entries to match the number of passed nets
    for i=length(keyentries)+1:nnets
        keyentries{i} = sprintf('unlabeled %d', i);
    end
end
if length(keyentries) > nnets && nargout > 1 % remove extra entries
    warning('got %d names for legend entries, but only %d nets.', length(keyentries), nnets)
    keyentries(nnets+1:end) = [];
end

% close all % close all present figures on function call

%% main function begin, should run save after input check has been passed
% create a matrix or a cell of matrices of network outputs -> (rows correspond to net)
% depending on the targets
fprintf('calculating network outputs\n')
% looping seems to be faster than cellfun
ytmp = cell(size(allnets,1), 1); % store network outpus in cell-array, concatenate later
for i=1:size(allnets,1)
    ytmp{i} = calc_output(allnets{i,1}, allnets{i,2}, allnets{i,3});
end


if nargs == 1, y = ytmp;
else y = []; for i=1:length(ytmp), y = [y; ytmp{i}]; end, end
if nargout < 2, return; end % do not do further calculations or plot if only y is desired as output

% calc SNR and efficiency for threshold value 0.5
fprintf('calculating SNR and efficiency\n')
SNR = []; EFF = [];
for i=1:size(ytmp,1)
    [snr_tmp, eff_tmp] = snr_eff(allnets{i,3}, ytmp{i}, 0.5);
    SNR = [SNR; snr_tmp];
    EFF = [EFF; eff_tmp];
end

%% plotting
col = colormap(lines(nnets)); % determine line color automatically

fprintf('making SNR and efficiency plots\n')
b=linspace(0,1,51); % threshold values at which snr and eff will be calculated
S = []; R = [];
for i=1:size(ytmp,1)
    Stmp = []; Rtmp = [];
    for j=1:length(b)
        [s,r] = snr_eff(allnets{i,3}, ytmp{i}, b(j));
        Stmp = [Stmp,s];
        Rtmp = [Rtmp,r];
    end
    S = [S; Stmp]; R = [R; Rtmp];
end
h_snr = figure; % maybe return handle?
plot(b, S')
title('signal-to-noise')
xlabel('threshold')
ylabel('SNR in output')
legend(keyentries, 'Location', 'Best');

h_eff = figure; % maybe return handle?
plot(b, R')
title('efficiency')
xlabel('threshold')
ylabel('r')
legend(keyentries, 'Location', 'Best');

% plot roc
h_roc = figure; % maybe return this handle?
fprintf('making ROC plot\n')
iplot=0; % seperate coutner to match the key entries
for i=1:size(ytmp,1)
    for j=1:size(ytmp{i},1)
        iplot = iplot + 1; % increase plot counter
        [TT, FK, ~] = roc(allnets{i,3}, ytmp{i}(j,:));
        plot(FK, TT, 'Color', col(iplot,:));
        hold on
    end
end
title('ROC');
xlabel('False Positive Rate')
ylabel('True Positive Rate')
legend(keyentries, 'Location', 'Best');
hold off

close 1 % ugly hack for removing the one figure that keeps popping up -> TODO: check how this can be handled better
end

%% helper functions
% calculate network outputs
function y = calc_output(nets, x, t)
    y = zeros(length(nets), length(t));
    for i=1:length(nets), y(i,:) = nets{i}(x); end
end

% caclulate snr and efficiency for given targets and outputs and signal threshold
function [s,r] = snr_eff(t,y,boundary)
tt = sum(y(:,t==1)>boundary,2);
ft = sum(y(:,t==0)>boundary,2);
s = tt./ft;
r = tt/sum(t);
end
