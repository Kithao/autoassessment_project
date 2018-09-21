function Y = softmaxNorm(X, k)
Y = zeros(size(X));
X(isnan(X)) = 0;

for i = 1:size(X,1)
    for j = 1:size(X,2)
%         Y(i,j) = 1+1/(1+exp(-X(i,j))*k);
        %Y(i,j) = 1/(1+exp(-X(i,j))*k) - 0.5;
        Y(i,j) = 1/(1+exp(-X(i,j))*k);
    end
end

end