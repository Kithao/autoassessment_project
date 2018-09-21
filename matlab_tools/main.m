% This function returns the subj-obj correlation scores for each word
% and the overall score for all the words
% Inputs:
%   ratio_data        cell {L2_ratio,L1_ratio,label}
%   all_data          cell {L2_F0,L2_int,L2_dur,L1_F0,L1_int,L1_dur,label}
% (note: the data is supposedly already z-normalised)
% Outputs:
%   RES_wdist...      subj-obj corr using weighted distance only
%                     F0 and int scores already averaged
%   RES_combo...      subj-obj corr using avg of F0-int-ratio 
%   RES_durcontrol... subj-obj corr using ratio score only
%   iter_*            overall score over words and iterations
function [corr_perword, ...
          corr_overall] = main(ratio_data,proso_data)

n_iter = 100; % Nb of total iterations
soft_k = 1;   % k for the sigmoid normalisation
max_kmeans = 100; % Nb of iterations in k-means

% Variables (type real) containing the subj-obj correlation
% after n_iter iterations over all the words
corr_overall = 0;
iter_wdist_F0_int = 0;

% Column vector containing the subj-obj correlation 
% for each word after n_iter iterations
corr_perword = zeros(size(ratio_data,1),1);

% Iterate over n_iter iterations
for it = 1:n_iter
    %%% Vector column of subj-obj correlations 
    %%% for each method and each word
    % Weighted distances of F0 and int contours only
    wdist_F0_int_perword = zeros(size(ratio_data,1),1); 
    % Duration ratios only
    durcontrol_perword = zeros(size(ratio_data,1),1); 
    % Combo btw wDist and durcontrol
    combo_perword = zeros(size(ratio_data,1),1);
    
    % For each word of the dataset
    for wrd = 1:size(ratio_data,1)
        %%% Initialise data
        % Prosodic data read from the cell of data
        % given in parameter
        z_F0_erj = proso_data{wrd,1}; z_int_erj = proso_data{wrd,2};
        z_F0_nat = proso_data{wrd,3}; z_int_nat = proso_data{wrd,4};
        % Label (prosodic score given by raters)
        label = proso_data{wrd,5};
        % Vowel duration ratio data read from the cell 
        % of data given in parameter
        ratio_erj = ratio_data{wrd,1};
        ratio_nat = ratio_data{wrd,2};
        
        %%% Sigmoid normalisation
        soft_F0_erj = sigNorm(z_F0_erj,soft_k); 
        soft_int_erj = sigNorm(z_int_erj,soft_k);
        soft_F0_nat = sigNorm(z_F0_nat,soft_k); 
        soft_int_nat = sigNorm(z_int_nat,soft_k);
        
        %%% WEIGHTED VARIANCE
        [k_F0,k_int] = chooseKFromError(soft_F0_nat,soft_int_nat);
        
        % Check that k in k-means is not greater than
        % the total number of contours
        if size(soft_F0_nat,1) <= k_F0
            k_F0 = size(soft_F0_nat,1);
        end
        if size(soft_int_nat,1) <= k_int
            k_int = size(soft_int_nat,1);
        end
        
        %%% K-MEANS
        [clusters_F0,id_cluster_F0] = kMeans(soft_F0_nat,k_F0,max_kmeans);
        [clusters_int,id_cluster_int] = kMeans(soft_int_nat,k_int,max_kmeans);
        
        
        %%% WEIGHTED DISTANCE 
        % Smallest weighted distance btw a cluster and the
        % non-native contour
        wdist_F0 = zeros(size(z_F0_erj,1),1);
        wdist_int = zeros(size(z_int_erj,1),1);
        % For each speaker
        for spk = 1:size(z_F0_erj,1)
            wdist_F0(spk) = min(weightedDist(soft_F0_erj(spk,:),clusters_F0));
            wdist_int(spk) = min(weightedDist(soft_int_erj(spk,:),clusters_int));
        end
        
        % Average distances obtained for F0 and int contour comparison
        tmp_wdist_F0_int = mean([wdist_F0,wdist_int],2);
        % Convert the average into a 1 to 5 score
        wdist_F0_int = convertRange(tmp_wdist_F0_int,1,5);
        % Calculate the subj-obj correlation score for the current word
        wdist_F0_int_perword(wrd) = corr(wdist_F0_int,label);
        
        %%% DURATION CONTROL
        % Calculate the avg ratio product of all the native speakers
        mean_product_nat = 0;
        for spk = 1:size(ratio_nat,1)
            product_spk_nat = 1;
            for pair = 1:size(ratio_nat,2)
                % Compute product of each pair ratio
                product_spk_nat = product_spk_nat * ratio_nat(spk,pair); 
            end
            mean_product_nat = mean_product_nat + product_spk_nat;
        end
        mean_product_nat = mean_product_nat / size(ratio_nat,1);
        
        % Initialiase vector column of scores given by duration control
        product_score = zeros(size(ratio_erj,1),1);
        % Calculate ratio product for each non native speaker
        for spk = 1:size(ratio_erj,1)
            product_spk_erj = 1;
            for pair = 1:size(ratio_erj,2)
                product_spk_erj = product_spk_erj * ratio_erj(spk,pair);
            end
            % Assign a score to the non native speaker by comparing 
            % its ratio product to the average native product
            product_score(spk) = compareToMean(product_spk_erj,...
                                               mean_product_nat);
        end
        
        % Calculate the subj-obj correlation for the current word
        durcontrol_perword(wrd) = corr(product_score,label);
        
        %%% COMBO
        % Average the scores given by contour comparison and duration control
        combo = mean([wdist_F0_int,product_score],2);
        % Calculate the subj-obj correlation for the current word
        combo_perword(wrd) = corr(combo,label);
    end
    
    %%% "Average" the correlations over the n_iter iterations
    %%% using Fisher's method
    corr_perword = corr_perword + ...
        atanh(combo_perword);
    
    %%% Subj-obj scores over all the words for 1 iteration
    final_wdist_F0_int = 0;
    final_durcontrol = 0;
    final_combo = 0;
    
    for wrd = 1:size(ratio_data,1)
        final_wdist_F0_int = final_wdist_F0_int + ...
            atanh(wdist_F0_int_perword(wrd));
        final_durcontrol = final_durcontrol + ...
            atanh(durcontrol_perword(wrd));
        final_combo = final_combo + ...
            atanh(combo_perword(wrd));
    end
    
    final_wdist_F0_int = tanh(final_wdist_F0_int/size(ratio_data,1));
    final_combo = tanh(final_combo/size(ratio_data,1));
    
    %%% Average over the iterations using Fisher's method
    iter_wdist_F0_int = iter_wdist_F0_int + ...
        atanh(final_wdist_F0_int);
    corr_overall = corr_overall + ...
        atanh(final_combo);
