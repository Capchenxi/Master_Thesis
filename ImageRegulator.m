function ImageRegulator(input_name,Pos)
Pos = 1;
debug = 'debug';
% modelname = 'Tower3_ImgFpts';
input_name = 'Tower3_picked_p1';
Data = load(input_name);   
fpts = cell2mat(struct2cell(load(input_name,'fpts'))); %load uv from 2D image

%% Find centriod and move
CO = mean( fpts(:,1:2) );   % the centroid

fpts(:,1:2) = fpts(:,1:2) - repmat(CO,size(fpts(:,1:2),1),1);

MAX = max( max( abs(fpts(:,1:2)) ) );

if MAX > 1
    Scale = 1 / (MAX*1.1);
    fpts = fpts * Scale;
else
    Scale = 1;
end

if strcmp(debug, 'debug')
%     campos_t = [ 0  0 20 ]';
    ViewAngle = [0 -90];
    figure;
    scatter(fpts(:,1),fpts(:,2));
    hold on;
    xlabel('X');ylabel('Y');zlabel('Z');title('Regulated uv points');
    view(ViewAngle);
%         camproj perspective;
    axis tight;
    axis equal;
end

%  plot3( cData.gmft(Idx,1), -cData.gmft(Idx,3), cData.gmft(Idx,2), '.b' );hold on;
%% Form model name.
underline = strfind(input_name,'_');
modelname = [input_name(1:underline(1)),'ImgFpts'];
Data.ImgFpts(:,2*Pos-1:2*Pos) = fpts(:,1:2);  %Save uv fpts into one file. 
save(modelname,'Data');
% end