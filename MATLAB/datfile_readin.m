function [x] = datfile_readin(filename, format, varargin)
%DATFILE_READIN read in .dat file that contains numeric values
%
% [X] = datfile_readin(FILENAME, FORMAT) takes a filename FILENAME and a
% format specifier (c format specifiers) FORMAT. Both arguments have to be
% passed as strings. It returns a NxM matrix X, where N is the number of
% columns in the .dat file and M is the number of lines in the .dat file.
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
if ~isempty(varargin)
    warning('Function takes only 2 arguments at the moment! Ignoring all but the first')
end
% check if both arguments are strings
if ~ischar(filename) || ~ischar(format)
    error('Both arguments must be strings!')
end

fId = fopen(filename, 'r');
if fId < 0
    error('Couldnot find file: %s', filename)
else
    fprintf('Opened file: %s\n', filename)
end

% determine the size (i.e. number of values per line from the format
% specifier
sizeI = [size(strsplit(format),2) Inf];

% perform read in
x = fscanf(fId, format, sizeI);