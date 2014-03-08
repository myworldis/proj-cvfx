function [ data ] = clamp( data,maxv , minv  )
% [ data ] = clamp( data,maxv , minv  )
if nargin < 3
     error('invalid');
end

data(data>maxv)=maxv;
data(data<minv)=minv;

end

