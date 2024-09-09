clc;
clear;
close all;
format short g;
%% To start the execution,load one of the datasets from lines 7 to 36.

load ecoli2.mat    %ecoli1  
% load glass0.mat    %glass1 
% load iris1.mat   
% load wine1.mat    

% load segment0.mat     %Lines 12 and 13 run together, otherwise you will get an error.     
% data=[data(:,1:2),data(:,4:end)]; 

% load vehicle0.mat
% load yeast5.mat
% load yeast6.mat
% load abalone19.mat

% load abalone-17_vs_7-8-9-10.mat           
% load abalone-20_vs_8-9-10.mat
% load abalone-3_vs_11.mat   
% load abalone9-18.mat

% load  kddcup-buffer_overflow_vs_back.mat  %Lines 25 and 26 run together, otherwise you will get an error.
% data=[data(:,1),data(:,3:6),data(:,10),data(:,13:14),data(:,16:17),data(:,23:33),data(:,36:42)]; 

% load  kddcup-rootkit-imap_vs_back_cfs.mat
% load kr-vs-k-zero_vs_fifteen.mat   
% load car-good.mat
% load car-vgood.mat
% load flare-F.mat

[r,c]=size(data); 
minority_data=data(data(:,c)==1,:);
majority_data=data(data(:,c)==2,:);

%% Draw a graph on data
% labels=data(:,end);
% data1=data(:,1:end-1);
% figure, scatter(data1(:,1), data1(:,2),25, labels,'filled');
% title('dataset');
% xlabel('x');
% ylabel('y');
% colormap([0 0 1;1 0 0])  %RGB for example R=1 0 0
%% Data normalization
normalize_data=zeros(r,c-1);
for   i=1:c-1
normalize_data(:,i)=(data(:,i)-min(data(:,i)))/(max(data(:,i))-min(data(:,i)));
end
data=[normalize_data,data(:,end)];
data=unique(data,'rows');
labels=data(:,end);
data1=data(:,1:end-1);

%% Call function over_classify_svm

minority_data=data(data(:,c)==1,:);
majority_data=data(data(:,c)==2,:);

[ after_svm_Precision,after_svm_Recall,after_svm_Fmeasure,after_svm_G_means,after_svm_accuracy,...
 Std_Dev_svm_recall,Std_Dev_svm_precision,Std_Dev_svm_F_measure,Std_Dev_svm_G_means,Std_Dev_svm_accuracy,]=...
                                                                                 over_classify_svm(data); 
                                                                     