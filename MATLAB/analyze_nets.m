function [y,EFF,SNR] = analyze_nets(nets, x, t)
%ANALYZE_NETS analyzes the performance of the given nets
%
% [Y, EFF, SNR] = analyze_nets(NETS, X, T) takes a cell-array of neural networks
% (feed-forward) NETS, network inputs X and targets T and analyzes them. It
% returns an NxM matrix Y, where N is the number of input networks and M is
% the number of input samples. Furthermore returns Nx1 vectors EFF, the efficiency and
% SNR, the signal-to-noise ratio of the output, both values for a threshold
% value (dividing the output into signal and background) of 0.5;
%
% If the input NETS is a SxQ input cell array it is rearranged internally
% into a "column cell-array" such that the final order of nets will be from
% top left to bottom right (row wise rearrangement).
%
% NOTE: plots will only be produced if more than one output argument is
% desired.

% by Thomas Madlener, 2015

%% input checks and handling
if length(x) ~= length(t)
    error('network inputs X and targets T do not have the same length')
end
if isa(nets, 'cell')
    if any(any(cellfun(@(net) ~isa(net, 'network'), nets)))
        error('there is at least one entry in NETS that is not a network')
    end
    if ~iscolumn(nets) % check if nets is a column vector
        fprintf('rearranging NETS to be a "vector"\n')
        % bring into vector like shape: the order is: elements of row 1,
        % elements of row 2 and so on
        nets = reshape(nets',[],1); % also reshapes row-vectors to column-vectors
    end
else 
    if isa(nets, 'network')
        nets = {nets}; % put nets into 1x1 cell-array for further processing
    else
        error('NETS input is neither cell array nor network')
    end
end

% close all % close all present figures on function call

%% function begin, should run save after input check has been passed
% create a matrix of network outputs -> (rows correspond to net)
fprintf('calculating network outputs\n')
% cellfun seems to be rather small for non optimized functions -> replace
% with for loop -> TODO: test
% y = cell2mat(cellfun(@(net) sim(net,x), nets, 'UniformOutput', false));
y = zeros(length(nets), length(t)); % preallocate
for i=1:length(nets), y(i,:) = nets{i}(x); end
if nargout < 1, end

col = colormap(lines(length(nets))); % determine line color automatically

% plot roc
h_roc = figure; % maybe return this handle?
fprintf('making ROC plot\n')
keyentries = cell(1,size(y,1));
for i=1:size(y,1)
    [TT, FK, ~] = roc(t,y(i,:));
    plot(FK, TT, 'Color', col(i,:));
    hold on
    keyentries{i} = sprintf('net %d', i);
end
title('ROC');
xlabel('False Positive Rate')
ylabel('True Positive Rate')
legend(keyentries);
hold off

fprintf('calculating SNR and efficiency\n')
[SNR, EFF] = snr_eff(t,y,0.5); % calculate efficiency for 'default' split

fprintf('making SNR and efficiency plots\n')
% make plot for different splitting boundaries
b=linspace(0,1,21);
S = []; R = [];
for i=1:length(b)
    [s,e] = snr_eff(t,y,b(i));
    S = [S,s];
    R = [R,e];
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

end

% helper functions
function [s,r] = snr_eff(t,y,boundary)
tt = sum(y(:,t==1)>boundary,2);
ft = sum(y(:,t==0)>boundary,2);
s = tt./ft;
r = tt/sum(t);
end
