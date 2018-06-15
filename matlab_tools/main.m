% Excel file of native prosodic data
% prosodic_native = 'prosodic_data_all_native.xlsx';
% prosodic_erj = 'prosodic_data_all_erj.xlsx';
% worksheet_F0 = 'F0';
% worksheet_int = 'int';
% worksheet_F0_z = 'z_F0';
% worksheet_int_z = 'z_int';
% cell_range_spk_native = 'A2:A1233';
% cell_range_native = 'A2:Z1233';
% cell_range_spk_erj = 'A2:A39273';
% cell_range_erj = 'A2:Z39273';

%%% Normalise data
% F0_z_native_all = zNormSpk(prosodic_native, worksheet_F0, cell_range_native);
% F0_z_erj_all = zNormSpk(prosodic_erj, worksheet_F0, cell_range_erj);
% int_z_native_all = zNormSpk(prosodic_native, worksheet_int, cell_range_native);
% int_z_erj_all = zNormSpk(prosodic_erj, worksheet_int, cell_range_erj);

%%% Extract only data corresponding to ERJ words
% uttlist_erj = readTxt(prosodic_erj,'uttlist_erj','A1:A910');
% F0_z_erj = extractData(uttlist_erj,prosodic_erj,worksheet_F0_z,cell_range_erj);
% int_z_erj = extractData(uttlist_erj, prosodic_erj,worksheet_int_z,cell_range_erj);
% uttlist_native = readTxt(prosodic_native,'uttlist_native','A1:A504');
% F0_z_native = extractData(uttlist_native,prosodic_native,worksheet_F0_z,cell_range_native);
% int_z_native = extractData(uttlist_native,prosodic_native,worksheet_int_z,cell_range_native);

prosodic_native = 'prosodic_data_native.xlsx';
prosodic_erj = 'prosodic_data_erj.xlsx';
worksheet_F0_z = 'z_F0';
worksheet_int_z = 'z_int';
worksheet_dur = 'duration';
erj_range = 'B2:Z911';
erj_range_match = 'AB2:AB911';
native_range = 'B2:Z505';
native_match = 'AA2:AA505';
wordList = readTxt(prosodic_native,'wordList','I1:I36');
outExcel = 'prosodic_perword_erj.xlsx';

% writeInExcel(wordList,prosodic_native,worksheet_dur,native_match,native_range,outExcel);

% Header for native
[num,header_native,raw] = xlsread(prosodic_native,worksheet_F0_z,'A1:BY1');
wordList = char(wordList);
for i = 1:length(wordList)
    word = wordList(i,1:16);
    xlswrite(outExcel,raw,word,'A1');
end

% Read text data contianed in specified range
% from excel sheet
function txt = readTxt(filename, worksheet, range)
[num,txt,raw] = xlsread(filename,worksheet,range);
end