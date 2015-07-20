function [Z,U,D] = decorrelate(X, U, D, varargin)
%DECORRELATE perform decorrelation on given data
%
% [Z,U,D] = decorrelate(X, U, D, normalize) takes NxM data matrix X and returns decorrelated NxM 
% data matrix Z, where N is the number of observations and M is the
% dimension of one variable. If passed two MxM matrices U and D the transformation
% specified by these two matrices is performed on the input data. (U and D
% have to come from an eigendecomposition to give usable results!)
% If normalize is true (default is true) the
% returned data will be normalized such that the covariance matrix is the
% unity matrix.
% returns the eigendecomposition of the covariance matrix of X as well if
% desired: cov(X) = U*D*U' (cov(X) is symmetric)

% by Thomas Madlener, 2015

% TODO: input check of X
if ~isempty(varargin)
    validateattributes(varargin{1}, {'logical'}, {'nonnan'}, 'decorrelate', 'normalize');
    normalize = varargin{1};
else
    normalize = true;
end

if (nargin ~= 1 && nargin ~= 3) && (~isempty(varargin) && nargin ~= 4)
    error('wrong number of input arguments')
end

calc_trans = false;
if nargin ~= 3, calc_trans = true; end
if nargin == 3
    if isempty(U) || isempty(D)
%         warning('one of the passed transformation matrices is empty. Calculating them from input data')
        calc_trans = true;
    end
    if size(X,2) ~= size(U,1) || size(X,2) ~= size(D,1)
        warning('one of the passed transformation matrices has the wrong dimensions. Calculating them from input data')
        calc_trans = true;
    end
    if size(U) ~= size(D)
        warning('transformation matrices do not have the same size. Calculating them from input data')
        calc_trans = true;
    end
    if any(size(U) ~= size(U')) || any(size(D) ~= size(D'))
        warning('one of the transformation matrices is not a square matrix. Calculating them from input data')
        calc_trans = true;
    end
end
if calc_trans % calculate transformation matrices from data
    % calculate covariance matrix estimate
    % [n, m] = size(X);
    % ybar = 1/n*sum(X); % calculate the mean vector
    % C = 1/n * (X')* X - ybar'*ybar;
    
    % using MATLAB built-in to calculate the empirical covariance matrix
    % NOTE: this is the same calculation as above! (only prefactor 1/n is
    % 1/(n-1) for cov
    C = cov(X);
    
    % do eigen decomposition of covariance matrix
    [U,D] = eig(C);
end

Z = X * U;
% normalized output (i.e. cov(Z) = identity)
if normalize
    Z = Z/sqrt(D);
end

end
