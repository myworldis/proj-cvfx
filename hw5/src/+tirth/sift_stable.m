function stable = sift_stable(im1, im2)
% SIFT_MOSAIC Demonstrates matching two images using SIFT and RANSAC
%
%   SIFT_MOSAIC demonstrates matching two images based on SIFT
%   features and RANSAC and computing their mosaic.
%
%   SIFT_MOSAIC by itself runs the algorithm on two standard test
%   images. Use SIFT_MOSAIC(IM1,IM2) to compute the mosaic of two
%   custom images IM1 and IM2.

% AUTORIGHTS

if nargin == 0
  im1 = imread(fullfile(vl_root, 'data', 'river1.jpg')) ;
  im2 = imread(fullfile(vl_root, 'data', 'river2.jpg')) ;
end

% make single
im1 = im2single(im1) ;
im2 = im2single(im2) ;

% make grayscale
if size(im1,3) > 1, im1g = rgb2gray(im1) ; else im1g = im1 ; end
if size(im2,3) > 1, im2g = rgb2gray(im2) ; else im2g = im2 ; end

% --------------------------------------------------------------------
%                                                         SIFT matches
% --------------------------------------------------------------------

[f1,d1] = vl_sift(im1g) ;
[f2,d2] = vl_sift(im2g) ;

[matches, scores] = vl_ubcmatch(d1,d2) ;

numMatches = size(matches,2) ;

X1 = f1(1:2,matches(1,:)) ; X1(3,:) = 1 ;
X2 = f2(1:2,matches(2,:)) ; X2(3,:) = 1 ;
% X1 = (X1 + X2)./2 ;   

% --------------------------------------------------------------------
%                                         RANSAC with homography model
% --------------------------------------------------------------------

clear H score ok ;
for t = 1:100
  % estimate homograpyh
  subset = vl_colsubset(1:numMatches, 4) ;
  A = [] ;
  for i = subset
%     A = cat(1, A, kron(X1(:,i)', vl_hat(X2(:,i)))) ;
%     A = cat(1, A, [X1(1,i) X1(2,i) 0 0 1 0 (-X2(1,i)-X1(1,i))/2; 0 0 X1(1,i) X1(2,i) 0 1 (-X2(2,i)-X1(2,i))/2 ] ) ;
    A = cat(1, A, [X1(1,i) X1(2,i) 0 0 1 0 -X2(1,i); 0 0 X1(1,i) X1(2,i) 0 1 -X2(2,i) ] ) ;
  end
%   [U,S,V] = svd(A) ;
%   H{t} = reshape(V(:,9),3,3) ;
  [V, D] = eig(A' * A);
  [~, minIndex] = min( diag(D) );
  V = V./V(7);    % The last element must be one.
  h = V(:,minIndex);
  rotate{t} = [h(1:2)'; h(3:4)'];
  translate{t} = [h(5) h(6)]';

  % score homography
%   X2_ = H{t} * X1 ;
%   du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
%   dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
%   ok{t} = (du.*du + dv.*dv) < 6*6 ;
%   score(t) = sum(ok{t}) ;
  X2_(1,:) = rotate{t}(1,:) * X1(1:2,:) + translate{t}(1);
  X2_(2,:) = rotate{t}(2,:) * X1(1:2,:) + translate{t}(2);
  X2_(3,:) = 1 ;
  du = X2_(1,:)./X2_(3,:) - X2(1,:)./X2(3,:) ;
  dv = X2_(2,:)./X2_(3,:) - X2(2,:)./X2(3,:) ;
  ok{t} = (du.*du + dv.*dv) < 6*6 ;
  score(t) = sum(ok{t}) ;
end

[score, best] = max(score) ;
% H = H{best} ;
rotate = rotate{best};
translate = translate{best};
ok = ok{best} ;

% --------------------------------------------------------------------
%                                                  Optional refinement
% --------------------------------------------------------------------

% function err = residual(H)
%  u = H(1) * X1(1,ok) + H(4) * X1(2,ok) + H(7) ;
%  v = H(2) * X1(1,ok) + H(5) * X1(2,ok) + H(8) ;
%  d = H(3) * X1(1,ok) + H(6) * X1(2,ok) + 1 ;
%  du = X2(1,ok) - u ./ d ;
%  dv = X2(2,ok) - v ./ d ;
%  err = sum(du.*du + dv.*dv) ;
% end
% 
% if exist('fminsearch') == 2
%   H = H / H(3,3) ;
%   opts = optimset('Display', 'none', 'TolFun', 1e-8, 'TolX', 1e-8) ;
%   H(1:8) = fminsearch(@residual, H(1:8)', opts) ;
% else
%   warning('Refinement disabled as fminsearch was not found.') ;
% end

% --------------------------------------------------------------------
%                                                         Show matches
% --------------------------------------------------------------------

% dh1 = max(size(im2,1)-size(im1,1),0) ;
% dh2 = max(size(im1,1)-size(im2,1),0) ;
% 
% figure(1) ; clf ;
% subplot(2,1,1) ;
% imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
% o = size(im1,2) ;
% line([f1(1,matches(1,:));f2(1,matches(2,:))+o], ...
%      [f1(2,matches(1,:));f2(2,matches(2,:))]) ;
% title(sprintf('%d tentative matches', numMatches)) ;
% axis image off ;
% 
% subplot(2,1,2) ;
% imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
% o = size(im1,2) ;
% line([f1(1,matches(1,ok));f2(1,matches(2,ok))+o], ...
%      [f1(2,matches(1,ok));f2(2,matches(2,ok))]) ;
% title(sprintf('%d (%.2f%%) inliner matches out of %d', ...
%               sum(ok), ...
%               100*sum(ok)/numMatches, ...
%               numMatches)) ;
% axis image off ;
% 
% drawnow ;

% --------------------------------------------------------------------
%                                                               Mosaic
% --------------------------------------------------------------------
[M, N, K] = size(im1);
stable = zeros(M, N, K);
% rotate
% translate
% Compute theta from mean of two possible arctangents
theta = mean([atan2(rotate(2),rotate(1)) atan2(-rotate(3),rotate(4))]);
% Compute scale from mean of two stable mean calculations
scale = mean(rotate([1 4])/cos(theta));
for i=1:M
    for j=1:N
        
        tmp(1) = scale * [cos(theta) sin(theta)] * [j i]' + translate(1);
        tmp(2) = scale * [-sin(theta) cos(theta)] * [j i]' + translate(2);
        tmp(3) = 1;
        
        x = round(tmp(1) / tmp(3));
        y = round(tmp(2) / tmp(3));
        
        if x<1 || y<1 || x>N || y>M
            continue;
        else
            stable(i, j, :) = im2(y, x, :);
        end
        
    end
end
% mass = ~isnan(im1) + ~isnan(stable) ;
% stable(isnan(stable)) = 0 ;
% im1(isnan(im1)) = 0 ;
% stable = (stable + im1) ./ mass ;

figure(2) ; clf ; 
imagesc(stable) ; axis image off ;
title('stable') ;

if nargout == 0, clear stable ; end

end