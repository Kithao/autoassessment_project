% This function calculates the weighted distance between 2 prosodic
% contours using the prosodic value as weight
% Segments that have a zero duration (i.e. not vowels) have no weight
% nonnative : non native contour (vector)
% cluster : cluster to which distance is calculated (matrix)
% id_cluster : index of contours in the cluster
% dur : matrix of durations from where to extract weights
function d = wdurDist(nonnative,cluster,id_cluster,dur)
[n_cluster,n_sample] = size(cluster);
d = zeros(n_cluster,1);
 
avg_dur = extractDur(cluster,id_cluster,dur);

for i = 1:n_cluster
    sum_weighted_error = 0;
    for j = 1:n_sample
        error = sum((nonnative(j)-cluster(i,j)).^2);
        if avg_dur(i,j) ~= 0
            % Add proportional weight where the duration is non zero
%             weight = 1+linearWeight(cluster(i,j),...
%                                     max(cluster(i,:)));
            weight = 1+linearWeight(cluster(i,j),...
                                    max(cluster(i,:)));
        else
            weight = 1;
        end
        sum_weighted_error = sum_weighted_error + error * weight;
    end
    d(i,1) = sqrt(sum_weighted_error);
end
end

% Extracts the mean duration for each cluster
function avg_dur = extractDur(cluster,id_cluster,dur)
avg_dur = zeros(size(cluster));
for clusteri = 1:size(cluster,1)
    avg_dur(clusteri,:) = mean(dur(id_cluster==clusteri,:));
end
end

% Returns a weigth proportional to the input value
% min: where weight is min ie min feature
% max: where weight is max ie max feature
% min_weight < w < 1
function w = linearWeight(x,max)
% w = (0.5/max)*x+0.5;
min_weight = 0;
max_weight = 0.5;
w = (x*(max_weight-min_weight)/max) + min_weight;
end

