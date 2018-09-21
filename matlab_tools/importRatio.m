% This function imports data from Excel file
function ratio_data = importRatio()
prosody_nat = 'prosodic_perword_handseg_native.xlsx';
prosody_erj = 'prosodic_perword_handseg_erj.xlsx';
[num,word_list,raw] = xlsread('prosodic_perword_handseg_native.xlsx',...
    'wordList','A1:A36');
word_list = char(word_list);

range_ratio = 'B35:F60'; % Durcontrol
% range_label = 'BY2:BY30';

ratio_data = cell(size(word_list,1),2); 

for i = 1:size(word_list,1)
    ratio_erj = xlsread(prosody_erj,word_list(i,:),range_ratio);
    ratio_nat = xlsread(prosody_nat,word_list(i,:),range_ratio);
%     label = xlsread(prosody_erj,word_list(i,:),range_label);
    ratio_data(i,1:2) = {ratio_erj,ratio_nat};
end
end