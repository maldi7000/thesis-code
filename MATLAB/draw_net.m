function [ Y ] = draw_net(net,varargin)
%DRAW_NET draws the given neural net
%
% Y = draw_net(NET,...) takes as input a neural network (at the moment only
% a feedforward network with one hidden layer) and draws its structure and
% some additional information that can be controlled via OPTION. If an
% input is passed the value the network returns for that input is returned
% in Y (0 by default).
%
% an input can be passed with the Name 'input', where the Value is a valid
% network input
%
% possible inputs for Name, Value pair, 'option',...
% + 'plain': simply plot the structure of the network (default) (DONE)
% + 'weigtsabs': plot the structure of the network. The color of each
% connections depends on the absolute weight of the corresponding weight (DONE)
% + 'weights': plot the structure of the network. The color of each
% connections depends on the value of the corresponding weight (TODO)
% + 'input': plot the structure of the network. The color of each
% connection depends on the actual signal value (= weight *
% connection-input). The color of each neuron depends on the neuron input
% (= sum of ingoing signals). This includes preprocessing of the input.
% + 'activation': plot the structure of the network. The color of each
% connection depends on the actual signal value (= weight *
% connection-input). The color of each neuron depends on the neuron
% activation value (= output of neuron). This includes preprocessing of the
% input but no postprocessing ouf the output!
%
% TODO: implementation of log-scale for weights?
% COULDDO (probably a TODO for the above features): refactoring
% TODO: check possibilities of different colormaps for neurons and
% connections -> Especially on the same figure as the network

% by Thomas Madlener, 2015

%% input checks and handling
p = inputParser; % use input parser for handling options and validating stuff
p.KeepUnmatched = true; % debugging purposes
addRequired(p, 'net', @(x) isa(x, 'network'));

expectedOptions = {'plain', 'weightsabs', 'weights', 'input', 'activation'};
defaultOption = 'plain';
addOptional(p,'option',defaultOption, ...
    @(x) any(validatestring(x,expectedOptions)));
defaultInput = [];
addOptional(p, 'input', defaultInput, @isnumeric);

parse(p,net,varargin{:});
option = p.Results.option;
inputVec = p.Results.input;

if length(net.layers) > 2, error('can only handle networks with one hidden layer at the moment'), end
[~,iS] = size(net.IW{1});
[~,~] = size(net.LW{2,1});
if isempty(inputVec), inputVec = ones(iS,1); end % fill with ones for default behaviour
iVS = length(inputVec);
if ~iscolumn(inputVec), error('input has to be a column-vector'), end
if iS ~= iVS, error('length of input vector does not match the number of input neurons'),end

Y = 0; % default return value);
%% main function body
% get the values for all objects to plot
[inV,hidV,oV,W_ih,W_ho,hB,oB] = get_values(net,option,inputVec);

% calculate output if necessary
if ~isempty(p.Results.input), Y = calculate_output(oV,net,option); end

% new version
max_w = max([max(W_ih), max(W_ho), max(hB), max(oB)]);
min_w = min([min(W_ih), min(W_ho), min(hB), min(oB)]);
in_h_c = get_object_colors(W_ih, max_w, min_w, 'line');
h_o_c = get_object_colors(W_ho, max_w, min_w, 'line');
b_h_c = get_object_colors(hB, max_w, min_w, 'line'); % get colors of bias connections
b_o_c = get_object_colors(oB, max_w, min_w, 'line');

max_n = max([inV; hidV; oV]); % maybe have to transpose oV
min_n = min([inV; hidV; oV]);
inc = get_object_colors(inV, max_n, min_n, 'neuron');
hidc = get_object_colors(hidV, max_n, min_n, 'neuron');
outc = get_object_colors(oV, max_n, min_n, 'neuron');

create_drawing(inc,hidc,outc,in_h_c, b_h_c, h_o_c, b_o_c);
if ~strcmp(option, 'plain')
    if max_n == min_n && max_n == 0
        draw_legend(max_w, min_w, ''); % colorbar on same figure
    else
        draw_legend(max_w, min_w, 'weights');
        draw_legend(max_n, min_n, 'neurons');
    end
end % TODO: fix, needs handle?
end

