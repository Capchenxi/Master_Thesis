%function aims to calsulate the sum of distance error between corresponding 
%the number set A,B.- Chenxi
function total_dist = dist_error(A,generic,B,original)
if size(A) ~= size(B)
    disp('Set A and B must have same size.')
else
    dist = zeros(size(A,2),1);
    for i = 1:size(A,2)
        A_x = generic(A(i),1);A_y = generic(A(i),2);
        B_x = original(B(i),1);B_y = original(B(i),2);
        dist(i) = sqrt((A_x-B_x)^2+(A_y-B_y)^2);
    end
    total_dist = sum(dist);    
end
