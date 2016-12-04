%Try to map the texture from image to personalized model
%% Load Data
imgname = 'Tower3_ImgFpts';
Pos = 1;
struct = load(imgname);
Data1 = struct.Data;

ver1 = Data1.fpts(:,2*Pos-1:2*Pos);
ver2 = Data1.new_model{Pos};
Tri = Data1.tri{Pos};
% ibadZ = Data1.badZ_idx{Pos};
% Irreg = Data1.Irreg_idx{Pos};
ImgFpt_nz_idx = Data1.ImgFpt_nz_idx{Pos};
% Z = Data1.Z_depth{Pos};
Img = cell(1,5);
ImgH = zeros(1,5);
ImgW = zeros(1,5);
Img{Pos} = imread('E:\Li,Chenxi\Images\Tower3_p1.jpg');
[ ImgW(Pos), ImgH(Pos)] = GetImageSize(Img{Pos});

faces1 = Tri;
faces2 = Tri;

[ Area1 ] = MeshArea(Tri,[ver1(ImgFpt_nz_idx,:),zeros(28,1)]);
[ Area2 ] = MeshArea(Tri,[ver2(ImgFpt_nz_idx,:),zeros(28,1)]);
Scale = sqrt( max(Area1,Area2) / min(Area1,Area2) );%Used to scale z depth.

% [select_idx,~] = find(ImgFpt_nz_idx);%ImgFpt_nz_idx is a logical matix, here find 0 index, which points will not be used later.
% select_idx(ibadZ,:) = []; % remove badZ points.
% select_idx(Irreg,:) = []; % remove unused triangle points. 

Pt1 = [ver1(ImgFpt_nz_idx,1:2),zeros(28,1)];
Pt2 = [ver2(ImgFpt_nz_idx,1:2),zeros(28,1)];

%  plotMesh( [Pt2(:,1),Pt2(:,2)], faces1, 'k');
%     axis equal; title('Subdivided Mesh (2D Image)');

for i = 1:7
    [ Pt1, faces1 ] = myLoopSubdivision2( Pt1, faces1,0);%when max(size(varargin)) ==1, there will not be outer smooth of the mesh.
    [ Pt2, faces2 ] = myLoopSubdivision2( Pt2, faces2,0 );
end

%  plotMesh( [Pt1(:,1),Pt1(:,2)], faces1, 'k');
%     axis equal; title('Subdivided Mesh (2D Image)');

L2i(:,1) = round( Pt1(:,1) );
L2i(:,2) = round( Pt1(:,2) );

Ind = sub2ind( [ ImgH(Pos),ImgW(Pos)  ], L2i(:,2), L2i(:,1) );% weigh - x, height - y;
    
R = Img{Pos}(:,:,1);
G = Img{Pos}(:,:,2);
B = Img{Pos}(:,:,3);
VCData_R( :, 1 ) = double( R(Ind) ) / 255;
VCData_G( :, 1 ) = double( G(Ind) ) / 255;
VCData_B( :, 1 ) = double( B(Ind) ) / 255;

model_color = [ VCData_R, VCData_G, VCData_B ];

ph = patch( 'Faces', faces1, 'Vertices', [ Pt2(:,1), Pt2(:,2) , zeros(size(Pt2,1),1)]); axis image; hold on;
set( ph, 'EdgeColor', 'none' );
% campos( [campos_t(1) campos_t(2) campos_t(3)] );    % camera pose
xlabel('X');ylabel('Y');zlabel('Z'); title('Personalized Model');
view([90 90]);
set(ph, 'FaceVertexCData', model_color );
set(ph, 'FaceColor', 'flat');

%% Save part.
% Data.Img = Img;
% Data.ImgH = ImgH;
% Data.ImgW = ImgW;
