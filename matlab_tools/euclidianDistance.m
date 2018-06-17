% Computes Euclidian distance between target and origin
% Inputs:
%   target    vector to which distances have to be calculated (mean)
%   origin    matrix of values from which to calculate distances
% Output:
%   d         vector of Euclidian distances
function d = euclidianDistance(target, origin)
d = zeros(size(origin,1),1);

for i = 1:size(origin,1)
    V = target - origin(i,:);
    euclidDist = sqrt(V * V');
    d(i,1) = euclidDist;
end
end