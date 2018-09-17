% This script calculates the mean and standard
% deviation of the data without counting undefined values
% (undetermined F0 and intensity)
% Input:
%   X    matrix of values for which to calculate the stats
% Outputs:
%   M    mean value of X
%   S    standard deviation of X  
function [M,S] = omitZeroStats(X)
[m,n] = size(X);
M = 0;
S = 0;
count = 0; % number of non-zero values

% Convert all NaN to 0 if it is not already done
% Note: if a whole line or column is full of NaN
%       the line/column is automatically deleted
%       To avoid this problem, insert a zero at one
%       of the undetermined value
X(isnan(X))=0;

for i = 1:m
    for j = 1:n
        if X(i,j) ~= 0
            M = M + X(i,j);
            count = count + 1;
        end
    end
end

% Mean value
M = M/count;

for i = 1:m
    for j = 1:n
        if X(i,j) ~= 0
            S = S+(X(i,j)-M)*(X(i,j)-M);
        end            
    end
end

% Standard deviation
S = sqrt(S/count);

end