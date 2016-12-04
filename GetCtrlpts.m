% This script used to find the correspoding points between generic model
% and Images. -Chenxi 2016/12/02
%% Load Data
gmfilename = 'Tower3';
Imgname = 'Tower3_ImgFpts';
struct = load(gmfilename);
struct1 = load(Imgname);
Data1 = struct.Data;
Data2 = struct1.Data;
Pos = 1;% Postition same as the convexhull layer we try to find the corresponding points.
% img_order = cell(1,5);%initial the order matrix into cell structure.
% gm_order = cell(1,5);


gm_layer_ratio = Data1.gm_layer_ratio;
gm_layer_pt = Data1.gm_layer_pt;
gm_layer_area = Data1.gm_layer_area;
gm_rowsize = Data1.gm_rowsize;
gmfpt = Data1.gmfpt;
ver1 = [gmfpt(:,1),gmfpt(:,2)];% Frontal fpts

img_layer_ratio = Data2.layer_ratio{Pos};
img_layer_pt = Data2.layer_pt{Pos};
img_layer_area = Data2.layer_area{Pos};
img_rowsize = Data2.rowsize{Pos};
imgfpts = Data2.ImgFpts(:,2*Pos-1:2*Pos);
ver2 = imgfpts;

% Original_layer = 'Tower1_picked_p1_layer.mat';
% Generic_layer = 'Tower3_projected_p1_layer.mat';
% original_model =load('r_Tower1_picked_p1.mat');
% generic_model = load('r_Tower3_projected_p1.mat');
% Generic_layer = Data1.
% Original_layer = Data2.
epsilon = 0.1;

% function Calculate_invariants(input_filename,Generic_model,epsilon)
% % picked = load (Original_layer);
% % projected = load (Generic_layer);
%Compare the ratio between the piced model and projection model. 
%the # of feature points on each layers suppose be more than the # of
%feature points on picked model for the projection model is the generic
%model so it may have more control of freedom to change than the picked model.?
% epsilon = 0.01;%accepablt error
compare_model = cell(1,size(gm_layer_ratio,2));
size_mtx = zeros(size(gm_layer_ratio,2),2);

for c = 1:size(gm_layer_ratio,2)%我这里改了，不知道列数和行数如何统一，因为都可能不一样
%     compare = zeros(size(gm_layer_ratio,1),size(img_layer_ratio,1));
    a = 0; 
    compare = [];
    for j = 1:gm_rowsize(c)
        A = gm_layer_ratio(j,c);
        for k = 1:img_rowsize(c)
            B = img_layer_ratio(k,c);
            temp = abs((B - A)/B);
            if temp <= epsilon
%                 cor_projection(j,i) = k;
                compare(j,k) = 1;
            else
%                 cor_projection(j,i) = 0;
                compare(j,k) = 0;
            end
        end

    end
    compare_model{c} = compare;
    size_mtx(c,1) = gm_rowsize(c); size_mtx(c,2) = img_rowsize(c);
end

projected_order = cell (1,size(gm_layer_ratio,2));
picked_order = cell (1,size(gm_layer_ratio,2));

for c = 1:size(gm_layer_ratio,2)
    %There will be some probability that the layer of picked image is less
    %than the layer of projected/generic model ATTENTION!
    compare = compare_model{c};
    [rows,cols] = find(compare == 1);
    if isempty(rows) && isempty(cols)
        disp(['There is no corresponding fpts in layer']); disp(c);
        continue
    else
        corresponding_projected = [];
        corresponding_picked =[];
        for j = 1:size(rows,1)
            
            if rows(j) < size_mtx(c,1)-2
                corresponding_projected(j,:) = [rows(j):1:rows(j)+3];
            else
                switch rows(j)
                    case size_mtx(c,1)-2
                        corresponding_projected(j,:) = [rows(j):1:rows(j)+2,1];
                    case size_mtx(c,1)-1
                        corresponding_projected(j,:) = [rows(j),rows(j)+1,1,2];
                    case size_mtx(c,1)
                        corresponding_projected(j,:) = [rows(j),1,2,3];
                end
            end
            if cols(j) < size_mtx(c,2)-2
                corresponding_picked(j,:) = [cols(j):1:cols(j)+3];
            else
                switch cols(j)
                    case size_mtx(c,2)-2
                        corresponding_picked(j,:) = [cols(j):1:cols(j)+2,1];
                    case size_mtx(c,2)-1
                        corresponding_picked(j,:) = [cols(j),cols(j)+1,1,2];
                    case size_mtx(c,2)
                        corresponding_picked(j,:) = [cols(j),1,2,3];
                end
            end
        end 
    end
        projected_order{c} = corresponding_projected ;
        picked_order{c} = corresponding_picked ;
