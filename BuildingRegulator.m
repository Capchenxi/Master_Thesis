% This script is used to regulate the vertices and generic feature points of one given model.
% This script can also help correct/ make sure chosen feature points on
% some specific vertices. - Chenxi Li 2016/12/1
function [ Data ] = BuildingRegulator(modelname)
%% Load and regulate the model.
modelname = 'Tower3';
Data = load(modelname);   
Data.gmt = cell2mat(struct2cell(load(modelname,'Tri'))); %load Vertices and Triangles information from raw obj file
Data.gmv = cell2mat(struct2cell(load(modelname,'Ver')));

Temp = cell2mat(struct2cell(load([modelname,'_feature_pts'],'mp_final_ascend')));%load fpts picked from Meshlab
Data.gmfpt = Temp(:,2:4);% The first column is order of the points.
Data.gms = 1;
debug = 'debug';
%% Check if the chosen point is on the mask.
Idx = GetPosIdx(1);%Frontal Position;
% if isfield(Data,'ImgFPt')
%     Idx = GetKeyIdx( Data.ImgFPt, 1, 1 );   % index of non-zero feature points into gmfpt
% else
%     Idx = Data.gmfpt(:,1)~=0 & Data.gmfpt(:,2)~=0 & Data.gmfpt(:,3)~=0;
% end
Data.gmfpt_nz_i = Idx;

[ ind, ~ ] = NNSearch3DFEX( [ Data.gmv(:,1) Data.gmv(:,2) Data.gmv(:,3) ], [ Data.gmfpt(Idx,1), Data.gmfpt(Idx,2), Data.gmfpt(Idx,3) ] );
Data.gmfpt(Idx,:) = Data.gmv(ind,1:3);
Data.gmfpt_i = ind; % index of non-zero feature points into gmv

%% Find centriod and move
CO = mean( Data.gmv(:,1:3) );   % the centroid

Data.gmv(:,1:3) = Data.gmv(:,1:3) - repmat(CO,size(Data.gmv(:,1:3),1),1);
Data.gmfpt(Idx,:)  = Data.gmfpt(Idx,:) - repmat(CO,size(Data.gmfpt(Idx,:),1),1);
% if isfield( Data, 'gmcpt' )
%     Data.gmcpt  = Data.gmcpt - repmat(CO,size(Data.gmcpt,1),1);
% end

MAX = max( max( abs(Data.gmv(:,1:3)) ) );

if MAX > 1
    Scale = 1 / (MAX*1.1);
    Data.gmv(:,1:3) = Data.gmv(:,1:3) * Scale;
    Data.gmfpt = Data.gmfpt * Scale;
%     if isfield( Data, 'gmcpt' )
%         Data.gmcpt  = Data.gmcpt * Scale;
%     end
%         Data.gm_sc = Data.gm_sc * Scale;
else
    Scale = 1;
end

if strcmp(debug, 'debug')
    campos_t = [ 0  0 20 ]';
    ViewAngle = [0 -90];
    ah = [0 0];
    figure;
    for i = 1:2
        ah(i) = subplot(1,2,i);
        ph = patch( 'Faces', Data.gmt(:,1:3), 'Vertices', [ Data.gmv(:,1) Data.gmv(:,2) Data.gmv(:,3) ] );
        hold on;
%             axis image; 
        set( ph, 'EdgeColor', 'none' );
        campos( [campos_t(1) campos_t(2) campos_t(3)] );    % camera pose
        xlabel('X');ylabel('Y');zlabel('Z');title('Regulated Model');
        view([ViewAngle(i) 0]);
        if size( Data.gmv, 2 ) == 4 %The 4th column is the triangle # of vertices;-Chenxi
            set( ph, 'FaceColor', [0.8 0.8 0.8] );
            light('Position',[1 -1 0],'Style','infinite');
        else
            set(ph, 'FaceVertexCData', [Data.gmv(:,4)/255, Data.gmv(:,5)/255, Data.gmv(:,6)/255] );
            set(ph, 'FaceColor', 'interp');
        end
%         camproj perspective;
        axis tight;
        axis equal;
    end
end

%  plot3( cData.gmft(Idx,1), -cData.gmft(Idx,3), cData.gmft(Idx,2), '.b' );hold on;
        
% this is to make sure that all Ft & Ct are on the surface

if strcmp(debug, 'debug')
    plot3( Data.gmfpt(Idx,1), Data.gmfpt(Idx,2), Data.gmfpt(Idx,3), '.b' ); hold on;
%         K = delaunay( Data.gmfpt(Idx,1), Data.gmfpt(Idx,2) );
%         patch( 'Faces', K(:,1:3), 'Vertices', [ Data.gmfpt(Idx,1), -Data.gmfpt(Idx,3)-0.25, Data.gmfpt(Idx,2) ], 'FaceColor', 'none', 'FaceAlpha', 1, 'EdgeColor', 'b' ); hold on
end

if isfield( Data, 'gmcpt' )
    [ ind, ~ ] = NNSearch3DFEX( [ Data.gmv(:,1) Data.gmv(:,2) Data.gmv(:,3) ], [ Data.gmcpt(:,1), -Data.gmcpt(:,3), Data.gmcpt(:,2) ] );
    Data.gmcpt = Data.gmv(ind,1:3);
    Data.gmcpt_i = ind;
    if strcmp(debugFlag, 'debug')
        plot3( Data.gmcpt(:,1), -Data.gmcpt(:,3), Data.gmcpt(:,2), '.r' ); hold on;
    end
end
save(modelname,'Data');
end

%     for i = 1 : length(Idx)
%         if Idx(i) == 1
%             text( Data.gmfpt(i,1), -Data.gmfpt(i,3), Data.gmfpt(i,2), num2str(i) );
%         end
%     end
% end
