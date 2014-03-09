function [ data ] = clamp( data,maxv , minv  )
% [ data ] = clamp( data,maxv , minv  )
if nargin < 1
     error('invalid');
elseif nargin <3
    %warning('set maxv=1,minv=0');
    maxv=1;
    minv=0;
end

data(data>maxv)=maxv;
data(data<minv)=minv;

end

