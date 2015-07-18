function [Z,U,D] = decorrelate(X, varargin)
%DECORRELATE perform decorrelation on given data
%
% [Z,U,D] = decorrelate(X, normalize) takes NxM data matrix X and returns decorrelated NxM 
% data matrix Z, where N is the number of observations and M is the
% dimension of one variable. If normalize is true (default is true) the
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

Z = X * U;
% normalized output (i.e. cov(Z) = identity)
if normalize
    Z = Z/sqrt(D);
end

end
