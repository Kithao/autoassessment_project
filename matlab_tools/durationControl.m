% This function returns the subj-obj correlation scores for each word
% and the overall score for all the words
% Inputs:
%   ratio_data        cell {L2_ratio,L1_ratio,label}
%   all_data          cell {L2_F0,L2_int,L2_dur,L1_F0,L1_int,L1_dur,label}
% Outputs:
%   RES_wdist...      subj-obj corr using weighted distance only
%                     F0 and int scores already averaged
%   RES_combo...      subj-obj corr using avg of F0-int-ratio 
%   RES_durcontrol... subj-obj corr using ratio score only
%   iter_*            overall score over words and iterations
function [RES_wdist_F0_int_perword, ...
          RES_combo_perword, ...
          RES_durcontrol_perword, ...
          iter_wdist_F0_int, ...
          iter_combo, ...
          iter_durcontrol] = durationControl(ratio_data,all_data)

n_iter = 100;
soft_k = 1;
max_kmeans = 100;

iter_wdist_F0_int = 0;
iter_durcontrol = 0;
iter_combo = 0;

% Subj-obj correlation for each word after n_iter iterations
RES_wdist_F0_int_perword = zeros(size(ratio_data,1),1);
RES_durcontrol_perword = zeros(size(ratio_data,1),1);
RES_combo_perword = zeros(size(ratio_data,1),1);

for it = 1:n_iter
    % Weighted distances
    wdist_F0_int_perword = zeros(size(ratio_data,1),1); 
    % Duration control 
    durcontrol_perword = zeros(size(ratio_data,1),1); 
    % Combo btw wDist and durcontrol
    combo_perword = zeros(size(ratio_data,1),1);
    
    %%% For each word of the dataset
    for wrd = 1:size(ratio_data,1)
        %%% Prosodic data
        z_F0_erj = all_data{wrd,1}; z_int_erj = all_data{wrd,2};
        z_F0_nat = all_data{wrd,4}; z_int_nat = all_data{wrd,5};
        %%% Label
        label = all_data{wrd,7};
        %%% Vowel ratio data
        ratio_erj = ratio_data{wrd,1};
        ratio_nat = ratio_data{wrd,2};
        
         %%% Softmax
        soft_F0_erj = softmaxNorm(z_F0_erj,soft_k); 
        soft_int_erj = softmaxNorm(z_int_erj,soft_k);
        soft_F0_nat = softmaxNorm(z_F0_nat,soft_k); 
        soft_int_nat = softmaxNorm(z_int_nat,soft_k);
        
        %%% K-means
        [k_F0,k_int] = chooseKFromError(soft_F0_nat,soft_int_nat);
        
        if size(soft_F0_nat,1) <= k_F0
            k_F0 = size(soft_F0_nat,1);
        end
        if size(soft_int_nat,1) <= k_int
            k_int = size(soft_int_nat,1);
        end
        [clusters_F0,id_cluster_F0] = kMeans(soft_F0_nat,k_F0,max_kmeans);
        [clusters_int,id_cluster_int] = kMeans(soft_int_nat,k_int,max_kmeans);
        
        %%% WDIST
        wdist_F0 = zeros(size(z_F0_erj,1),1);
        wdist_int = zeros(size(z_int_erj,1),1);
        % Iterate over each speaker
        for spk = 1:size(z_F0_erj,1)
            wdist_F0(spk) = min(weightedDist(soft_F0_erj(spk,:),clusters_F0));
            wdist_int(spk) = min(weightedDist(soft_int_erj(spk,:),clusters_int));
        end
        
        tmp_wdist_F0_int = mean([wdist_F0,wdist_int],2);
        wdist_F0_int = convertRange(tmp_wdist_F0_int,1,5);
        wdist_F0_int_perword(wrd) = corr(wdist_F0_int,label);
        
        %%% DURATION CONTROL
        % Mean pair product of native speakers
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
        % Vector of scores given by duration control
        product_score = zeros(size(ratio_erj,1),1);
%         product_allspk = zeros(size(ratio_erj,1),1);
        for spk = 1:size(ratio_erj,1)
            product_spk_erj = 1;
            for pair = 1:size(ratio_erj,2)
                % Compute product of each pair ratio
                product_spk_erj = product_spk_erj * ratio_erj(spk,pair);
            end
%             product_allspk(spk) = product_spk_erj;
            product_score(spk) = compareToMean(product_spk_erj,...
                                               mean_product_nat);
        end
%         product_score = linConvert(product_allspk,1,5);
%             product_score = ratioToMean(product_allspk,mean_product_nat);
        
        durcontrol_perword(wrd) = corr(product_score,label);
        
        %%% COMBO
        combo = mean([wdist_F0_int,product_score],2);
        combo_perword(wrd) = corr(combo,label);
    end
    
    RES_wdist_F0_int_perword = RES_wdist_F0_int_perword + ...
        atanh(wdist_F0_int_perword);
    RES_durcontrol_perword = RES_durcontrol_perword + ...
        atanh(durcontrol_perword);
    RES_combo_perword = RES_combo_perword + ...
        atanh(combo_perword);
    
    %%% Subj-obj scores for 1 iter
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
    final_durcontrol = tanh(final_durcontrol/size(ratio_data,1));
    final_combo = tanh(final_combo/size(ratio_data,1));
    
     %%% Average over iterations
    iter_wdist_F0_int = iter_wdist_F0_int + ...
        atanh(final_wdist_F0_int);
    iter_durcontrol = iter_durcontrol + ...
        atanh(final_durcontrol); 
    iter_combo = iter_combo + ...
        atanh(final_combo);
end

RES_wdist_F0_int_perword = tanh(RES_wdist_F0_int_perword/n_iter);
RES_durcontrol_perword = tanh(RES_durcontrol_perword/n_iter);
RES_combo_perword = tanh(RES_combo_perword/n_iter);

iter_wdist_F0_int = tanh(iter_wdist_F0_int/n_iter);
iter_durcontrol = tanh(iter_durcontrol/n_iter);
iter_combo = tanh(iter_combo/n_iter);

end

function scores = convertRange(dist,min_score,max_score)
scores = zeros(size(dist,1),1);
min_dist = -max(dist);
max_dist = -min(dist);
for i = 1:size(dist,1)
    scores(i) = (((-dist(i))-min_dist) * ...
        (max_score-min_score))/(max_dist-min_dist)+ min_score;
end
end

function durScore = compareToMean(product,meanNative)
if product < 1
    durScore = 1;
elseif (1 <= product && product <= meanNative)
    durScore = 3;
else
    durScore = 5;
end
end

% Convert product of ratios into scores on a linear scale
function converted = linConvert(product_scores,min_score,max_score) 
converted = zeros(size(product_scores,1),1);
min_product = min(product_scores);
max_product = max(product_scores);
for i = 1:size(product_scores,1)
    converted(i) = min_score + (product_scores(i)-min_product) * ...
        (max_score-min_score)/(max_product-min_product);
end
end

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