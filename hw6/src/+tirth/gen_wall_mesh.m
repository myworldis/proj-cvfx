function [ output_args ] = gen_wall_mesh( wallpts , objName , fout )

if nargin <2
    error();
elseif nargin ==2
    fout=[];
end

 

faceName = sprintf('%s',objName);

fprintf('%s_mesh=[\n',faceName);

for iv=1:4
    vex = wallpts( iv ,:);       
    vstr=strjoin(strsplit(mat2str(vex(:)),';'),',');

    fprintf('%s,\n',vstr);
end
fprintf(']\n');    



fprintf('mData={''points3'':%s_mesh }\n',faceName);
fprintf('mNode = createSceneNode(root=root,scene=scene , name=''%s_node'' )\n',faceName);
fprintf('createMesh_notex(meshNode=mNode , name=''%s_'' , meshData=mData  )\n',faceName);

fprintf('\n');  
     

end

% 
% m1=[
%     [9.02178,17.270399,27.8484],
%     [8.36302,21.6996,27.292801],
%     [0.284635,22.317101,34.748901],
%     [0.772702,19.058701,35.4888]
% ];
% 
% m1MData={'points3':m1}
% m1Node = createSceneNode(root=root,scene=scene , name='m1' )
% createMesh_notex(meshNode=m1Node , name='_m1' , meshData=m1MData  )
