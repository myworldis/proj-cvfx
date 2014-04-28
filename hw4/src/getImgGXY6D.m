function [ allgxy ] = getImgGXY6D( img )


if nargin < 1
    error('invalid');
end

assert(ndims(img)>=2,'invalid image');

% 6D gradient
 
allgxy=[];
for k=1:ndims(img)
    [gx,gy]=imgradientxy(img(:,:,k));
    gxy=cat(3,gx,gy);
    
    allgxy=cat(3,allgxy,gxy);
end


end

