function [M,S] = omitZeroStats(X)
[m,n] = size(X);
M = 0;
S = 0;
count = 0; % number of non-zero values

% Convert all NaN to 0
X(isnan(X))=0;

for i = 1:m
    for j = 1:n
        if X(i,j) ~= 0
            M = M + X(i,j);
            count = count + 1;
        end            
    end
end

M = M/count;

for i = 1:m
    for j = 1:n
        if X(i,j) ~= 0
            S = S+(X(i,j)-M)*(X(i,j)-M);
        end            
    end
end

S = sqrt(S/count);

end