end

% try to find the real # in model with the corresponding order.
for c = 1:size(gm_layer_ratio,2)
    projected_temp = projected_order{c};
    projected_real_temp = [];
    for i = 1: size (projected_temp,1)
        projected_real_temp(i,1) = gm_layer_pt(projected_temp(i,1),c);
        projected_real_temp(i,2) = gm_layer_pt(projected_temp(i,2),c);
        projected_real_temp(i,3) = gm_layer_pt(projected_temp(i,3),c);
        projected_real_temp(i,4) = gm_layer_pt(projected_temp(i,4),c);
    end
    projected_real_order{c} = projected_real_temp;
    
    picked_temp = picked_order{c};
    picked_real_temp = [];
    for i = 1: size (picked_temp,1)
        picked_real_temp(i,1) = img_layer_pt(picked_temp(i,1),c);
        picked_real_temp(i,2) = img_layer_pt(picked_temp(i,2),c);
        picked_real_temp(i,3) = img_layer_pt(picked_temp(i,3),c);
        picked_real_temp(i,4) = img_layer_pt(picked_temp(i,4),c);
    end
    picked_real_order{c} = picked_real_temp;
end
% 
%% Distance Error Calculate.
%If two points correspond to one point, just make sure the one which has
%the smallest distance erro will be chosen
%rows和cols same.
 for c = 1:size(gm_layer_ratio,2)
    %There will be some probability that the layer of picked image is less
    %than the layer of projected/generic model ATTENTION!
    
    %Firstly, find if there are same projected set correspond to same point
    %in picked set.
    A = projected_real_order{c};
    B = picked_real_order{c};
    C = unique(projected_real_order{c},'rows');
    if size(C,1) == size(A,1)
        flag1 = 1;%flag
    else
        for countC = 1:size(C,1)
            isrepeat = find(A(:,1) == C(countC,1));
            if size(isrepeat) == 1;
                continue
            else
                dist = zeros(size(isrepeat,1),1);
                flag2 = 1;%flag
                for p = 1:size(isrepeat)
                    dist(p) = dist_error(A(isrepeat(p),:),ver1,...
                        B(isrepeat(p),:),ver2);
                end
                [~,I] = min(dist);
                I_node = setdiff(isrepeat,isrepeat(I));
                A(I_node,:) = [];B(I_node,:) = [];
            end
        end
    end
    C = unique(picked_real_order{c},'rows');
 if size(C,1) == size(B,1)
        flag1 = 1;%flag
    else
        for countC = 1:size(C,1)
            isrepeat = find(B(:,1) == C(countC,1));
            if size(isrepeat) == 1;
                continue
            else
                dist = zeros(size(isrepeat,1),1);
                flag2 = 1;%flag
                for p = 1:size(isrepeat)
                    dist(p) = dist_error(A(isrepeat(p),:),ver1,...
                        B(isrepeat(p),:),ver2);
                end
                [~,I] = min(dist);
                I_node = setdiff(isrepeat,isrepeat(I));
                A(I_node,:) = [];B(I_node,:) = [];
                flag3 =1;
            end
        end
end
    projected_real_order{c} = [];
    projected_real_order{c} = A;
    picked_real_order{c} = [];
    picked_real_order{c} = B;
 end
img_order{Pos} = picked_real_order;
gm_order{Pos} = projected_real_order;

Data2.img_order = img_order;
Data2.gm_order = gm_order;
Data = Data2;
save(Imgname,'Data');                  
                
