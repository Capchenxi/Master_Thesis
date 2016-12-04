% This script used to find the convexhull of the given images pf a specific
% position **. Input is the given uv 2D coordinates in specific position.
% Output contains the layers
cc = hsv(12);
%% Load Data.
modelname = 'Tower3_ImgFpts';
Pos = 1;
struct = load(modelname);
Data = struct.Data;
ImgFpts = Data.ImgFpts(:,2*Pos-1:2*Pos);% Regulated with pos 1.
% fpt = Tower_fpts2d;%Use this as the 2d projection feature points of original model.

N = size(ImgFpts,1);
fpt_n = ImgFpts; fpt_n(:,3) = 1:N;%fpt_n is a matrix with the original # of the points. 
fpt_change = fpt_n;
%% This part is to define layer information as a cell structure, each cell represent a Pos. 
% layer_pt = cell(1,5);
% layer_area = cell(1,5);
% layer_ratio = cell(1,5);
% rowsize = cell(1,5);
%%
for i = 1:N/3
    dt = delaunayTriangulation(fpt_change(:,1),fpt_change(:,2));
    k = convexHull(dt);%k是找到的convexhull 的第一圈
    layer_pt{Pos}(1:size(k),i) = fpt_change(k,3);% this is what I want for the area ratio
    plot(dt.Points(:,1),-dt.Points(:,2), '.', 'markersize',10); hold on;
    plot(dt.Points(k,1),-dt.Points(k,2), 'color',cc(i,:)); hold on;
    axis equal;
    fpt_change(k,:) = [];
    if size(fpt_change,1) <= 2; break; else end;
end

layer_pt{Pos}(size(layer_pt{Pos},1)+1,:) = 0; 
layer_area{Pos} = zeros(size(layer_pt{Pos}));
for j = 1:size(layer_pt{Pos},2) % j means # of layers.
    for k = 1:size(layer_pt{Pos},1)-2
        if layer_pt{Pos}(k,j) == 0 ||layer_pt{Pos}(k+1,j) == 0 ||layer_pt{Pos}(k+2,j) == 0;
            break
%             layer_area{Pos}(k,j) = 0;
        else
            layer_area{Pos}(k,j) = tri_area(ImgFpts(layer_pt{Pos}(k,j),:),ImgFpts(layer_pt{Pos}(k+1,j),:),ImgFpts(layer_pt{Pos}(k+2,j),:));
        end
    end
    layer_area{Pos}(k,j) = tri_area(ImgFpts(layer_pt{Pos}(k,j),:),ImgFpts(layer_pt{Pos}(1,j),:),ImgFpts(layer_pt{Pos}(2,j),:));   
end

%rowsize used to record the size in very col when compare the invariants.
rowsize{Pos} = zeros(1,size(layer_area{Pos},2));
for j = 1:size(layer_area{Pos},2)
   for i = size(layer_area{Pos},1):-1:1
     if layer_area{Pos}(i,j) == 0;
     else
         break
     end     
   end
   rowsize{Pos}(1,j) = i;
end

%Try to clculate the ratio of the triangle neighbors.
for i = 1:size(layer_area{Pos},2)
    for j = 1:rowsize{Pos}(i)-1
        if layer_area{Pos}(j+1,i) == 0;
            layer_ratio{Pos}(j,i) = 0;
        else 
            layer_ratio{Pos}(j,i) = layer_area{Pos}(j,i)/layer_area{Pos}(j+1,i);
        end
    end
    layer_ratio{Pos}(rowsize{Pos}(i),i) = layer_area{Pos}(rowsize{Pos}(i),i)/layer_area{Pos}(1,i);
end

% if isfield(Data,'gmfpt')
%     Data.gm_layer_pt = layer_pt;
%     Data.gm_layer_area = layer_area;
%     Data.gm_layer_ratio = layer_ratio;
%     Data.gm_rowsize = rowsize;
% else

%% Save part.
%Here use the structure array to store different Pos information.
Data.layer_pt = layer_pt;
Data.layer_area = layer_area;
Data.layer_ratio = layer_ratio;
Data.rowsize = rowsize;

save(modelname,'Data');
% end