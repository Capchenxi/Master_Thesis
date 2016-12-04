% --------------------------- Descriptions --------------------------------
% This matlab program reads a *.obj file and changes its format from:

% -------------------------------------------------------------------------

function [ Ver, Tri, Poly ] = ParseObjData_Geomagic( Path, iFile, oFile )
    
 tic;
    
% %     [ ~, SYSID ] = SystemAdapter;
% %     if strcmp( SYSID, 'WINDOWS')
% %         Path = [ 'D:\Drexel\Research_n_Projects', '\ACVA\Data\TestingData\', Folder, '\' ];
% %     else        
% %         Path = ['/media/Research/Drexel/Research_n_Projects/ACVA/Data/TestingData/', Folder, '/'];
% %     end
%     Path = 'C:\Users\sony\Documents\MATLAB\';
%     iFile = 'EmpireState.obj'
%     oFile = 'EmpireState_stat'
    fileID = fopen( [Path, iFile]);
    if fileID == -1
        error( ['Unable to open file: ', 'EmpireState.obj']);
    end
    NoV = 0;    % # of vertices
    NoT = 0;    % # of triangles
    i = 0;
    N = 0;
    
    msg = 'Extracting coordinates info, please wait';
    h1 = waitbar( 0, [msg, ' ... '], 'Name', 'Parse obj data ...' );
    fprintf( '%s: %3d%%', msg, 0 );
    
 %% Find number of vertices.
    while 1
        tline = fgetl(fileID);
        if isempty(strfind(tline,'vertices'))

        else
           N = str2num(cell2mat(regexp(tline, '\d*(?= vertices)','match')));
           break
        end
    end
    frewind(fileID);
    Ver = zeros( N, 3 );
%% Get coordinate of vertices.
       while 1
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
              if tline(1) == 'v';
                i = i + 1;                
                if mod(i,1000) == 0
                    fprintf( sprintf('%s%%3d%%%%', ...
                             repmat('\b', 1, 4)), ...
                             round(i/N*100) );
                    waitbar( i/N, h1, ...
                             [ msg, ' ... ', ...
                             num2str(round(i/N*100)), '%'] );
                end
                LineEnd = length(tline); 
                Ver(i, 1) = str2double( tline(Space(2):Space(3)) );
                Ver(i, 2) = str2double( tline(Space(3):Space(4)) );
                Ver(i, 3) = str2double( tline(Space(4):LineEnd) );
              
                if i == N;
                    waitbar( 1, h1, ...
                             [ msg, ' ... ', ...
                             num2str(round(i/N*100)), '%' ] );
                    fprintf( sprintf('%s%%3d%%%%', ...
                             repmat('\b', 1, 4)), round(N/N*100) );
                    break;
                end
            else
                % do nothing
              end 
              else
              end
        end
    end

    fprintf('. Done!\n')
    delete(h1);
    

   msg = 'Extracting triangles info, please wait';

    h2 = waitbar(0, [ msg, ' ... ' ], 'Name', 'Parse obj data ...' );
    fprintf('%s: %3d%%', msg, 0);
    j = 1; 
    k = 1;
    
    while 1
        tline = fgetl(fileID);
        if isempty(strfind(tline,'polygons'))
           %do nothing 
        else
            N2 = str2num(cell2mat(regexp(tline, '\d*(?= polygons)','match')))-1;
            N1 = str2num(cell2mat(regexp(tline, '\d*(?= triangles)','match')));
            break
        end
    end
    N = N1+N2;
    frewind(fileID);
    
    Tri = zeros( N1, 3 );
    Poly = zeros( N2, 4 );
    
    while 1
        tline = fgetl(fileID);
        if ~ischar(tline)
            break;
        else
            Space = strfind( tline, ' ' );
        end
        if ~isempty(tline)
                    if tline(1) == 'f';
            NoT = NoT + 1;                             
                if mod(j,1000) == 0
                    fprintf( sprintf('%s%%3d%%%%', ...
                             repmat('\b', 1, 4)), round((j+k)/N*100) );
                    waitbar( j/N, h2, ...
                             [ msg, ' ... ', ...
                             num2str(round(j/N*100)), '%'] );
                end
                if numel(Space)<4
                    % do nothing
                else          
                     if numel(Space) == 4 
                        TempT = regexp(tline, '(?<=\ )\d*(?=\/)','match');
                        Tri(j, 1) = str2double(cell2mat(TempT(1,1)));
                        Tri(j, 2) = str2double(cell2mat(TempT(1,2)));
                        Tri(j, 3) = str2double(cell2mat(TempT(1,3)));
                        j = j+1;
                     
                     elseif numel(Space) == 5 
                        TempP = regexp(tline, '(?<=\ )\d*(?=\/)','match');
                        Poly(k, 1) = str2double(cell2mat(TempP(1,1)));
                        Poly(k, 2) = str2double(cell2mat(TempP(1,2)));
                        Poly(k, 3) = str2double(cell2mat(TempP(1,3)));
                        Poly(k, 4) = str2double(cell2mat(TempP(1,4)));
                        k = k+1;
                    end
                end

                if j == N1 && k == N2;
                    waitbar( 1, h2, ...
                             [ msg, ' ... ', ...
                             num2str(round((j+k)/N*100)), '%'] );
                    fprintf( sprintf('%s%%3d%%%%', ...
                             repmat('\b', 1, 4)), round(N/N*100));
                    break;
                end
            else
                N = 0;
            end
%         else
        end

    end

    fprintf('. Done!\n')
    delete(h2);
    
    fclose(fileID);
    
%% Find vertices shared by faces
% NoF = length(Tri) +length(Poly);
NoT = length(Tri);
NoP = length(Poly);
VSFs = zeros( length(Ver),1);
for i = 1:NoT
    VSFs(Tri(i,1)) = VSFs(Tri(i,1))+1;
    VSFs(Tri(i,2)) = VSFs(Tri(i,2))+1;
    VSFs(Tri(i,3)) = VSFs(Tri(i,3))+1;
    
    Ver( Tri(i,1), 4 ) = i;
    Ver( Tri(i,2), 4 ) = i;
    Ver( Tri(i,3), 4 ) = i;
end
% 
for j = 1:NoP
    VSFs(Poly(j,1)) = VSFs(Poly(j,1)) + 1;
    VSFs(Poly(j,2)) = VSFs(Poly(j,2)) + 1;
    VSFs(Poly(j,3)) = VSFs(Poly(j,3)) + 1;
    VSFs(Poly(j,4)) = VSFs(Poly(j,4)) + 1;
    
    Ver(Poly(j,1), 5 ) = j;
    Ver(Poly(j,2), 5 ) = j;
    Ver(Poly(j,3), 5 ) = j;
    Ver(Poly(j,4), 5 ) = j;
end
%     % ---------------------------------------------------------------------
%     % Find all the vertices that do not belong to any triangles and
%     % delete these irregularities
%     % ---------------------------------------------------------------------
%     Irreg = find( sum( Ver(:, 7:size(Ver,2)),2 ) == 0 );
%     Irreg = sort( Irreg, 'descend' );
%     if numel( Irreg ) > 0
%         for j = 1 : length( Irreg )
%             Ver( Irreg(j), : ) = [];
%             Irreg_Index = find( Tri(:,1:3) > Irreg(j) );
%             Tri( Irreg_Index ) = Tri( Irreg_Index ) - 1;
%         end
%     end
    % ---------------------------------------------------------------------
    save( [ Path, oFile, '.mat' ], 'Ver', 'Tri', 'Poly','-mat' );
    toc
end