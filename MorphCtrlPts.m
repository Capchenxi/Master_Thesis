%This function aims to Change the corresponding points in 3d genericmodel
%and make is more like model we get in image. -Chenxi 2016/12/02
%% Load Data.
Pos = 1;

struct1 = load('Tower3_ImgFpts','Data');
struct2 = load('Tower3','Data');
Data1 = struct1.Data;
Data2 = struct2.Data;
gm_order = Data1.gm_order{Pos};
img_order = Data1.img_order{Pos};
gmfpt = Data2.gmfpt;
ImgFpt = Data1.ImgFpts(:,Pos*2-1:Pos*2);
ver1 = gmfpt(:,1:3);%Only Frontal;
ver2 = [ImgFpt,zeros(size(ImgFpt,1),1)];
badZ_idx = cell(1,5);
Irreg_idx = cell(1,5);
new_model = cell(1,5);
Z_depth = cell(1,5);
tri = cell(1,5);
ImgFpt_nz_idx = cell(1,5);
new_model{Pos} = zeros(size(ver2));

for i = 1:size(gm_order,2)
    for j = 1:size(gm_order{i},1)
        generic = gm_order{i}(j,:);
        original = img_order{i}(j,:);
%         temp = zeros(4,2);%如果加z depth 记得改size
        for k = 1:4 % 4 points are a pair/2 triangle areas candecide a ratio.
           ver1(generic(k),1) = ver2(original(k),1);
           ver1(generic(k),2) = ver2(original(k),2);           
           new_model{Pos}(original(k),1:2) = ver1(generic(k),1:2);
%            temp(k,1:2) = new_model(generic(k),:);      
        end
        
    end
end


% new_model = new_model(index1~=0,:);%去除整行零项
% new_model = unique(new_model,'rows');% 去除重复性
nz_idx =  all(new_model{Pos}(:,1:2),2);%non-zero row index in new_model.mat
new_model{Pos}(nz_idx,3) = ver1(nz_idx,3);

scatter3(new_model{Pos}(nz_idx,1),-new_model{Pos}(nz_idx,2),new_model{Pos}(nz_idx,3));axis equal; hold on;
DT = delaunayTriangulation (new_model{Pos}(nz_idx,1),new_model{Pos}(nz_idx,2));
tri{Pos} = DT.ConnectivityList;

%% Save part.
ImgFpt_nz_idx{Pos} = nz_idx;
Data1.new_model = new_model;
Data1.tri = tri;
Data1.ImgFpt_nz_idx = ImgFpt_nz_idx;
Data = Data1;
% 
imgfile = 'Tower3_ImgFpts';
save(imgfile,'Data');

trimesh(tri{1},new_model{Pos}(nz_idx,1),-new_model{Pos}(nz_idx,2),new_model{Pos}(nz_idx,3))%'FaceColor', faceColor,...
xlabel('X');ylabel('Y');zlabel('Z');   
% 'EdgeColor',edgeColor,'FaceAlpha',0.3);
   axis equal