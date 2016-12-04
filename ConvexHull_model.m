%% This fuction aims on finding the convexhull layers of a picked/projected 
%%  2d plane and areas formed by neighbor triangles.
% INPUT: input_filename
% OUTPUT: .mat file stored all layer information contains each layer points, neighbor areas.
% Ex. Give a input_filename 'Tower3_picked_p1.mat' with picked feature
% points found in 2d plane, I will get a output file named
% 'Tower3_picked_p1_layer.mat' with layer_pt,layer_area, layer_type(picked/projected?),
% layer_ratio(area ratio of triangle neighbors)
% Chenxi Li 2016/10/22-2016/12/02 Revised
% Convexhull 有一个问题，没有平面化，这里引入的还是三维的，但是frontal例外就正好可以，要改！
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ConvexHull_model(modelname)
%% Load data
modelname = 'Tower3';
cc = hsv(12);
struct = load( modelname );%Use this as the picked feature points from the images.
Data = struct.Data;
gmfpt = Data.gmfpt;% Regulated with pos 1.
% fpt = Tower_fpts2d;%Use this as the 2d projection feature points of original model.

N = size(gmfpt,1);
%!!gmfpt_n应该变成一个二维的平面投影，要改！
gmfpt_n = gmfpt; gmfpt_n(:,3) = 1:N;%fpt_n is a matrix with the original # of the points. 
gmfpt_change = gmfpt_n;
for i = 1:N/3
    dt = delaunayTriangulation(gmfpt_change(:,1),gmfpt_change(:,2));
    k = convexHull(dt);%k是找到的convexhull 的第一圈
    layer_pt(1:size(k),i) = gmfpt_change(k,3);% this is what I want for the area ratio
    plot(dt.Points(:,1),dt.Points(:,2), '.', 'markersize',10); hold on;
    plot(dt.Points(k,1),dt.Points(k,2), 'color',cc(i,:)); hold on;
    axis equal;
    gmfpt_change(k,:) = [];
    if size(gmfpt_change,1) <= 2; break; else end;
end
layer_pt(size(layer_pt,1)+1,:) = 0; 
layer_area = zeros(size(layer_pt));
for j = 1:size(layer_pt,2) % j means # of layers.
    for k = 1:size(layer_pt,1)-2
        if layer_pt(k,j) == 0 ||layer_pt(k+1,j) == 0 ||layer_pt(k+2,j) == 0;
            break
%             layer_area(k,j) = 0;
        else
            layer_area(k,j) = tri_area(gmfpt(layer_pt(k,j),:),gmfpt(layer_pt(k+1,j),:),gmfpt(layer_pt(k+2,j),:));
        end
    end
    layer_area(k,j) = tri_area(gmfpt(layer_pt(k,j),:),gmfpt(layer_pt(1,j),:),gmfpt(layer_pt(2,j),:));   
end

%rowsize used to record the size in very col when compare the invariants.
rowsize = zeros(1,size(layer_area,2));
for j = 1:size(layer_area,2)
   for i = size(layer_area,1):-1:1
     if layer_area(i,j) == 0;
     else
         break
     end     
   end
   rowsize(1,j) = i;
end

%Try to clculate the ratio of the triangle neighbors.
for i = 1:size(layer_area,2)
    for j = 1:rowsize(i)-1
        if layer_area(j+1,i) == 0;
            layer_ratio(j,i) = 0;
        else 
            layer_ratio(j,i) = layer_area(j,i)/layer_area(j+1,i);
        end
    end
    layer_ratio(rowsize(i),i) = layer_area(rowsize(i),i)/layer_area(1,i);
end

if isfield(Data,'gmfpt')
    Data.gm_layer_pt = layer_pt;
    Data.gm_layer_area = layer_area;
    Data.gm_layer_ratio = layer_ratio;
    Data.gm_rowsize = rowsize;
else
    Data.layer_pt = layer_pt;
    Data.layer_area = layer_area;
    Data.layer_ratio = layer_ratio;
    Data.rowsize = rowsize;
end


save(modelname,'Data');
end





