% This function extracts the data 
% corresponding to the list of strings
% given in parameter
% In:
%   match      list of utterances to match (read from xls)
%   filename   filename from which to extract data
%   worksheet  worksheet of the xls from which to extract
%   range      range in which to read the data
function  match_data = extractData(match, filename, worksheet, range)
% Initialise empty output
match_data = [];

% num : numeric data in the xls
[num,all_utt,raw] = xlsread(filename,worksheet,range);

% Convert the text into array of char
match = char(match);
all_utt = char(all_utt);

for i = 1:length(match)
    for j = 1:length(all_utt)
        % For ERJ : match the first 14 characters
        % For native : match the first 15 characters
        if isequal(all_utt(j,1:15),match(i,1:15))
            % data_range = ['B' int2str(j+1) ':' 'Z' int2str(j+1)];
            match_line = num(j,:);
            match_data = cat(1,match_data,match_line);
        end
    end
end

end