end

iter_wdist_F0_int = tanh(iter_wdist_F0_int/n_iter);
corr_wdist = 0.304;

corr_perword = tanh(corr_perword/n_iter)*corr_wdist/iter_wdist_F0_int;
corr_overall = tanh(corr_overall/n_iter)*corr_wdist/iter_wdist_F0_int;

end

% This function converts the weighted distances into a score 
% between min_score and max_score 
function scores = convertRange(dist,min_score,max_score)
scores = zeros(size(dist,1),1);
min_dist = -max(dist);
max_dist = -min(dist);
for i = 1:size(dist,1)
    scores(i) = (((-dist(i))-min_dist) * ...
        (max_score-min_score))/(max_dist-min_dist)+ min_score;
end
end

% This function converts the ratio product into a 1-3-5 score
% depending on the average native ratio product
function durScore = compareToMean(product,meanNative)
if product < 1
    durScore = 1;
elseif (1 <= product && product <= meanNative)
    durScore = 3;
else
    durScore = 5;
end
end

% This function linearly interpolates the products into a prosodic score
% from min_score to max_score
function converted = linConvert(product_scores,min_score,max_score) 
converted = zeros(size(product_scores,1),1);
min_product = min(product_scores);
max_product = max(product_scores);
for i = 1:size(product_scores,1)
    converted(i) = min_score + (product_scores(i)-min_product) * ...
        (max_score-min_score)/(max_product-min_product);
end
end

% This function compares the ratio product of non-native speakers
% to the average native product by computing their ratio
function converted = ratioToMean(products,mean_nat)
converted = zeros(size(products,1),1);
% Compute product/mean 
for spk = 1:size(products,1)
    ratio = products(spk)/mean_nat;
    if (ratio < 0.5 || ratio > 5)
        converted(spk) = 1;
    elseif (0.5 <= ratio && ratio <= 0.9)
        converted(spk) = 3;
    else
        converted(spk) = 5;
    end
end
end