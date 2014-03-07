function [ nora ] = normalize( a )
 


if ~isa(a,'double')
    a=double(a);
end


nora = a;

for k=1:size(a,3)

    maxval = max2(a(:,:,k)) ;
    minval  =min2(a(:,:,k)) ;

    range = maxval - minval;
    nora(:,:,k) = ( a(:,:,k) - minval ) ./ range;
end


end

