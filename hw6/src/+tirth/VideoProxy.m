classdef VideoProxy < handle


    properties( Access=public )
       
        video_file 
        
        dynamic
    end
    
    methods
        
        function obj=VideoProxy()
            obj.video_file=[];
            obj.dynamic=struct;
        end
        
        function load(obj,fpath)
           
            if ~exist(fpath,'file')
                error(sprintf('File not existed [%s]\n',fullfile(pwd,fpath)));
            end
            
            obj.video_file = VideoReader(fpath); 
        end
         
        
        function [vWidth]=width(obj)
            
            if ~isempty(obj.video_file)
               
               vWidth = video_file.Width;
               vHeight = vin.Height;
               
            end            
        end
        
         
        function [f]=getFrame(obj,k)
            
            if ~isempty(obj.video_file)
                
               if obj.video_file.NumberOfFrames >= k
                   f = uint8(read(obj.video_file, k)); 
               else
                   error('invalid frame id');
               end
            else
                fprintf('file is not initialized\n');
                f=[];
            end
            
        end
        function [num]=totalFrame(obj)
            if ~isempty(obj.video_file)
                num = obj.video_file.NumberOfFrames;
            else
                num=0;
            end
        end
        function delete(obj)
            
            if ~isempty(obj.video_file)  
            end
            
        end
    
    end

end