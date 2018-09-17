% This function calculates the weighted distance between 2 prosodic
% contours. The weight at one point is linearly dependent on the value 
% of the contour at this point
% target : non native (matrix)
% origin : cluster (matrix of all clusters)
% d : vector of weighted distances from each cluster
function d = weightedDist(target, origin)
[m,n] = size(origin);
d = zeros(m,1);

for i = 1:m
    sum_weigthed_error = 0;
    
    for j = 1:n
        error = sum((target(j) - origin(i,j)) .^2);
        weight = linearWeight(origin(i,j),min(origin(i,:)),max(origin(i,:)));
        sum_weigthed_error = sum_weigthed_error + error * weight;
    end
    d(i,1) = sqrt(sum_weigthed_error);
end

end

% Returns a weigth proportional to the input value
% min: where weight is min ie min feature
% max: where weight is max ie max feature
% min_weight < w < 1
function w = linearWeight(x,min,max)
min_weight = 0.5;
max_weight = 1;
w = (x*(max_weight-min_weight)/max) + min_weight;
end