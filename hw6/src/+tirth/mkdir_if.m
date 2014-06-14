function [] = mkdir_if( dirpath )
% 

if ~exist(dirpath,'dir') && ~isempty(dirpath)
   mkdir(dirpath); 
end


end

