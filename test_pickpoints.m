filename = 'Tower4_1'; Pos = 1;
figure;
% Img = imread(['C:\Users\sony\Documents\MATLAB\Model_revised\2D_images\',filename,'_p',num2str(Pos),'.jpg']);
 Img = imread(['C:\Users\sony\Documents\MATLAB\Model_revised\2D_images\Tower4_p',num2str(Pos),'.jpg']);
imshow(Img);
pause() % you can zoom with your mouse and when your image is okay, you press any key
ind = GetPosIdx(filename,Pos)';
M = zeros(size(ind,1),2);
M = ginput(size(ind,1));
zoom out; % go to the original size of your image
fpts = M;
save([filename,'_p',num2str(Pos),'_fpts.mat'],'fpts');
