function [ data ] = normalize( data )


maxval=data;
for k=1:ndims(data)
    maxval=(max(maxval));
end

data=data./maxval;

end

