function [ output_args ] = analyze_weights(net)
%ANALYZE_WEIGHTS analyzes the weight of a neural network
%
% analyze_weights(NET) takes as input a neural network (at the moment only
% a feedforward network with one hidden layer) and analyzes its weights and
% its relations between different neurons
%
% TODO: implement
% TODO: documentation finish

% by Thomas Madlener, 2015

%% input checks and handling
if ~isa(net, 'network'), error('input needs to be a network'), end
if length(net.layers) > 2, error('can only handle networks with one hidden layer at the moment'), end
% TODO: more checks?

%% main function body
W_ih = net.IW{1}; % get weigh matrix of input layer - hidden layer
W_ho = net.LW{2,1}; % get weight matrix of hidden layer - output layer
[hidsize, insize] = size(W_ih);
outsize = size(W_ho,1);

hidkeys = cell(insize,1);
for i=1:insize, hidkeys{i} = sprintf('input %d', i); end
W_ih_vec = reshape(W_ih,[],1); % reshape to (column) vector
% hist(W_ih, 50); % make histogram split by inputs
% hold on
% hist(W_ih_vec,50);
% legend(hidkeys, 'Location', 'Best');

% figure;
% hist(W_ho, 50);

draw_net(W_ih, W_ho);
end

%% helper stuff
function handle = draw_net(H,O) % H -> input - hidden, O -> hidden - output
    handle = figure; hold on, % axis equal
    axis off
    set(gcf, 'color', [1,1,1]); % white background
    
    sizes = [size(H'), size(O,1)]; % sizes: input, hidden, output
    maxsize = max(sizes); maxind = find(sizes == maxsize);
    
    [inpos_x, hidpos_x, outpos_x] = get_x_positions();
    radius = .8;
    [inpos_y, hidpos_y, outpos_y] = get_y_positions(sizes);
    
    max_w = max([max(H), max(O)]); % determine max and min weight
    min_w = min([min(H), min(O)]);
    
    i_h_cols = get_line_colors(H, max_w, min_w);
    h_o_cols = get_line_colors(O, max_w, min_w);
    
    % draw lines first -> circles are above lines then later
    handle = draw_weight_lines(handle, H, i_h_cols, O, h_o_cols);
    % for now do not color the neurons (might come later)
    circles(inpos_x,inpos_y, radius, 'facecolor', 'none');
    circles(hidpos_x,hidpos_y, radius, 'facecolor', 'none');
    circles(outpos_x,outpos_y, radius, 'facecolor', 'none');
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
    
    in_y = (-ymax(1):ymax(1)) * s * maxsize/sizes(1);
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
    colmap = get_colormap(51);
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

% draw the weight lines onto the figure
% h is the figure handle
% H_cols and O_cols define the colors of the lines (still to decide how to
% handle that the easiest way
function handle = draw_weight_lines(h, H, H_cols, O, O_cols)
    set(groot, 'CurrentFigure', h);
    [y_in, y_hid, y_out] = get_y_positions([size(H'), size(O)]);
    [x_in, x_hid, x_out] = get_x_positions();
    
    % draw lines from input to hidden
    for i=1:size(H,2)
        for j=1:size(H,1)
            line([x_in, x_hid],[y_in(i), y_hid(j)], 'Color', H_cols{j,i})
        end
    end
    
    % draw lines from hidden to output
    for i=1:size(O,1)
        for j=1:size(O,2)
            line([x_hid,x_out], [y_hid(j), y_out(i)], 'Color', O_cols{i,j});
        end
    end
    
    handle = h; % does this work?
end

% define colormap for this function
% COULDDO: make this take options (e.g. greyscale, etc.)
function colmap = get_colormap(steps)
    x = linspace(1,0,steps); % for greyscale
    colmap = [x', x', x']; % greyscal color map
end