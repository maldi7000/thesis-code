function [SNR,EFF,CUTS] = analyze_class_out(t,y,lb,ub,keyentries,varargin)
%ANALYZE_CLASS_OUT analyzes the outputs of classifiers
%
% [SNR,EFF,CUTS] = analyze_class_out(T,Y,lb,ub,keyentries) .... TODO
%
% lb - lower boundary of varying threshold
% ub - upper boundary of varying threshold
% TODO: return values
% EFF - efficiency that can be reached for a given cut value (CUTS)
% SNR - signal-to-noise in the output at a given cut (CUTS)
% CUTS - cut values corresponding to the efficiency and SNR values
% -> desired: if not passed automatically determine (or set to 0,1 maybe)

% by Thomas Madlener

%% input handling and checking
% copied from nn_class_hist
if ~iscell(t), t = {t}; end % transform to cell-array
if ~iscell(y), y = {y}; end % transform to cell-array
if nargin == 2, lb = -1; ub = 1; end % assign default values
if nargin == 5
   if ~iscellstr(keyentries), error('passed KEYENTRIES does contain non-string entries'), end
   if ~isvector(keyentries), error('KEYENTRIES has to be passed as vector-like cell-array'), end
else
    keyentries = {}; % populate later if nothing is passed
end
if ~isvector(t), error('T is not a 1xK or Kx1 cell-array'), end
if ~isvector(y), error('Y is not a 1xK or Kx1 cell-array'), end
if length(t) ~= length(y), error('the sizes of T and Y do not match'), end
for i=1:length(t)
    if ~isrow(t{i}), error('the target values have to be passed as a row vector'), end % check if targets are row
    if ~ismatrix(y{i}), error('the outputs have to be passed as a matrix'), end % check if outputs are matrix
    if length(t{i}) ~= length(y{i}) % check if both have the same length
        error('targets and outputs must have the same lenghts')
    end
end

%% begin of main functionality
mins = cellfun(@(x) min(x,[],2), y, 'UniformOutput', false);
maxs = cellfun(@(x) max(x,[],2), y, 'UniformOutput', false);
nnets = sum(cellfun(@(x) size(x,1), mins)); % get the the total number of outputs
[nR,nC] = calc_layout(nnets);
keyentries = check_and_handle(keyentries,nnets);

fprintf('calculating SNR and efficiency\n')
support = 300; % make the number of support points dependent on deisire for plots
if nargout == 0, support = 100; end
b = linspace(lb,ub,support);
S = zeros(length(b), nnets); R = S; % preallocate
ib = 1; ie = 0;
S_in = zeros(1,length(nnets)); % preallocate input SNR-ratio
for i=1:length(t) % loop over all cell-arrays
    ib = ie + 1; ie = ib + size(y{i},1) - 1; % determine where the values fit into the overall array
    [S(:,ib:ie),R(:,ib:ie)] = snr_eff_range(t{i}, y{i}, b);
    S_in(ib:ie) = calc_snr(t{i},1);
end

if nargout >= 1
    SNR = S;
    EFF = R;
    CUTS = b';
end

if nargout == 0
    figure; % return handle?
    plot(b,S);
    title('signal-to-noise')
    xlabel('classification threshold')
    ylabel('SNR in output')
    legend(keyentries,'Location', 'Best')

    figure; % return handle?
    plot(b,R);
    title('efficiency')
    xlabel('classification threshold')
    ylabel('r')
    legend(keyentries,'Location','Best')

    figure;
    [h,l1,l2] = plotyy(b,R,b,S);
%     l1.LineWidth = 3;
%     l2.LineWidth = 3;
    ylabel(h(1), 'efficiency')
    ylabel(h(2), 'SNR_{out}')
    xlabel('classification threshold')

    figure; % return handle?
    plot(R,S./repmat(S_in,size(S,1),1)) % blow up input SNR to 'full' matrix
    % plot(R,S./repmat(S_in,size(S,1),1), 'LineWidth', 3) % thicker lines for presentations and reports
    title('SNR gain vs. efficiency')
    xlabel('efficiency')
    ylabel('SNR_{out}/SNR_{in}')
    xlim([0.99,1]) % set xaxis range to 'interesting' range
    legend(keyentries,'Location','Best')

    % TODO: ROC only works with 0 and 1 targets
    figure; % return handle?
    fprintf('making ROC plot\n')
    iplot = 0;
    col = colormap(lines(nnets)); % determine line colors automatically
    auroc = ones(nnets,1)*0.5; % save the areas under the curve into array
    for i=1:size(y,1)
        for j=1:size(y{i},1)
            iplot = iplot + 1; % increase plot counter
            [TT,FK,~] = roc(t{i}, y{i}(j,:));
            plot(FK,TT, 'Color', col(iplot,:))
    %         plot(FK,TT, 'Color', col(iplot,:), 'LineWidth', 3) % thicker lines
            hold on
            auroc(iplot) = trapz(FK,TT); % calculate auroc using trapez rule
            fprintf('integrated ROC for %s: %f\n', keyentries{iplot}, auroc(iplot)) % using trapezrule to get the area under the curve
    %         keyentries{iplot} = sprintf('%s, AUC = %.03f', keyentries{iplot}, auroc(iplot));
        end
    end
    line([0,1],[0,1],'Color',[0.7,0.7,0.7]); % plot diagonal
    title('ROC');
    xlabel('False Positive Rate')
    ylabel('True Positive Rate')
    legend(keyentries, 'Location', 'Best');
    hold off
end
end

%% helper functions
% calculate the 'optimal layout'
function [nR,nC] = calc_layout(nPlots)
    nR = ceil(sqrt(nPlots));
    nC = ceil(sqrt(nPlots) - 0.5);
end

% get SNR and efficiency value in a range of thresholds from minb to maxb
function [S,R] = snr_eff_range(t,y,b)
    S = zeros(size(y,1),length(b)); R = S; % preallocate
    for i=1:length(b)
        [S(:,i), R(:,i)] = snr_eff(t,y,b(i));
    end
    S = S'; R = R'; % transpose to have the values belonging to one output in columns instead of rows
end

% caclulate snr and efficiency for given targets and outputs and signal threshold
function [s,r] = snr_eff(t,y,boundary)
tt = sum(y(:,t>0)>boundary,2); % t == 1 for signal outputs
ft = sum(y(:,t<=0)>boundary,2); % t == 0 for bg outputs for nns, and -1 for bdts
s = tt./ft;
r = tt/sum(t>0);
end

% process the keyentries input such that no problems arise in its later use
function entries = check_and_handle(keyentries, nnets)
    if ~iscolumn(keyentries), keyentries = keyentries'; end % transform to column 'vector'
    nentries = length(keyentries);
    entries = keyentries;
    if nentries < nnets
        for i=nentries+1:nnets, entries{i} = sprintf('unlabeled %d', i-nentries); end
    end
    if nentries > nnets % remove extra entries
        warning('got %d names for legend entries, but only %d nets.', nentries, nnets)
        entries(nnets+1:end) = [];
    end
end