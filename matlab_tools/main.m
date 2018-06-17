n_iter = 100;
soft_k = 1;
max_kmeans = 50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%                        READ DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prosody_nat = 'prosodic_perword_native.xlsx';
% prosody_erj = 'prosodic_perword_erj.xlsx';
% word_list = char(readTxt('prosodic_data_native.xlsx','wordList','I1:I36'));
% range_F0 = 'B2:Z30'; 
% range_int = 'AA2:AY30';
% range_dur = 'AZ2:BX30';
% range_label = 'BY2:BY30';

%%% Read all data and store it in cell
% all_data = cell(size(word_list,1),7);
% 
% for i = 1:size(word_list,1)
%     z_F0_erj = xlsread(prosody_erj,word_list(i,:),range_F0);
%     z_int_erj = xlsread(prosody_erj,word_list(i,:),range_int);
%     dur_erj = xlsread(prosody_erj,word_list(i,:),range_dur);
%     z_F0_nat = xlsread(prosody_nat,word_list(i,:),range_F0);
%     z_int_nat = xlsread(prosody_nat,word_list(i,:),range_int);
%     dur_nat = xlsread(prosody_nat,word_list(i,:),range_dur);
%     label = xlsread(prosody_erj,word_list(i,:),range_label);
%     all_data(i,1:7) = {z_F0_erj,z_int_erj,dur_erj, ...
%                        z_F0_nat,z_int_nat,dur_nat, ...
%                        label};
% end


%%% Average corr per word after n iter
iter_RES_corr_wdist_F0_perword = zeros(size(word_list,1),1);
iter_RES_corr_wdist_int_perword = zeros(size(word_list,1),1);
iter_RES_corr_wdist_F0_int_perword = zeros(size(word_list,1),1);

%%% Average corr per feature after n iter
iter_final_corr_wdist_F0 = 0;
iter_final_corr_wdist_int = 0;
iter_final_corr_wdist_F0_int = 0;

for it = 1:n_iter

    %%% Final results (for 1 iter)
    RES_corr_wdist_F0_perword = zeros(length(word_list),1);
    RES_corr_wdist_int_perword = zeros(length(word_list),1);
    RES_corr_wdist_F0_int_perword = zeros(length(word_list),1);



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
        %%%               K-MEANS CLUSTERING
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [k_F0,k_int] = chooseKFromError(soft_F0_nat,soft_int_nat);

        % Check that the nb of clusters is less than the nb of native
        % utterances
        if (size(soft_F0_nat,1) <= k_F0)
            k_F0 = size(soft_F0_nat,1);
        end
        if (size(soft_int_nat,1) <= k_int)
            k_int = size(soft_int_nat,1);
        end

        clusters_F0 = kMeans(soft_F0_nat,k_F0,max_kmeans);
        clusters_int = kMeans(soft_int_nat,k_int,max_kmeans);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%               WEIGHTED DISTANCES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        wdist_F0 = zeros(size(z_F0_erj,1),1);
        wdist_int = zeros(size(z_int_erj,1),1);
        for j = 1:size(z_F0_erj,1)
            wdist_F0(j) = min(weightedDist(soft_F0_erj(j,:),clusters_F0));
            wdist_int(j) = min(weightedDist(soft_int_erj(j,:),clusters_int));
        end

        %%% Average between F0 and int
        wdist_F0_int = mean([wdist_F0,wdist_int],2);

        %%% Correlation between the auto scores and the real ones
        %%% for one word
        corr_wdist_F0_word = corr(-wdist_F0,label);
        corr_wdist_int_word = corr(-wdist_int,label);
        corr_wdist_F0_int_word = corr(-wdist_F0_int,label);

        %%% Input the previous correlation scores to RES_corr
        RES_corr_wdist_F0_perword(i) = corr_wdist_F0_word;
        RES_corr_wdist_int_perword(i) = corr_wdist_int_word;
        RES_corr_wdist_F0_int_perword(i) = corr_wdist_F0_int_word;
    end
    
    iter_RES_corr_wdist_F0_perword = ...
        iter_RES_corr_wdist_F0_perword + ...
        atanh(RES_corr_wdist_F0_perword);
    iter_RES_corr_wdist_int_perword = ...
        iter_RES_corr_wdist_int_perword + ...
        atanh(RES_corr_wdist_int_perword);
    iter_RES_corr_wdist_F0_int_perword = ...
        iter_RES_corr_wdist_F0_int_perword + ...
        atanh(RES_corr_wdist_F0_int_perword);

    %%% Average the correlation scores of all words for each wdist
    %%% using Fisher's method
    final_corr_wdist_F0 = 0;
    final_corr_wdist_int = 0;
    final_corr_wdist_F0_int = 0;

    for i = 1:length(word_list)
        final_corr_wdist_F0 = final_corr_wdist_F0 + atanh(RES_corr_wdist_F0_perword(i));
        final_corr_wdist_int = final_corr_wdist_int + atanh(RES_corr_wdist_int_perword(i));
        final_corr_wdist_F0_int = final_corr_wdist_F0_int + atanh(RES_corr_wdist_int_perword(i));
    end

    final_corr_wdist_F0 = tanh(final_corr_wdist_F0/size(word_list,1));
    final_corr_wdist_int = tanh(final_corr_wdist_int/size(word_list,1));
    final_corr_wdist_F0_int = tanh(final_corr_wdist_F0_int/size(word_list,1));
    
    %%% Average over all the iterations
    iter_final_corr_wdist_F0 = iter_final_corr_wdist_F0 + atanh(final_corr_wdist_F0);
    iter_final_corr_wdist_int = iter_final_corr_wdist_int + atanh(final_corr_wdist_int);
    iter_final_corr_wdist_F0_int = iter_final_corr_wdist_F0_int + atanh(final_corr_wdist_F0_int);
end

iter_RES_corr_wdist_F0_perword = tanh(iter_RES_corr_wdist_F0_perword/n_iter);
iter_RES_corr_wdist_int_perword = tanh(iter_RES_corr_wdist_int_perword/n_iter);
iter_RES_corr_wdist_F0_int_perword = tanh(iter_RES_corr_wdist_F0_int_perword/n_iter);

iter_final_corr_wdist_F0 = tanh(iter_final_corr_wdist_F0/n_iter);
iter_final_corr_wdist_int = tanh(iter_final_corr_wdist_int/n_iter);
iter_final_corr_wdist_F0_int = tanh(iter_final_corr_wdist_F0_int/n_iter);

% Read text data contained in specified range
% from excel sheet
% function txt = readTxt(filename, worksheet, range)
% [num,txt,raw] = xlsread(filename,worksheet,range);
% end
