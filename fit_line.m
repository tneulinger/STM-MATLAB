function [flat_topography, M] = fit_line(topography)
% FIT_LINE Subtract best fit lines from horizontal of a topography
%
% [flat_topography, M] = FIT_LINE(topography)
%
% The 'topography' input is an nx by ny matrix.
% The 'flat_topography' returned is an nx by by matrix with best fit lines
% subtracted from the horizontal (along ny). 
% The 'M' matrix returned is a 2 by nx matrix, containing the best fit
% slope in the first row and the best fit y-intercept in the second row,
% where the jth column of 'M' corresponds to the jth row of 'topography'.
%
% Example:
% [~, mapStructure] = load3ds_map('test.3ds');
% topo = mapStructure.R(:,:,3);
% [flat_topo, M] = fit_line(topo);
% subplot(1,2,1); imagesc(topo);
% subplot(1,2,2); imagesc(flat_topo);

[nx,ny] = size(topography);         % get size of topography

M = zeros(2,nx);                    % matrix to hold fit values [m;b]
flat_topography = zeros(nx,ny);     % matrix to hold flat topography

% subtract best fit line from horizontal 
for k = 1:nx                        % loop over rows
    X = [ones(ny,1), (1:ny)'];      % construct X
    Y = topography(k,:)';           % construct Y
    M(:,k) = X\Y;                   % fit (c.f. MATLAB backslash)
    flat_topography(k,:) = ...      % update flat topography
        topography(k,:) - (X*M(:,k))';
end

end