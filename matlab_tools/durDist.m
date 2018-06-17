% This function calculates the weighted distance between 2 prosodic
% contours using durations as weights
% nonnative : non native contour (matrix)
% cluster : cluster to which distance is calculated (one vector)
% id_cluster : index of contours in the cluster
% dur : matrix of durations from where to extract weights
function d = durDist(nonnative,cluster,id_cluster,dur)
[n_cluster,n_sample] = size(cluster);
d = zeros(n_cluster,1);
 
durWeights = extractDur(cluster,id_cluster,dur);

for i = 1:n_cluster
    sum_weighted_error = 0;
    for j = 1:n_sample
        error = sum((nonnative(j)-cluster(i,j)).^2);
        if durWeights(i,j) ~= 0
            weight = 1 + durWeights(i,j);
        else
            weight = 1;
        end
%         weight = 1 + durWeights(i,j);
        sum_weighted_error = sum_weighted_error + error * weight;
    end
    d(i,1) = sqrt(sum_weighted_error);
end

end

% Extracts the mean duration for each cluster
function durWeights = extractDur(cluster,id_cluster,dur)
durWeights = zeros(size(cluster));
for clusteri = 1:size(cluster,1)
    durWeights(clusteri,:) = mean(dur(id_cluster==clusteri,:));
end
end


