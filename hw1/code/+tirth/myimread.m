function [ r,m,a ] = myimread( varargin )

[r,m,a]=imread(varargin{:});

r=double(r)./255;
a=double(a)./255;

end

