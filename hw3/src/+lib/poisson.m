function F = poisson( foreground, background, mask )

%background = imr(background_name);
%foreground = imr(foreground_name);
%mask = imr(mask_name);

if nargin < 3
    error('invalid');
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

A = sparse(n,n);
f = zeros(n,1); %% Uknown Vector
fx = find(mask > 0);  %% Unknown Position
bx = find(mask == 0);  %% Known Position
q = zeros(n,1);
q(fx) = 1;
% Build Laplace Matrix

I = diag(sparse(q));
A = -4*I;
A = A+circshift(I,[0 h])+circshift(I,[0 -h]); % X Comp
A = A+circshift(I,[0 1])+circshift(I,[0 -1]); % Y Comp
A = A+speye(n)-I;
b = zeros(n,1);
b(bx) = background(bx);

% Compute Laplace Foreground
lapforeground = circshift(foreground,[1 0])+circshift(foreground,[-1 0]);
lapforeground = lapforeground+circshift(foreground,[0 1])+circshift(foreground,[0 -1]);
lapforeground = lapforeground-4*foreground;
b(fx) = lapforeground(fx);

% Solve Linear System Ax = b
x = A\b;
F = reshape(x,[h w]);

end

function img = imcheck(img)

if max(max(img)) > 1 
   img = double(img)/255.0;
end
    


end

