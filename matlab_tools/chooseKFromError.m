% Converts variance between contours into a number of clusters
% Variance = Error between pairs / nb of pairs
% Nb of clusters = from 1 to nb utterances / 2
% Interpolate between min and max error in a pair
% (ie the higher the variance is, the greater k will be)
function [k_F0,k_int] = chooseKFromError(F0,Int)
% Total within contour variance
var_F0 = 0;
var_int = 0;

% Initialise min and max error between 2 contours
% with the error between 2 random contours (the 2 first ones in the list) 
min_err_F0 = sum((F0(1,:) - F0(2,:)) .^ 2);
max_err_F0 = sum((F0(1,:) - F0(2,:)) .^ 2);
min_err_int = sum((Int(1,:) - Int(2,:)) .^ 2);
max_err_int = sum((Int(1,:) - Int(2,:)) .^ 2);

nb_pairs = 0;

% Calculate the error between each pair of contours
for i = 1:(size(F0,1)-1)
    for j = (i+1):size(F0,1)
        % Weighted error between F0 contour i and F0 contour j
        err_F0_tmp = sum((F0(i,:) - F0(j,:)) .^ 2);
        weight_F0 = linearWeight(F0(i,j),min(F0(i,:)),max(F0(i,:)));
        err_F0 = err_F0_tmp * weight_F0;
        var_F0 = var_F0 + err_F0;
        % Update the values of min and max error between 2 contours
        if err_F0 < min_err_F0
            min_err_F0 = err_F0;
        end
        if err_F0 > max_err_F0
            max_err_F0 = err_F0;
        end
        
        % Weighted error between int contour i and int contour j
        err_int_tmp = sum((Int(i,:) - Int(j,:)) .^ 2);
        weight_int = linearWeight(Int(i,j),min(Int(i,:)),max(Int(i,:)));
        err_int = err_int_tmp * weight_int;
        var_int = var_int + err_int;
        % Update the values of min and max error between 2 contours
        if err_int < min_err_int 
            min_err_int = err_int;
        end
        if err_int > max_err_int
            max_err_int = err_int;
        end
        
        nb_pairs = nb_pairs + 1;
    end
end

% Calculate the variance: average error between each pair
% of contours of the set
var_F0 = var_F0/nb_pairs;
var_int = var_int/nb_pairs;

% Determine the lower and upper limit for k
min_k = 1;
max_k = fix(size(F0,1)/2); % no more than half the total nb of contours

% Linearly interpolate the variance between min_k and max_k
k_F0 = fix(min_k + (var_F0 - min_err_F0)*(max_k - min_k)/(max_err_F0 - min_err_F0));
k_int = fix(min_k + (var_int - min_err_int)*(max_k - min_k)/(max_err_int - min_err_int));

end

% Returns a weight proportional to the input value
% min: where weight is min ie min feature
% max: where weight is max ie max feature
% min_weight < w < 1
function w = linearWeight(x,min,max)
min_weight = 0.5;
max_weight = 1;
w = (x*(max_weight-min_weight)/max) + min_weight;
end