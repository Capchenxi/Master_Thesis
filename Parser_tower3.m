tic;

oFile = 'Tower3'
Path = 'C:\Users\sony\Documents\MATLAB\';
iFile = 'Tower3.obj'
    fileID = fopen( [Path, iFile]);

    NoV = 0;    % # of vertices
    NoT = 0;    % # of triangles
    i = 0;
    N = 0;
    
    msg = 'Extracting coordinates info, please wait';
    h1 = waitbar( 0, [msg, ' ... '], 'Name', 'Parse obj data ...' );
    fprintf( '%s: %3d%%', msg, 0 );
    flag = 1;
    test = 0;
    
    
 %% Find number of vertices.
 while flag == 1
        tline = fgetl(fileID);
        if ~ischar(tline)
            break;
        else
            Space = strfind( tline, ' ' );
            if numel(Space) < 4
                Space(numel(Space)+1) = numel(tline);
            end
            NoV = NoV + 1;             
              if ~isempty(tline)
              if tline(1:Space(1)-1) == 'v';
                i = i + 1;                
                LineEnd = length(tline); 
                Ver(i, 1) = str2double( tline(Space(2):Space(3)) );
                Ver(i, 2) = str2double( tline(Space(3):Space(4)) );
                Ver(i, 3) = str2double( tline(Space(4):LineEnd) );
              elseif length(tline) < 13
                      continue                      
              elseif strcmp(tline(6:13),'vertices')
                      N = tline(Space(1):Space(2));
                      if i == N
                          break
                      else end
              else
              end
              end
              
        end
 end
    fprintf('. Done!\n')
    delete(h1);
    
    msg = 'Extracting triangles info, please wait';

    h2 = waitbar(0, [ msg, ' ... ' ], 'Name', 'Parse obj data ...' );
    fprintf('%s: %3d%%', msg, 0);
    j = 0; 
    k = 0;
    
    frewind(fileID);
    
    while 1
        tline = fgetl(fileID);
        if ~ischar(tline)
            break;
        else
            Space = strfind( tline, ' ' );
            LineEnd = length(tline);
        end
        NoT = NoT + 1;
        if ~isempty(tline)
            if tline(1) == 'f';            
                if numel(Space)<4
                    % do nothing
                else          
                     if numel(Space) == 4 
                        j = j+1;
                        TempT = regexp(tline, '(?<=\ )\d*(?=\/)','match');
                        Tri_1(j, 1) = str2double(cell2mat(TempT(1,1)));
                        Tri_1(j, 2) = str2double(cell2mat(TempT(1,2)));
                        Tri_1(j, 3) = str2double(cell2mat(TempT(1,3)));
                                             
                     elseif numel(Space) == 5 
                        k = k+1;
                        TempP = regexp(tline, '(?<=\ )\d*(?=\/)','match');
                        Poly(k, 1) = str2double(cell2mat(TempP(1,1)));
                        Poly(k, 2) = str2double(cell2mat(TempP(1,2)));
                        Poly(k, 3) = str2double(cell2mat(TempP(1,3)));
                        Poly(k, 4) = str2double(cell2mat(TempP(1,4)));
                        
                    end
                end
            elseif length(tline)< 28 || length(Space)<5
                continue
            elseif strcmp(tline(Space(2):Space(3)),'polygons') && ...
                    strcmp(tline(Space(5):LineEnd),'triangles')
                N1 = tline(Space(1):Space(2));
                N2 = tline(Space(4):Space(5));
                if j == N1+1 && k == N2+1
                    break
                else 
                end
                
            end
            else
                N = 0;   
        end
%         else
    end

fprintf('. Done!\n')
delete(h2);

Poly_1 = zeros(2*length(Poly),3);
 for i = 1:length(Poly)
     Poly_1(i,1) = Poly(i,1);
     Poly_1(i,2) = Poly(i,2);
     Poly_1(i,3) = Poly(i,3);
 end
 
 for j = (length(Poly)+1) : 2*length(Poly)
     Poly_1(j,1) = Poly(j-length(Poly),3);
     Poly_1(j,2) = Poly(j-length(Poly),4);
     Poly_1(j,3) = Poly(j-length(Poly),1);
 end
 
Tri = [Tri_1;Poly_1];  

NoT = length(Tri);
VSFs = zeros( length(Ver),1);
for i = 1:NoT
    VSFs(Tri(i,1)) = VSFs(Tri(i,1))+1; %+1表示三角形占用了这个点，这个点事有效的点
    VSFs(Tri(i,2)) = VSFs(Tri(i,2))+1;
    VSFs(Tri(i,3)) = VSFs(Tri(i,3))+1;
    
    Ver( Tri(i,1), 4 ) = i;
    Ver( Tri(i,2), 4 ) = i;
    Ver( Tri(i,3), 4 ) = i;
end

    save( [ Path, oFile, '.mat' ], 'Ver', 'Tri','-mat' );
    toc
% end