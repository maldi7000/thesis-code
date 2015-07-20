function [x] = datfile_readin(filename, format, varargin)
%DATFILE_READIN read in .dat file that contains numeric values
%
% [X] = datfile_readin(FILENAME, FORMAT, CONCAT) takes a filename FILENAME and a
% format specifier (c format specifiers) FORMAT. Both arguments have to be
% passed as strings. It returns a NxM matrix X, where N is the number of
% columns in the .dat file and M is the number of lines in the .dat file.
% The FILENAME can contain wildcards such that all files fitting the
% wildcard will be loaded. If all data from the read in files shall be
% concatenated set CONCAT to true (defaults to true). If CONCAT is set to
% false the function returns a cell-array of NxM matrices.
%
% NOTE: for the function to work properly the .dat file must not contain
% any non numeric values and all lines of the .dat file must contain the
% same number of values and also the format of the values has to be
% constant over the file
%
% COULDDO: make this function more variable (i.e. allow comments in .dat
% file, make more checks before reading, automatic format detection,
% etc...)

% by Thomas Madlener, 2015

% check number of input arguments
if nargin < 2
    error('You must provide at least 2 arguments: filename and format!')
end
if size(varargin) > 1
    warning('Function takes only 3 arguments at the moment! Ignoring all but the first')
elseif isempty(varargin)
    concat = true;
else
    validateattributes(varargin{1}, {'logical'},{'nonnan'}, 'datfile_readin', 'concat');
    concat = varargin{1};
end

% check if both arguments are strings
validateattributes(filename, {'char'}, {'nonempty'}, 'datfile_readin', 'concat');
validateattributes(format, {'char'}, {'nonempty'}, 'datfile_readin', 'format');

% determine the size (i.e. number of values per line from the format
% specifier
sizeI = [size(strsplit(format),2), Inf];

files=dir(filename); % expand wildcard and get all files
if isempty(files)
    error('Found no file matching: %s', filename)
end
if length(files) == 1 % if there is only one file do not put the values into a cell
    concat = true;
end

% handle the directory name. the structs returned by do not have
% information on the path!
directories = strsplit(filename,'/'); % split full (relative) name at /
dirname = strjoin(directories(1:end-1), '/'); % join all but the last part (i.e. the filename) together again with '/' as delimiter
if ~isempty(dirname), dirname = [dirname, '/']; end % add '/' after last directory name (as delimiter to the filename) only if necessary

if ~concat
    x = cell(size(files)); % pre allocate cell
else
    x = []; % variable size here -> no pre allocation
end

for i=1:length(files)
    fname = [dirname, files(i).name];
    fId = fopen(fname, 'r');
    if fId < 0
        error('Couldnot open file: %s', fname)
    else
        fprintf('Opened file: %s\n', fname)
    end

    % perform read in
    tmp = fscanf(fId, format, sizeI);
    if ~concat
        x{i} = tmp;
    else
        x = [x, tmp];
    end
end
