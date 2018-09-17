% This script z-normalises raw data at the speaker level
% Inputs:
%  filename     excel file
%  worksheet    sheet name
%  cell_range   boundaries of the cells to read in the excel file
% Output:
%  complete_z   z-normalised data
% Format of the excel sheet
% <filename> <value_1> ... <value_25>
%     |          |_____________|
%  spk_list            num
function complete_z = zNormSpk(filename, worksheet, cell_range)
complete_z = []; % matrix of all values
% num : numerical values in the xls file
% spk_list : txt (list of speakers)
[num,spk_list,raw] = xlsread(filename, worksheet, cell_range);

% Cluster each speaker together
nb_spk = 1;
same_spk = 1;
% Convert speaker list into array of char
spk_list = char(spk_list);

for i = 1:(length(spk_list)-1)
    % Check if first characters are the same
    % 10 characters for native
    % 7 characters for erj
    % (i.e. same speaker)
    if isequal(spk_list(i+1,1:10), spk_list(i,1:10))
        same_spk = same_spk+1;
        if i == (length(spk_list)-1)
            if nb_spk == 1
                first_index = i-same_spk+1;
                last_index = i;
            else
                first_index = i-same_spk+2;
                last_index = i+1;
            end
            data = num(first_index:last_index,:);
            % Z normalise values
            [mean,std] = omitZeroStats(data);
            z_data = zNorm(data,mean,std);
            % Store new values
            complete_z = cat(1,complete_z,z_data);
        end
    else
        % Once a new speaker is detected, z norm
        % values on the previous speaker and 
        % reallocate same spk vector to new speaker
        if same_spk == 1
            first_index = i;
            last_index = i;
        else
            first_index = i-same_spk+1;
            last_index = i;
        end
        % Read data for one speaker
        data = num(first_index:last_index,:);
        % Z normalise values
        [mean,std] = omitZeroStats(data);
        z_data = zNorm(data,mean,std);
        % Store new values
        complete_z = cat(1,complete_z,z_data);
        
        % Reinitialise values
        same_spk = 1;
        nb_spk = nb_spk+1;
    end
end
end

% This function z-normalises a population of values
% Inputs: 
%    X    matrix with raw values
%    M    mean
%    S    standard deviation
% Outputs:
%    Y    matrix with z-normalised values
function Y = zNorm(X,M,S)
[m,n] = size(X);
Y = zeros(size(X));
% M = mean2(X);
% S = std2(X);

for i = 1:m
    for j = 1:n
        if (X(i,j)~=0 && ~isnan(X(i,j)))
            Y(i,j) = (X(i,j)-M)/S;
        end
    end
end
end