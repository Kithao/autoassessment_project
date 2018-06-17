function [centroids,indices] = kMeans(X, K, max_iterations)
indices = [];
if (size(X,1) == 2 && K == 2)
    centroids = X;
    indices = [1;2];
elseif K == 1
    centroids = mean(X);
    indices = ones(size(X,1),1);
elseif K == size(X,1)
    centroids = X;
    indices = zeros(size(X,1),1);
    for i = 1:size(X,1)
        indices(i,1) = i;
    end
else
    centroids = initCentroids(X, K);

    for i=1:max_iterations
      indices = getClosestCentroids(X, centroids);
      centroids = computeCentroids(X, indices, K);
    end
end
end

function centroids = initCentroids(X,K)
% centroids = zeros(K,size(X,2)); 
randidx = randperm(size(X,1));
centroids = X(randidx(1:K), :);
end

function indices = getClosestCentroids(X, centroids)
K = size(centroids, 1);
indices = zeros(size(X,1), 1);
m = size(X,1);

for i=1:m
    k = 1;
    min_dist = sum((X(i,:) - centroids(1,:)) .^ 2);
    for j=2:K
        dist = sum((X(i,:) - centroids(j,:)) .^ 2);
        if(dist < min_dist)
          min_dist = dist;
          k = j;
        end
    end
    indices(i) = k;
end
end

function centroids = computeCentroids(X, idx, K)

% [m,n] = size(X);
n = size(X,2);
centroids = zeros(K, n);

for i=1:K
    xi = X(idx==i,:);    
    if isempty(xi)
        % If the cluster is empty, assign another random centroid
        randidx = randperm(size(X,1));
        centroids(i,:) = X(randidx(1),:);
    else
        ck = size(xi,1);
        if ck == 1
            centroids(i, :) = xi;
        else
            centroids(i, :) = (1/ck) * sum(xi);
        end
    end
%     
%     ck = size(xi,1);
%     centroids(i, :) = (1/ck) * sum(xi);
end
end

