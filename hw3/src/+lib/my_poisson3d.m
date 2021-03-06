function F = my_poisson3d( foreground, background, mask , presol )
%  foreground, background, mask
%  

if nargin < 3
    error('invalid');
elseif nargin==3
    F=[];
    fprintf('diable frame blending');
end

if ndims(mask)==3
    warning(' input mask is 3d image. truncate to r channel');
    mask=mask(:,:,1);
end

foreground=imcheck(foreground);
background=imcheck(background);
mask=imcheck(mask);

fprintf('start');

ts=tic;
F = zeros(size(background));
F(:,:,1) = poisson_gray( background(:,:,1), foreground(:,:,1), mask ,presol);
F(:,:,2) = poisson_gray( background(:,:,2), foreground(:,:,2), mask ,presol);
F(:,:,3) = poisson_gray( background(:,:,3), foreground(:,:,3), mask ,presol);

toc(ts);
end

function F = poisson_gray( background, foreground, mask , presol )

[h,w] = size(foreground);

n = w*h;

%A = sparse(n,n);

f = zeros(n,1);         %% Uknown Vector 
fx = find(mask > 0);    %% Unknown Position (target region)
bx = find(mask == 0);   %% Known Position (BK)

q = zeros(n,1);  
q(fx) = 1;              % target region 


% Build Laplace Matrix
% 
% 4-connected element
% 
I = diag(sparse(q));
A = -4*I;
A = A+circshift(I,[0 h])+circshift(I,[0 -h]); % X Comp
A = A+circshift(I,[0 1])+circshift(I,[0 -1]); % Y Comp
A = A+speye(n)-I; % setup constriant 
b = zeros(n,1);   % 
b(bx) = background(bx); % fill constriant with BK(im2)

% Compute Laplace Foreground
lapFG = circshift(foreground,[1 0])+circshift(foreground,[-1 0]);
lapFG = lapFG+circshift(foreground,[0 1])+circshift(foreground,[0 -1]);
lapFG = lapFG-4*foreground;

lapBK = circshift(background,[1 0])+circshift(background,[-1 0]);
lapBK = lapBK+circshift(background,[0 1])+circshift(background,[0 -1]);
lapBK = lapBK-4*background;

gFor = imgradient(foreground);
gBK = imgradient(background);

resFB = lapFG;
ch_flag= abs(lapFG) < abs(lapBK) ; 
ch_flag= abs(gFor) < abs(gBK) ; 
resFB( ch_flag ) = lapBK(ch_flag);

%resFB = (lapBK+lapFG)/2;

%resFB = lapforeground;

b(fx) = resFB(fx);

if isempty(presol)
    % Solve Linear System Ax = b
    x = A\b;
    F = reshape(x,[h w]);
else
    num_fg=length(fx);
    presol_fg = presol(fx);
    
    b(end+1:end+num_fg)=presol_fg(:);
    
    effIdx = find(sum(I,2));
    
    cp_q = q;
    cp_q(effIdx)=1;
    
    ii=sparse(1:length(effIdx),effIdx,ones(length(effIdx),1),length(effIdx),size(A,2));
    A2=cat(1,A,ii);
    x = A2\b;
    F = reshape(x,[h w]);
    
end

end

function img = imcheck(img)

if max(max(img)) > 1 
   img = double(img)/255.0;
end
    


end

