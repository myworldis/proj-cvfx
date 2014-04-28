

cd('D:\nthu_school\CVFX\proj-cvfx\hw4\src');

addpath('../lib/GCMex');

dataPath = '../data/';
 
fg = imread( fullfile( dataPath , 'res_inp.jpg') );
 

fimshow(fg);

%%

% ignore border pixels
nnG = make4x4NN( fg );


% setup Data cost
% bg,fg

NUM_OF_UNK = size(fg,1)*size(fg,2); 
NUM_OF_LABEL = 256;

FG_LID=1;
BG_LID=2;


fg_mask1d = fg_mask(:);

LARGE_PENALTY=1;

dataCost = ones( NUM_OF_UNK, NUM_OF_LABEL );

% 
% E( FG ) = BG

for k=1:NUM_OF_LABEL
    dataCost( :,k)=  ( double(fg(:)) - (k-1) ).^2 ;
end

dataCost=dataCost*0.5;

%% setup Pairwised cost
 
% fg_gxy6d = getImgGXY6D(fg);
%  
% bg_1d = double(reshape(bg,[],3));

fg_1d = double(fg(:));

pairCost = zeros(size(fg,1),size(fg,2));

[uu,vv]=find(nnG);        

weiNNG = nnG;

for i=1:numel(uu)
    
    pIdx = uu(i);
    qIdx = vv(i);
    
    xi = ( fg_1d(pIdx,:)- fg_1d(qIdx,:) ).^2*10 ; 
    weiNNG(pIdx,qIdx)=xi; 
end
 
disp('done');
 

%% 

% mmat = zeros(NUM_OF_LABEL,NUM_OF_LABEL);
% 
% for i=1:size(mmat,1)
%     for j=1:size(mmat,2)
%         if j>=i
%            mmat(i,j) = j-i;
%         else
%             mmat(i,j) = 0;
%         end
%     end
% end
% 
% mmat= mmat+mmat';

mmat = ones(NUM_OF_LABEL,NUM_OF_LABEL);

lambda=2331;

mmat(eye(NUM_OF_LABEL)>0)=0;

mmat = mmat * lambda;

%%
% >> h = GCO_Create(4,3);             % Create new object with NumSites=4, NumLabels=3
%      >> GCO_SetDataCost(h,[0 9 2 0;      % Sites 1,4 prefer  label 1
%                            3 0 3 3;      % Site  2   prefers label 2 (strongly)
%                            5 9 0 5;]);   % Site  3   prefers label 3

%      >> GCO_SetSmoothCost(h,[0 1 2;      % 
%                              1 0 1;      % Linear (Total Variation) pairwise cost
%                              2 1 0;]);   % 

%      >> GCO_SetNeighbors(h,[0 1 0 0;     % Sites 1 and 2 connected with weight 1
%                             0 0 1 0;     % Sites 2 and 3 connected with weight 1
%                             0 0 0 2;     % Sites 3 and 4 connected with weight 2
%                             0 0 0 0;]);
%      >> GCO_Expansion(h);                % Compute optimal labeling via alpha-expansion 
%      >> GCO_GetLabeling(h)


%   Handle = GCO_Create(NumSites,NumLabels)
h = GCO_Create(NUM_OF_UNK,NUM_OF_LABEL); 

%  NumLabels-by-NumSites 
GCO_SetDataCost(h, (dataCost)' );


GCO_SetSmoothCost(h, mmat );

GCO_SetNeighbors(h,  (nnG) );

GCO_Expansion(h);   

ll = GCO_GetLabeling(h);

disp( unique(ll) )

%%

ll2d=reshape(ll-1, size(fg));

ll2d = double(ll2d)/255;
  
figure;
imagesc(fg);colormap(gray)
figure;
imagesc((ll2d));colormap(gray)





