%% plotting functions
% draw the network on canvas. needed: colors of all neurons and colors of
% all connections
function handle = create_drawing(I, H, O, ih, bh, ho, bo)
    handle = figure; hold on, % axis equal
    axis off
    set(gcf, 'color', [1,1,1]); % white background
    
    handle = draw_weight_lines(handle, ih, bh, ho, bo);
    
    [ip_x, hp_x, op_x] = get_x_positions(); % get neuron x- & y-positions
    [ip_y, hp_y, op_y] = get_y_positions([size(ih'), size(ho,1)]);
    
    % draw neurons
    handle = draw_neuron_circles(handle, ip_x, ip_y, I);
    handle = draw_neuron_circles(handle, hp_x, hp_y, H);
    handle = draw_neuron_circles(handle, op_x, op_y, O);

    % draw bias-"neurons"
    B = cell(size(H,1),1); B(:) = {zeros(1,3)}; % bias-neurons shall be black
    handle = draw_neuron_circles(handle, hp_x + 5, hp_y + 2, B, 0.2);
    B = cell(size(O,1),1); B(:) = {zeros(1,3)};
    handle = draw_neuron_circles(handle, op_x - 0.5, op_y + 3, B, 0.2);
end

% new version of draw_weight_lines
function handle = draw_weight_lines(h,H, bH,O,bO)
%     set(groot, 'CurrentFigure', h); % does not work on R2013b, why?
    [y_in, y_hid, y_out] = get_y_positions([size(H'), size(O)]);
    [x_in, x_hid, x_out] = get_x_positions();
    
    % draw lines from input to hidden
    draw_lines(h,x_in, x_hid, y_in, y_hid, H);
    % draw lines from hidden to output
    draw_lines(h,x_hid, x_out, y_hid, y_out, O);
    
    % draw bias connections (CAUTION: the offsets in x and y are hardcoded
    % and also used for drawing the circles!)
    for i=1:length(bH), line([x_hid+5, x_hid],[y_hid(i)+2, y_hid(i)], 'Color', bH{i}); end
    for i=1:length(bO), line([x_out-0.5,x_out],[y_out(i)+3, y_out(i)], 'Color', bO{i}); end
    handle = h; % does this work?
end

% draw lines
% draw all possible lines from x1, y1(i) to x2, y2(j) with color c{i,j}
function handle = draw_lines(h,x1, x2, y1, y2, c)
    for i=1:length(y1)
        for j=1:length(y2)
            line([x1, x2], [y1(i), y2(j)], 'Color', c{j,i});
        end
    end
    handle = h;
end

% draw neuron circles
function handle = draw_neuron_circles(h, x, y, colors, radius)
    %     set(groot, 'CurrentFigure', h); % does not work on R2013b, why?
    if nargin == 4
        radius = .8;
    end
    for i=1:length(y)
        circles(x, y(i), radius, 'facecolor', colors{i});
    end
%     circles(x,y,radius,'facecolor', 'none');
    % TODO: coloring
    handle = h;
end

% draw legend for understanding the meaning of the colors
function handle = draw_legend(w_max, w_min, titlestr)
    if ~isempty(titlestr) % if empty title -> plot on original canvas
        figure; % preliminary solution: plot coloraxis on new plot
        title(titlestr);
    end
%     set(groot, 'CurrentFigure', h); % does not work on R2013b, why?
    colormap(get_colormap(w_max, w_min));
    caxis([w_min, w_max]);
    c = colorbar;
    c.Label.String = 'Absolute value of weight'; % doesnot work in R2013b

%     handle = h; % works?
end

%% helper stuff
% get the values of the connections and the neurons to be drawn
function [iN,hN,oN,ihC,hoC,hB,oB] = get_values(net,option,input)
    % get all values from net first
    ihC = net.IW{1}; hoC = net.LW{2,1}; hB = net.b{1}; oB = net.b{2};
    % initialize neuron values to 0 by default and assign values only if
    % needed
    iN = zeros(size(ihC,2),1); hN = zeros(size(ihC,1),1); oN = zeros(size(hoC,1),1);

    if strcmp(option,'plain') % if option plain set all values to 0
        ihC(:,:) = 0; hoC(:,:) = 0; hB(:,:) = 0; oB(:,:) = 0;
    end
    if strcmp(option,'weightsabs')
        ihC = abs(ihC); hoC = abs(hoC); hB = abs(hB); oB = abs(oB);
    end
    if strcmp(option,'input') || strcmp(option,'activation')
        iN = preprocess(net,input);
        hN = ihC * iN + hB; % input values of hidden neurons
        ihC = get_signal_value(ihC, iN);
        aH = feval(net.layers{1}.transferFcn, hN); % calculate the activation value of the hidden neurons
        oN = hoC * aH + oB; % input value of output neurons
        hoC = get_signal_value(hoC, aH);
    end
    if strcmp(option,'activation')
        hN = aH;
        oN = feval(net.layers{2}.transferFcn, oN);
    end

end

% calculate the output value of the network from the value of the output
% neurons
function output = calculate_output(oN, net, option)
    if ~strcmp(option, 'activation')
        output = feval(net.layers{2}.transferFcn, oN);
        output = postprocess(net,output);
    else
        output = postprocess(net,oN);
    end
end

% calculate the signal values that a connection is transporting
% W is the weight matrix connecting layer i and j, x is the input from
% layer i, signal is the matrix of the signal values (i.e. row i from W
% gets multiplied with value i from x)
function signal = get_signal_value(W,x)
    signal = W .* repmat(x,1,size(W,1))';
end

% preprocess the network inputs to get the same values as y=net(x)
% CAUTION: this does probably not work if there are more than one
% preprocessing functions
function y = preprocess(net,x)
    y = feval(net.input.processFcns{1}, 'apply', x, net.input.processSettings{1});
end

% postprocess the network outputs to get the same values as y=net(x)
function y = postprocess(net,x)
    y = feval(net.output.processFcns{1}, 'reverse', x, net.output.processSettings{1});
end

% determine the positions of the nodes on the plotting plane
function [in_y, hid_y, out_y] = get_y_positions(sizes)
    s = 2; % distance between circle centers -> make this parameter?
    % center the weights around zero
    % calculate the position of the outermost circles
    % uneven numbers of neurons are placed on even circle centers and vice
    % versa by this calculation
    ymax = floor(sizes/2) - (1-mod(sizes,2))*0.5;
    maxsize = max(sizes);

    in_y = (-ymax(1):ymax(1)) * s * maxsize/sizes(1); % additional factor for evenly spacing
    hid_y = (-ymax(2):ymax(2)) * s * maxsize/sizes(2);
    out_y = (-ymax(3):ymax(3)) * s * maxsize/sizes(3);
end

% fix the x-positions so that they can be consistently retrieved throughout
% the function
function [in_x, hid_x, out_x] = get_x_positions()
    in_x = -30; hid_x = 0; out_x = 30;
end

% get colors from default colormap generating function for objects to be
% drawn by passing a matrix of values and a min and max value to determine
% the whole range
function objcolors = get_object_colors(M, v_max, v_min, object)
    objcolors = cell(size(M));
    if v_max == v_min && v_max == 0 % return black lines and white circles for only zero entries
        if strcmp(object,'line'), objcolors(:) = {zeros(1,3)}; end
        if strcmp(object,'neuron'), objcolors(:) = {ones(1,3)}; end
        return;
    end
    colmap = get_colormap(v_max, v_min); % returns a colmap of approx. length 50
    col_int = linspace(v_min, v_max, length(colmap)); % define an intervall for each color
    for i=1:size(M,1)
        for j=1:size(M,2)
            col = find(col_int <= M(i,j));
            objcolors{i,j} = colmap(col(end),:);
        end
    end
end

% define colormap for this function
% COULDDO: make this take options (e.g. greyscale, etc.)
% desired: 
function colmap = get_colormap(v_max, v_min)
    steps = 17; % yields approx 3*steps different if v_min
    if v_min == 0
       ng = steps;
       nr = 0;
    else
        d = abs(v_max - v_min); % range to be spanned
        ng = abs(round(steps  * v_max / d)); % "green steps"
        nr = abs(round(steps * v_min / d)); % "red steps"
    end
    gm = [ones(ng,1); linspace(1,0.5,2*ng)'];
    gh = [linspace(1,0,2*ng)'; zeros(ng,1)];
    rm = [linspace(0.5,1,2*nr)'; ones(nr,1)];
    rh = [zeros(nr,1); linspace(0,1,2*nr)'];
    
    colmap = colormap([rm, rh, rh; gh,gm,gh]);
end