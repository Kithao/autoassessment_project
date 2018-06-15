% This function writes in the outfile the data found in the infile
% and sorts them according to the word it corresponds to

function writeInExcel(wordlist, ...
    infile,insheet,inrangematch,inrangedata, ...
    outfile)
% Conversts the list into characters
wordlist = char(wordlist);
[num,match,raw] = xlsread(infile,insheet,inrangematch);
[num2,data,rawdata] = xlsread(infile,insheet,inrangedata);
match = char(match);

for i = 1:length(wordlist)
    word_data_complete = [];
    word = wordlist(i,1:16);
    for j = 1:length(match)
        if isequal(wordlist(i,1:16),match(j,1:16))
            % word_data = num(j,:);
            word_data = rawdata(j,:);
            word_data_complete = cat(1,word_data_complete,word_data);
        end
    end
    % For F0
    % xlswrite(outfile,word_data_complete,word,'A2');    
    xlswrite(outfile,word_data_complete,word,'AZ2');    
end

end
