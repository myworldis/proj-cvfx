function [ nnGraph ] = make4x4NN( img  )
% get 4-by-4 connected NN graph 

if nargin < 1
    error('invalid');
end

FG_H =size(img,1);
FG_W =size(img,2);

fprintf(' W= %d , H=%d \n',FG_W,FG_H);
% setup NN graph

UNK_NUM=(FG_H)*(FG_W);

I_2d=zeros(FG_H,FG_W);

% ignore border pixels
I_2d(2:end-1,2:end-1)=1;

I = sparse( diag(I_2d(:)) );

shift_h = FG_H;

nnGraph= (I); 
nnGraph= nnGraph+circshift(I,[0,shift_h])+circshift(I,[0,-shift_h]); % X NN
nnGraph= nnGraph+circshift(I,[0,1])+circshift(I,[0,-1]); % Y NN
% remove self
nnGraph(I>0)=0;
 
 

end

