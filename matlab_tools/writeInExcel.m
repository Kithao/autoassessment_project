% This function writes in an output file the data found in the 
% input file and sorts the data by writing them in separate sheets
% corresponding to each word
% Note: make sure the word match list is sorted alphabetically
% Inputs:
%   wordlist      list of unique words (each word will generate a separate 
%                 sheet in Excel)
%   infile        Excel file from where the data is read
%   insheet       Excel sheet from where the data is read
%   inrangematch  column where the corresponding word of each line is
%                 written (usually last column)
%   inrangedata   range of cells where the data is read
% 
% Format of the excel sheet
% <filename_i> <F0_1_i> <F0_2_i> ... <F0_25_i> <word_i>
%      |           |        |             |        |
% <filename_j> <F0_1_j> <F0_2_j> ... <F0_25_j> <word_j>                    
%                  |______________________|        |
%                         inrangedata         inrangematch
% Note: Make sure the inrangematch is alphabetically sorted
% otherwise the function will not behave correctly
% (do this in Excel)
function writeInExcel(wordlist, ...
    infile,insheet,inrangematch,inrangedata, ...
    outfile)
% Converts the list into characters
wordlist = char(wordlist);
[num,match,raw] = xlsread(infile,insheet,inrangematch);
[num2,data,rawdata] = xlsread(infile,insheet,inrangedata);
match = char(match);

for i = 1:length(wordlist)
    word_data_complete = [];
    word = wordlist(i,1:16);
    for j = 1:length(match)
        if isequal(wordlist(i,1:16),match(j,1:16))
            word_data = rawdata(j,:);
            word_data_complete = cat(1,word_data_complete,word_data);
        end
    end
    % For F0
%     xlswrite(outfile,word_data_complete,word,'A2');
    % For int
%     xlswrite(outfile,word_data_complete,word,'AA2');
    % For dur
%     xlswrite(outfile,word_data_complete,word,'AZ2');  
    % For label
%     xlswrite(outfile,word_data_complete,word,'BY2');    
    % For duration ratios
    xlswrite(outfile,word_data_complete,word,'A35');
end
end
