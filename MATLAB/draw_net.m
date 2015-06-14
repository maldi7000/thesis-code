function [ output_args ] = draw_net(net)
%DRAW_NET draws the given neural net
%
% draw_net(NET) takes as input a neural network (at the moment only
% a feedforward network with one hidden layer) and analyzes its weights and
% its relations between different neurons
%
% At the moment it plots the neural network and its connections where the
% connections are colored according to the weight of the connection.
%
% NOTE: at the moment only the absolute value of a connection is considered
% on a linear scale
%
% TODO: handling of positive and negative connections
% TODO: implementation of log-scale for weights?
% COULDDO (probably a TODO for the above features): refactoring
%
% COULDDO: implement response of network to a given input (i.e. color lines
% etc. according to the output of given neurons, etc...)
%

% by Thomas Madlener, 2015

%% input checks and handling
if ~isa(net, 'network'), error('input needs to be a network'), end
if length(net.layers) > 2, error('can only handle networks with one hidden layer at the moment'), end
% TODO: more checks?

%% main function body
W_ih = net.IW{1}; % get weigh matrix of input layer - hidden layer
W_ho = net.LW{2,1}; % get weight matrix of hidden layer - output layer
% [hidsize, insize] = size(W_ih);
% outsize = size(W_ho,1);
%
% hidkeys = cell(insize,1);
% for i=1:insize, hidkeys{i} = sprintf('input %d', i); end
% W_ih_vec = reshape(W_ih,[],1); % reshape to (column) vector
% hist(W_ih, 50); % make histogram split by inputs
% hold on
% hist(W_ih_vec,50);
% legend(hidkeys, 'Location', 'Best');

% figure;
% hist(W_ho, 50);

% new version
max_w = max([max(W_ih), max(W_ho)]);
min_w = min([min(W_ih), min(W_ho)]);
in_h_c = get_line_colors(W_ih, max_w, min_w);
h_o_c = get_line_colors(W_ho, max_w, min_w);

% temporary solution -> TODO: get this from actually useful values
inc = cell(size(W_ih,2),1);
hidc = cell(size(W_ih,1),1);
outc = cell(size(W_ho,1),1);

inc = get_circle_colors(inc, 0, 1);
hidc = get_circle_colors(hidc, 0, 1);
outc = get_circle_colors(outc, 0, 1);

% new version which needs the colors of the objects to draw
draw_net(inc, hidc, outc, in_h_c, h_o_c);
end

%% plotting functions
% new version of draw_net
function handle = draw_net(I,H,O,ih,ho)
    handle = figure; hold on, % axis equal
    axis off
    set(gcf, 'color', [1,1,1]); % white background
    
    handle = draw_weight_lines(handle, ih, ho);
    
    [ip_x, hp_x, op_x] = get_x_positions();
    [ip_y, hp_y, op_y] = get_y_positions([size(ih'), size(ho,1)]);
    
    handle = draw_neuron_circles(handle, ip_x, ip_y, I);
    handle = draw_neuron_circles(handle, hp_x, hp_y, H);
    handle = draw_neuron_circles(handle, op_x, op_y, O);
    
    % TODO: rewrite legend-stuff
end

% new version of draw_weight_lines
function handle = draw_weight_lines(h,H,O)
%     set(groot, 'CurrentFigure', h); % does not work on R2013b, why?
    [y_in, y_hid, y_out] = get_y_positions([size(H'), size(O)]);
    [x_in, x_hid, x_out] = get_x_positions();
    
    % draw lines from input to hidden
    for i=1:size(H,2)
        for j=1:size(H,1)
            line([x_in, x_hid],[y_in(i), y_hid(j)], 'Color', H{j,i});
        end
    end
    % draw lines from hidden to output
    for i=1:size(O,1)
        for j=1:size(O,2)
            line([x_hid,x_out], [y_hid(j), y_out(i)], 'Color', O{i,j});
        end
    end
    
    handle = h; % does this work?
end

% draw neuron circles
function handle = draw_neuron_circles(h, x, y, colors)
    %     set(groot, 'CurrentFigure', h); % does not work on R2013b, why?
    radius = .8;
    for i=1:length(y)
        circles(x, y(i), radius, 'facecolor', colors{i});
    end
%     circles(x,y,radius,'facecolor', 'none');
    % TODO: coloring
    handle = h;
end

% draw legend for understanding the meaning of the colors
function handle = draw_legend(h, w_min, w_max)
%     set(groot, 'CurrentFigure', h); % does not work on R2013b, why?
    colmap = colormap(get_colormap(51));
    caxis([w_min, w_max]);
    c = colorbar;
    c.Label.String = 'Absolute value of weight'; % doesnot work in R2013b

    handle = h; % works?
end

%% helper stuff
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

% get the linecolors for every line (returns a NxM cell-array with a 1x3 rgb color
% for every matrix entry
% NOTE: at the moment only greyscale of absvalue of weight
function linecols = get_line_colors(M, w_max, w_min)
    abs_max = max([abs(w_max), abs(w_min)]);
    linecols = cell(size(M)); % preallocate
    colmap = get_colormap(51); % WARNING: the value of 51 is also used in other places!
    col_int = linspace(0,abs_max,51); % define an intervall for each color
%     col_int = linspace(log(1e-1),log(abs_max),51); % define logarithmic scale
    for i=1:size(M,1)
        for j=1:size(M,2)
            col = find(col_int <= abs(M(i,j)));
%             col = find(col_int <= log(abs(M(i,j))));
%             if isempty(col), col = 1; end % safety measure
            linecols{i,j} = colmap(col(end),:); % TODO
        end
    end
end

% calculate the values the neurons have. options: input -> input value,
% activation -> activation-function value corresponding to input (= neuron
% output)
function [HV, OV] = calc_neuron_vals(IN,H,O,option)
    
    HV = [];
    OV = [];
end

% determine the colors of the neuron circles
function circlecols = get_circle_colors(V, v_max, v_min)
    circlecols = cell(size(V));
    circlecols(:) = {'none'}; % assign no color to cells, for now
%     circlecols = {}; % return empty at the moment
end

% define colormap for this function
% COULDDO: make this take options (e.g. greyscale, etc.)
function colmap = get_colormap(steps)
    x = linspace(1,0,steps); % for greyscale
    colmap = [x', x', x']; % greyscal color map
end