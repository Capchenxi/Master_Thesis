% function mp_final_ascend = import_pp_file1(filename, startRow, endRow)
%startRow ����������ʼ��һ�У� endRow����������������һ�У���ͬ��obj��ͬ����ֵ
%formatSpec ������Ҫ�����Ļ�ѡ�����ĸ���� 20160918

filename = 'Tower3_picked_points.pp';
startRow = 9;
endRow = 71;


delimiter = ' ';
if nargin<=2
    startRow = 9;
    endRow = 73;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%s%s%s%s%*s';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this code. If an error occurs for a different file, try regenerating the code from the Import
% Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
% for block=2:length(startRow)
%     frewind(fileID);
%     dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
%     for col=1:length(dataArray)
%         dataArray{col} = [dataArray{col};dataArrayBlock{col}];
%     end
% end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4]
    % Converts strings in the input cell array to numbers. Replaced non-numeric strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Create output variable
mp73 = cell2mat(raw);
mp73_final = zeros(size(rawData, 1),4);
mp73_final(:,1) = mp73(:,1);
mp73_final(:,2) = mp73(:,2);
mp73_final(:,3) = mp73(:,3);
mp73_final(:,4) = mp73(:,4);
mp_final_ascend = sortrows(mp73_final,1);
%% Save mat files.
filename_pre = char(regexp(char(regexp(filename,'\w*(?=_)','match')), '\w*(?=_)','match'));
filename_save = [filename_pre '_feature_pts' '.mat'];
save(filename_save,'mp_final_ascend');
% end
