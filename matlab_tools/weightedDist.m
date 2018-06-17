% This function calculates the weighted distance between 2 prosodic
% contours using a linear weight
% target : non native (matrix)
% origin : cluster (matrix of all clusters)
% d : vector of weighted distances from each cluster
function d = weightedDist(target, origin)
[m,n] = size(origin);
d = zeros(m,1);
% min_avg = min(target);

for i = 1:m
    sum_weigthed_error = 0;
    
    for j = 1:n
%         error = (target(j)-origin(i,j))*(target(j)-origin(i,j));
        error = sum((target(j) - origin(i,j)) .^2);
        weight = linearWeight(origin(i,j),min(origin(i,:)),max(origin(i,:)));
%         weight = linearWeight(target(j),min(target),max(target));
%         weight = sigmoidWeight(origin(i,j),max(origin(i,:)));
        sum_weigthed_error = sum_weigthed_error + error * weight;
    end
    d(i,1) = sqrt(sum_weigthed_error);
%     d(i,1) = sum_weigthed_error;
end

end

% Returns a weigth proportional to the input value
% min: where weight is min ie min feature
% max: where weight is max ie max feature
% min_weight < w < 1
function w = linearWeight(x,min,max)
% w = (0.5/max)*x+0.5;
min_weight = 0.5;
max_weight = 1;
w = (x*(max_weight-min_weight)/max) + min_weight;

end