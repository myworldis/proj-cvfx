function F = my_poisson( foreground, background, mask )
%  foreground, background, mask
%  

if nargin < 3
    error('invalid');
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
F(:,:,1) = poisson_gray( background(:,:,1), foreground(:,:,1), mask );
F(:,:,2) = poisson_gray( background(:,:,2), foreground(:,:,2), mask );
F(:,:,3) = poisson_gray( background(:,:,3), foreground(:,:,3), mask );

toc(ts);
end

function F = poisson_gray( background, foreground, mask )

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
resFB( ch_flag ) = lapBK(ch_flag);

%resFB = lapforeground;

b(fx) = resFB(fx);
% Solve Linear System Ax = b
x = A\b;
F = reshape(x,[h w]);

end

function img = imcheck(img)

if max(max(img)) > 1 
   img = double(img)/255.0;
end
    


end

