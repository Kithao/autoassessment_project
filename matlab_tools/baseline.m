%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%                    BASELINE METHODS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_iter = 10;
soft_k = 1;
max_kmeans = 50;
k_fix = 4;
word_list = char(readTxt('prosodic_data_native.xlsx','wordList','I1:I36'));

%%% Average corr per word after n iter for euclidian distance
iter_RES_corr_euclid_F0_perword = zeros(size(word_list,1),1);
iter_RES_corr_euclid_int_perword = zeros(size(word_list,1),1);
iter_RES_corr_euclid_F0_int_perword = zeros(size(word_list,1),1);

%%% Average corr per word after n iter for feature correlation
iter_RES_corr_featcorr_F0_perword = zeros(size(word_list,1),1);
iter_RES_corr_featcorr_int_perword = zeros(size(word_list,1),1);
iter_RES_corr_featcorr_F0_int_perword = zeros(size(word_list,1),1);

iter_final_euclid_F0 = 0;
iter_final_euclid_int = 0;
iter_final_euclid_F0_int = 0;
iter_final_featcorr_F0 = 0;
iter_final_featcorr_int = 0;
iter_final_featcorr_F0_int = 0;

for it = 1:n_iter
    RES_corr_euclid_F0_perword = zeros(length(word_list),1);
    RES_corr_euclid_int_perword = zeros(length(word_list),1);
    RES_corr_euclid_F0_int_perword = zeros(length(word_list),1);

    RES_corr_featcorr_F0_perword = zeros(length(word_list),1);
    RES_corr_featcorr_int_perword = zeros(length(word_list),1);
    RES_corr_featcorr_F0_int_perword = zeros(length(word_list),1);
    
    for i = 1:size(all_data,1)
        z_F0_erj = all_data{i,1}; z_int_erj = all_data{i,2}; 
        dur_erj = all_data{i,3};
        z_F0_nat = all_data{i,4}; z_int_nat = all_data{i,5}; 
        dur_nat = all_data{i,6};
        label = all_data{i,7};

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%                  SIGMOID NORM
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        soft_F0_erj = softmaxNorm(z_F0_erj,soft_k); 
        soft_int_erj = softmaxNorm(z_int_erj,soft_k);
        soft_F0_nat = softmaxNorm(z_F0_nat,soft_k); 
        soft_int_nat = softmaxNorm(z_int_nat,soft_k);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%                  AVERAGE REFERENCES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         clusters_F0 = mean(soft_F0_nat);
