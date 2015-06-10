function [EFF,SNR,y] = analyze_nets(nets, x, t)
%analyze_nets analyzes the performance of the given nets
%
% analyze_nets(NETS, X, T) takes a cell-array of neural networks
% (feed-forward) NETS, network inputs X and targets T and analyzes them.
% (Also makes some plots)
%
% TODO: finish documentation
% TODO: decide on outpus
% TODO: decide on plots

% by Thomas Madlener, 2015

% TODO: input checks

% close all % close alle figures

% create a matrix of network outputs -> (rows correspond to net)
y = cell2mat(cellfun(@(net) sim(net,x), nets, 'UniformOutput', false)');

col = colormap(lines(length(nets))); % determine line color automatically

% plot roc
h_roc = figure; % maybe return this handle?
hold on
keyentries = cell(1,size(y,1));
for i=1:size(y,1)
    [TT, FK, ~] = roc(t,y(i,:));
    plot(FK, TT, 'Color', col(i,:));
    keyentries{i} = sprintf('net %d', i);
end
title('ROC');
xlabel('False Positive Rate')
ylabel('True Positive Rate')
legend(keyentries);
hold off

[SNR, EFF] = snr_eff(t,y,0.5); % calculate efficiency for 'default' split

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
