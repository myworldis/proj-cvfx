function [ hmat ] = estimate_tx( pts1 , pts2  )
% Tx 1 to 2
% 
%  Tx frame 1 to frame 2
%  

%[tform, pointsBm, pointsAm] = estimateGeometricTransform(...
%    pts2, pts1, 'projective');


[tform, ~, ~] = estimateGeometricTransform(...
        pts1, pts2, 'affine');
 
    
hmat=tform.T';
%hmat=tform.T;

%hmat = cv.findHomography(pts1, pts2,'Method','Ransac'); 

%hmat = cv.estimateRigidTransform(pts1, pts2 ,'FullAffine',0); 

end

