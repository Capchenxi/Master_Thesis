%This script tells me in ** position, I can see fpts with [Idx] like [Idx]. 
% And drop some fpts that couldn't be seen in ** position.
% Input: Pos is like **
% Output: Idx is a 1 by N(N is the valid points that could be seen frome
% pos **);
function [Idx] = GetPosIdx(Pos)

switch(Pos)
    case 1,
        Idx = [1:63];
%     case 2,
%         if sgn
%             Idx = [2:8 10:13 15:39 47 49:63 67:69 72:73 75:79 80:83];
%         else
%             Idx = [2:8 10:13 15:39 47 49:63 67:69 72:73 75:79];
%         end
%     case 3,
%         if sgn
%             Idx = [2:4 6:8 10 12:13 15:17 20:29 32:39 47 49:54 56:59 61:63 67:69 72:73 75:79 80:83];
%         else
%             Idx = [2:4 6:8 10 12:13 15:17 20:29 32:39 47 49:54 56:59 61:63 67:69 72:73 75:79];
%         end
%     case 4,
%         Idx = [4 8 10 12 13 15 22 23 26 27 34 35 38 39 47 49 51 52 54 56 57 59 61 63 67:69 72:73 75:79];
end
