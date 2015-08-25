function [out_args] = plot_corr_matrix(CX, titlestr)
%PLOT_CORR_MATRIX plots the correlation matrix colorized
%
% plot_corr_matrix(CX, title) plots the correlation matrix CX and
% an optional title
colormap jet
imagesc(CX);
caxis([-1 1]);
colorbar
if nargin == 2, title(titlestr), end
for i=1:size(CX,1)
    for j=1:size(CX,2)
        if(abs(CX(i,j)) > 1e-2)
            col = 'k';
            if(abs(CX(i,j)) > 0.7), col = 'w'; end
            text(i-0.2,j,num2str(CX(i,j), '%.2f'), 'Color', col);
        end
    end
end
end
