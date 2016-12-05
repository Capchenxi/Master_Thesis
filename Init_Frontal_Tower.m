%Try to map the texture from image to personalized model
%% Load Data
imgname = 'Tower3_ImgFpts';
modelname = 'Tower3.mat';
Pos = 1;
struct = load(imgname);
Data1 = struct.Data;

ver1 = Data1.fpts(:,2*Pos-1:2*Pos);
ver2 = Data1.new_model{Pos};
Tri = Data1.tri{Pos};
ImgFpt_nz_idx = Data1.ImgFpt_nz_idx{Pos};

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
%% Let's find out Z depth.
[ ~, Z ] = VisibleVertices( Pt2, ver2(ImgFpt_nz_idx,1:3), Tri, [0,0,1], min(ver2(ImgFpt_nz_idx,3)) );

%find idx so that Z~=nan;
idx = (1:length(Z))';
badZ = isnan(Z);
goodZ = ~badZ;
igoodZ = idx(goodZ);
ibadZ = sort( idx(badZ), 'descend' );
if numel( ibadZ ) > 0
    Z = Z(igoodZ);
%     Pt1 = Pt1(igoodZ,:);
%     Pt2 = Pt2(igoodZ,:);%Pt2 is the first column and second column of new_model
    [ faces2, Pt2_new,Irreg ] = RemoveTri( faces2, Pt2, igoodZ );
    if numel( Irreg ) > 0
        Pt1( Irreg, : ) = [];
        Pt2( Irreg, : ) = [];
        Z( Irreg, : ) = [];
    end
end

% new_model_test = [newVer(:,1:2),Z(:,1)];


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

ph = patch( 'Faces', faces2, 'Vertices', [ Pt2_new(:,1), Pt2_new(:,2) , Z(:,1)]); axis image; hold on;
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
