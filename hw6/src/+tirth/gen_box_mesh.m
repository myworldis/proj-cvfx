function [ output_args ] = gen_box_mesh( obb3d , objName , fout )

if nargin <2
    error();
elseif nargin ==2
    fout=[];
end

box_face=[
1,2,3,4
5,6,7,8
1,5,6,2
2,6,7,3
3,7,8,4
4,8,5,1
];


for k=1:size(box_face,1)
    
    ivx=box_face(k,:);
    
    faceName = sprintf('%s_f%.d',objName,k);
    
    fprintf('%s_mesh=[\n',faceName);
    for iv=1:4
        vex = obb3d(ivx(iv),:);       
        vstr=strjoin(strsplit(mat2str(vex(:)),';'),',');
        
        fprintf('%s,\n',vstr);
    end
    fprintf(']\n');    
    
    
    
    fprintf('mData={''points3'':%s_mesh }\n',faceName);
    fprintf('mNode = createSceneNode(root=root,scene=scene , name=''%s_node'' )\n',faceName);
    fprintf('createMesh_notex(meshNode=mNode , name=''%s_'' , meshData=mData  )\n',faceName);
    
    fprintf('\n');  
    
end

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
