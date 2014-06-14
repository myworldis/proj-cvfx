function tform = match_sift(im1, im2)

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
% Each column of F is a feature frame and has the format [X;Y;S;TH],
%   where X,Y is the (fractional) center of the frame, 
%   S is the scale and
%   TH is the orientation (in radians).
 

% 128 x N_features
[f1,d1] = vl_sift(im1g) ;
[f2,d2] = vl_sift(im2g) ;

[D,IDX]=bwdist(d1,d2);

[matches, scores] = vl_ubcmatch(d1,d2) ;

numMatches = size(matches,2) ;

X1 = f1(1:2,matches(1,:)) ; 
X1(3,:) = 1 ;
 
X2 = f2(1:2,matches(2,:)) ; 
X2(3,:) = 1 ;

% --------------------------------------------------------------------

pointsA = f1(1:2,matches(1,:))' ; 
pointsB =f2(1:2,matches(2,:))'; 


if 0 
    fimshow(im1g)
    plot(pointsA(:,1),pointsA(:,2),'x','markersize',13,'color','r','linewidth',2);

    fimshow(im2g)
    plot(pointsB(:,1),pointsB(:,2),'x','markersize',13,'color','r','linewidth',2);
end


[tform, pointsBm, pointsAm] = estimateGeometricTransform(...
    pointsB, pointsA, 'affine');

% [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
%    pointsB, pointsA,  'projective');


end