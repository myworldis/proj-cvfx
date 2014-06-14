function [   ] = printM( mat )
 

for k=1:size(mat,1)   
   if k~=size(mat,1)
       fprintf('%s,\n',strjoin(strsplit(mat2str(mat(k,:))),',')); 
   else
       fprintf('%s\n',strjoin(strsplit(mat2str(mat(k,:))),',')); 
   end
end
end