%         clusters_int = mean(soft_int_nat);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%               K-MEANS CLUSTERING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [k_F0,k_int] = chooseKFromError(soft_F0_nat,soft_int_nat);
        if (size(soft_F0_nat,1) <= k_F0)
            k_F0 = size(soft_F0_nat,1);
        end
        if (size(soft_F0_nat,1) <= k_int)
            k_int = size(soft_F0_nat,1);
        end
        [clusters_F0,id_cluster_F0] = kMeans(soft_F0_nat,k_F0,max_kmeans);
        [clusters_int,id_cluster_int] = kMeans(soft_int_nat,k_int,max_kmeans);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%                 EUCLIDIAN DISTANCES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        euclid_F0 = zeros(size(z_F0_erj,1),1);
        euclid_int = zeros(size(z_int_erj,1),1);
        for j = 1:size(z_F0_erj,1)
            euclid_F0(j) = min(euclidianDistance(soft_F0_erj(j,:),...
                               clusters_F0));
            euclid_int(j) = min(euclidianDistance(soft_int_erj(j,:),...
                                clusters_int));
        end
        
        %%% Average between F0 and int
        euclid_F0_int = mean([euclid_F0,euclid_int],2);
        
        %%% Correlation between the auto scores and the real ones
        %%% for one word
        RES_corr_euclid_F0_perword(i) = corr(-euclid_F0,label);
        RES_corr_euclid_int_perword(i) = corr(-euclid_int,label);
        RES_corr_euclid_F0_int_perword(i) = corr(-euclid_F0_int,label);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%                 FEATURE CORRELATION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        featcorr_F0 = zeros(size(z_F0_erj,1),1);
        featcorr_int = zeros(size(z_int_erj,1),1);
        for j = 1:size(z_F0_erj,1)
            featcorr_F0(j) = max(correlation(soft_F0_erj(j,:),...
                                 clusters_F0));
            featcorr_int(j) = max(correlation(soft_int_erj(j,:),...
                                  clusters_int));
        end
        
        %%% Average between F0 and int
        featcorr_F0_int = tanh((atanh(featcorr_F0)+atanh(featcorr_int))/2);
        
        %%% Correlation between the auto scores and the real ones
        %%% for one word
        RES_corr_featcorr_F0_perword(i) = corr(featcorr_F0,label);
        RES_corr_featcorr_int_perword(i) = corr(featcorr_int,label);
        RES_corr_featcorr_F0_int_perword(i) = corr(featcorr_F0_int,label);
    end
    
    %%% Average correlation for each word
    iter_RES_corr_euclid_F0_perword = ...
        iter_RES_corr_euclid_F0_perword + ...
        atanh(RES_corr_euclid_F0_perword);
    iter_RES_corr_euclid_int_perword = ...
        iter_RES_corr_euclid_int_perword + ...
        atanh(RES_corr_euclid_int_perword);    
    iter_RES_corr_euclid_F0_int_perword = ...
        iter_RES_corr_euclid_F0_int_perword + ...
        atanh(RES_corr_euclid_F0_int_perword);
    
    iter_RES_corr_featcorr_F0_perword = ...
        iter_RES_corr_featcorr_F0_perword + ...
        atanh(RES_corr_featcorr_F0_perword);
    iter_RES_corr_featcorr_int_perword = ...
        iter_RES_corr_featcorr_int_perword + ...
        atanh(RES_corr_featcorr_int_perword);    
    iter_RES_corr_featcorr_F0_int_perword = ...
        iter_RES_corr_featcorr_F0_int_perword + ...
        atanh(RES_corr_featcorr_F0_int_perword);
    
    %%% Average correlation for all the words
    final_corr_euclid_F0 = 0;
    final_corr_euclid_int = 0;
    final_corr_euclid_F0_int = 0;
    
    final_corr_featcorr_F0 = 0;
    final_corr_featcorr_int = 0;
    final_corr_featcorr_F0_int = 0;
    
    for i = 1:size(word_list,1)
        final_corr_euclid_F0 = final_corr_euclid_F0 + ...
            atanh(RES_corr_euclid_F0_perword(i));
        final_corr_euclid_int = final_corr_euclid_int + ...
            atanh(RES_corr_euclid_int_perword(i));
        final_corr_euclid_F0_int = final_corr_euclid_F0_int + ...
            atanh(RES_corr_euclid_F0_int_perword(i));
        
        final_corr_featcorr_F0 = final_corr_featcorr_F0 + ...
            atanh(RES_corr_featcorr_F0_perword(i));
        final_corr_featcorr_int = final_corr_featcorr_int + ...
            atanh(RES_corr_featcorr_int_perword(i));
        final_corr_featcorr_F0_int = final_corr_featcorr_F0_int + ...
            atanh(RES_corr_featcorr_F0_int_perword(i));
    end
    
    final_corr_euclid_F0 = tanh(...
        final_corr_euclid_F0/size(word_list,1));
    final_corr_euclid_int = tanh(...
        final_corr_euclid_int/size(word_list,1));
    final_corr_euclid_F0_int = tanh(...
    final_corr_euclid_F0_int/size(word_list,1));
    
    final_corr_featcorr_F0 = tanh(...
        final_corr_featcorr_F0/size(word_list,1));
    final_corr_featcorr_int = tanh(...
        final_corr_featcorr_int/size(word_list,1));
    final_corr_featcorr_F0_int = tanh(...
        final_corr_featcorr_F0_int/size(word_list,1));
    
    %%% Over all iterations
    iter_final_euclid_F0 = iter_final_euclid_F0 + ...
        atanh(final_corr_euclid_F0);
    iter_final_euclid_int = iter_final_euclid_int + ...
        atanh(final_corr_euclid_int);
    iter_final_euclid_F0_int = iter_final_euclid_F0_int + ...
        atanh(final_corr_euclid_F0_int);
    
    iter_final_featcorr_F0 = iter_final_featcorr_F0 + ...
        atanh(final_corr_featcorr_F0);
    iter_final_featcorr_int = iter_final_featcorr_int + ...
        atanh(final_corr_featcorr_int);
    iter_final_featcorr_F0_int = iter_final_featcorr_F0_int + ...
        atanh(final_corr_featcorr_F0_int);
end

iter_RES_corr_euclid_F0_perword = tanh(...
    iter_RES_corr_euclid_F0_perword/n_iter);
iter_RES_corr_euclid_int_perword = tanh(...
    iter_RES_corr_euclid_int_perword/n_iter);
iter_RES_corr_euclid_F0_int_perword = tanh(...
    iter_RES_corr_euclid_F0_int_perword/n_iter);

iter_RES_corr_featcorr_F0_perword = tanh(...
    iter_RES_corr_featcorr_F0_perword/n_iter);
iter_RES_corr_featcorr_int_perword = tanh(...
    iter_RES_corr_featcorr_int_perword/n_iter);
iter_RES_corr_featcorr_F0_int_perword = tanh(...
    iter_RES_corr_featcorr_F0_int_perword/n_iter);

iter_final_euclid_F0 = tanh(iter_final_euclid_F0/n_iter);
iter_final_euclid_int = tanh(iter_final_euclid_int/n_iter);
iter_final_euclid_F0_int = tanh(iter_final_euclid_F0_int/n_iter);

iter_final_featcorr_F0 = tanh(iter_final_featcorr_F0/n_iter);
iter_final_featcorr_int = tanh(iter_final_featcorr_int/n_iter);
iter_final_featcorr_F0_int = tanh(iter_final_featcorr_F0_int/n_iter);

% Read text data contained in specified range
% from excel sheet
function txt = readTxt(filename, worksheet, range)
[num,txt,raw] = xlsread(filename,worksheet,range);
end

% Computes correlation coefficient between each line of mat with ref
function y = correlation(ref, mat)
y = zeros(size(mat,1),1);

for i = 1:size(mat,1)
   R = corrcoef(mat(i,:), ref);
   y(i) = R(2,1);
end
end
