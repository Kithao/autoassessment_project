% This function imports prosodic data from the excel files
% function [F0_nnat,int_nnat,dur_nnat,...
%           F0_nat,int_nat,dur_nat,...
%           label] = importData()
function all_data = importData()      
prosody_nat = 'prosodic_perword_handseg_native.xlsx';
prosody_erj = 'prosodic_perword_handseg_erj.xlsx';
word_list = char(readTxt('prosodic_data_native.xlsx','wordList','I1:I36'));
range_F0 = 'B2:Z30'; 
range_int = 'AA2:AY30';
range_dur = 'AZ2:BX30';
range_label = 'BY2:BY30';

%%% Read all data and store it in cell
all_data = cell(size(word_list,1),7);

for i = 1:size(word_list,1)
    F0_nnat = xlsread(prosody_erj,word_list(i,:),range_F0);
    int_nnat = xlsread(prosody_erj,word_list(i,:),range_int);
    dur_nnat = xlsread(prosody_erj,word_list(i,:),range_dur);
    F0_nat = xlsread(prosody_nat,word_list(i,:),range_F0);
    int_nat = xlsread(prosody_nat,word_list(i,:),range_int);
    dur_nat = xlsread(prosody_nat,word_list(i,:),range_dur);
    label = xlsread(prosody_erj,word_list(i,:),range_label);
    all_data(i,1:7) = {F0_nnat,int_nnat,dur_nnat, ...
                       F0_nat,int_nat,dur_nat, ...
                       label};
end   
end

% Read text data contained in specified range
% from excel sheet
function txt = readTxt(filename, worksheet, range)
[num,txt,raw] = xlsread(filename,worksheet,range);
end