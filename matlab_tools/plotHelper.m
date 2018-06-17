%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%                        READ DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prosody_nat = 'prosodic_perword_native.xlsx';
% prosody_erj = 'prosodic_perword_erj.xlsx';
word_list = char(readTxt('prosodic_data_native.xlsx','wordList','I1:I36'));
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

word_id = 6; % see from word_list
z_F0_erj = all_data{word_id,1};
z_int_erj = all_data{word_id,2};
dur_erj = all_data{word_id,3};
z_F0_nat = all_data{word_id,4};
z_int_nat = all_data{word_id,5};
dur_nat = all_data{word_id,6};

soft_F0_erj = softmaxNorm(z_F0_erj,1); 
soft_int_erj = softmaxNorm(z_int_erj,1);
soft_F0_nat = softmaxNorm(z_F0_nat,1); 
soft_int_nat = softmaxNorm(z_int_nat,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%              CLUSTERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[k_F0,k_int] = chooseKFromError(soft_F0_nat,soft_int_nat);
max_iter = 50;
[cluster_F0,indices_F0] = kMeans(soft_F0_nat,k_F0,max_iter);
[cluster_int,indices_int] = kMeans(soft_int_nat,k_int,max_iter);
tr_soft_F0_nat = transpose(soft_F0_nat);
tr_soft_int_nat = transpose(soft_int_nat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%              CONTOUR SMOOTHING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = 1:25;
xi = 1:0.2:25;

%%% Smoothe F0 erj
smoothe_F0_erj = [];
for k=1:size(z_F0_erj,1)
%     yi = pchip(x,z_F0_erj(i,:),xi);
    yi = pchip(x,soft_F0_erj(k,:),xi);
    smoothe_F0_erj = cat(1,smoothe_F0_erj,yi);
end
%%% Smoothe int erj
smoothe_int_erj= [];
for k=1:size(z_int_erj,1)
%     yi = pchip(x,z_int_erj(i,:),xi);
    yi = pchip(x,soft_int_erj(k,:),xi);
    smoothe_int_erj = cat(1,smoothe_int_erj,yi);
end

%%% Smoothe F0 nat
smoothe_F0_nat = [];
for k=1:size(z_F0_nat,1)
%     yi = pchip(x,z_F0_erj(k,:),xi);
    yi = pchip(x,soft_F0_nat(k,:),xi);
    smoothe_F0_nat = cat(1,smoothe_F0_nat,yi);
end
%%% Smoothe int nat
smoothe_int_nat= [];
for k=1:size(z_int_nat,1)
%     yi = pchip(x,z_int_erj(i,:),xi);
    yi = pchip(x,soft_int_nat(k,:),xi);
    smoothe_int_nat = cat(1,smoothe_int_nat,yi);
end

%%% Smoothe clusters
smoothe_cluster_F0 = [];
for k=1:size(cluster_F0,1)
    yi = pchip(x,cluster_F0(k,:),xi);
    smoothe_cluster_F0 = cat(1,smoothe_cluster_F0,yi);
end
smoothe_cluster_int = [];
for k=1:size(cluster_int,1)
    yi = pchip(x,cluster_int(k,:),xi);
    smoothe_cluster_int = cat(1,smoothe_cluster_int,yi);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%              PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
font_size = 14;

%%% Individual prosodic contour and duration for native spk
% j = 1;
% plot(xi,transpose(smoothe_F0_nat(j,:)-0.5),'LineWidth',1.5);
% hold on
% plot(xi,transpose(smoothe_int_nat(j,:)-0.5),'LineWidth',1.5);
% s = bar(dur_erj(j,:),'FaceColor', [0.4,0.1,0.1]);
% hold off
% alpha(s,0.5)

% xlabel('Sample points','FontSize',font_size);
% ylabel('Sigmoid normalised z-scores','FontSize',font_size)
% title('F0, intensity and duration native speaker','FontSize',font_size);

%%% Individual prosodic contour and duration for native spk
% figure
% j = 4;
% plot(xi,transpose(smoothe_F0_erj(j,:)-0.5),'LineWidth',1.5);
% hold on
% plot(xi,transpose(smoothe_int_erj(j,:)-0.5),'LineWidth',1.5);
% s = bar(dur_nat(j,:),'FaceColor', [0.4,0.1,0.1]);
% hold off
% alpha(s,0.5)
% xlabel('Sample points','FontSize',font_size);
% ylabel('Sigmoid normalised z-scores','FontSize',font_size)
% title('F0, intensity and duration Japanese speaker','FontSize',font_size);

%%% Durations of native and non-native
spk_nat = 8;
spk_erj = 11;
% figure
% % bar(dur_nat(spk_nat,:),'FaceColor', [0.5,0.1,0.1])
% bar(dur_nat(spk_nat,:))
% hold on
% % bar(dur_erj(spk_erj,:),'FaceColor', [0.1,0.5,0.1])
% s = bar(dur_erj(spk_erj,:));
% hold off
% alpha(.5)
% xlabel('Sample points','FontSize',font_size)
% ylabel('Duration percentage')
% title('Vowel duration for native and non native speakers')

%%% Average of all native durations
dur_nat_avg = mean(dur_nat);
figure
bar(dur_nat_avg);
plot_title = strcat('Average native speakers vowel duration ', ...
        ' (',lower(word_list(word_id,:)),')');
title(plot_title, 'FontSize', font_size);

%%% Average of all nonnative durations
dur_erj_avg = mean(dur_erj);
figure
bar(dur_erj_avg);
plot_title = strcat('Average non native speakers vowel duration ', ...
        ' (',lower(word_list(word_id,:)),')');
title(plot_title, 'FontSize', font_size);

%%% Difference btw one spk's dur and native ones
figure
diff_dur = dur_erj(spk_erj,:) - dur_nat_avg;
hold on
d = bar(dur_erj(spk_erj,:));
e = bar(diff_dur);
hold off
alpha(0.5);
plot_title = strcat('Duration difference btw non native and avg native ',...
    ' (',lower(word_list(word_id,:)),')');
title(plot_title,'FontSize',font_size);


%%% All F0 native
% figure
% plot(xi,transpose(smoothe_F0_erj));
% hold on
% plot(xi,transpose(smoothe_cluster_F0(1,:)),'LineWidth',2); % centroid
% hold off
% xlabel('Sample points','FontSize',font_size)
% ylabel('Sigmoid normalised z-scores','FontSize',font_size)
% title('All F0 contours','FontSize',font_size)

%%% One figure per F0 cluster and its centroid
% for k_id = 1:k_F0
%     dur_avg_F0 = mean(dur_nat(indices_F0==k_id,:));
%     figure
% %     plot(xi,transpose(smoothe_cluster_F0(i,:)),'LineWidth',3);
%     plot(xi,transpose(smoothe_cluster_F0(k_id,:)-0.5),'LineWidth',3); % translate
%     hold on
% %     plot(xi,transpose(smoothe_F0_nat(indices_F0==i,:)));
%     plot(xi,transpose(smoothe_F0_nat(indices_F0==k_id,:)-0.5));
%     d = bar(dur_avg_F0);
%     hold off
%     alpha(d,0.5);
%     plot_title = strcat('F0 Cluster ',int2str(k_id), ...
%         ' (',lower(word_list(word_id,:)),')');
%     xlabel('Sample points','FontSize',font_size)
%     ylabel('Sigmoid normalised z-scores','FontSize',font_size)
%     title(plot_title,'FontSize',font_size)
% end

%%% All int contours
% figure
% plot(xi,transpose(smoothe_int_nat));
% plot_title = strcat('All intensity contours ', ...
%         ' (',word_list(word_id,:),')');
% xlabel('Sample points','FontSize',font_size)
% ylabel('Sigmoid normalised z-scores','FontSize',font_size)
% title(plot_title,'FontSize',font_size)

%%% One figure per int cluster
% for k_id = 1:k_int
%     dur_avg_int = mean(dur_nat(indices_int==k_id,:));
%     figure
% %     plot(xi,transpose(smoothe_cluster_int(i,:)),'LineWidth',3);
%     plot(xi,transpose(smoothe_cluster_int(k_id,:)-0.5),'LineWidth',3); % translate
%     hold on
% %     plot(xi,transpose(smoothe_int_nat(indices_int==i,:)));
%     plot(xi,transpose(smoothe_int_nat(indices_int==k_id,:)-0.5));
%     d = bar(dur_avg_int);
%     hold off
%     alpha(d,0.5);
%     plot_title = strcat('Int Cluster ',int2str(k_id), ...
%         ' (',lower(word_list(word_id,:)),')');
%     xlabel('Sample points','FontSize',font_size)
%     ylabel('Sigmoid normalised z-scores','FontSize',font_size)
%     title(plot_title,'FontSize',font_size)
% end

%%% Several contours
% figure
% hold on;
% for i = 1:5
%     plot(xi,transpose(smoothe_F0_nat(i,:)),'LineWidth',1.5);
% end
% hold off
% title('F0 contours native')


% Read text data contained in specified range
% from excel sheet
function txt = readTxt(filename, worksheet, range)
[num,txt,raw] = xlsread(filename,worksheet,range);
end



