function [Ave_precision_svm,Ave_recall_svm,Ave_F_measure_svm,Ave_G_means_svm,Ave_accuracy_svm,...
          Std_Dev_svm_recall,Std_Dev_svm_precision,Std_Dev_svm_F_measure,Std_Dev_svm_G_means,Std_Dev_svm_accuracy]=...
          over_classify_svm(data)
%% Initialization of variables
[~,c]=size(data);
minority_data1=data(data(:,c)==1,:);
majority_data1=data(data(:,c)==2,:);
data=[minority_data1;majority_data1];

data1=data(:,1:end-1);
lable=data(:,end);

[no_class,~]=size(unique(lable));
kf=10;   %number of folds ,kfold=10
kernel_svm='RBF';          %for SVM 
% kernel_svm='polynomial'; %for SVM 
%type_measure='N';
iter=5;    %number of Iteration  

%% Define the variable to calculate the standard deviation *********
all_recall=zeros(kf,iter,1);
all_precision=zeros(kf,iter,1);
all_F_measure=zeros(kf,iter,1);
all_G_means=zeros(kf,iter,1);
all_accuracy=zeros(kf,iter,1);

for j=1:iter
%% Define performance criteria before over-sampling*****************

recall_before=zeros(kf,1);
precision_before=zeros(kf,1);
F_measure_before=zeros(kf,1);
G_means_before=zeros(kf,1);
accuracy_before=zeros(kf,1);

%% Define performance criteria after over-sampling*****************

recall_after=zeros(kf,1);
precision_after=zeros(kf,1);
F_measure_after=zeros(kf,1);
G_means_after=zeros(kf,1);
accuracy_after=zeros(kf,1);

%% Definition of confusion matrix before and after over-sampling*******

xs_svm_before=zeros(no_class);
xs_svm_after=zeros(no_class);

%% Divide the data into k parts or rewriting Kfold approach*****************
[minority_index]=kfold_func2(minority_data1,kf);
[majority_index]=kfold_func2(majority_data1,kf);
indices=[minority_index;majority_index];

for i = 1:kf
%% Define variables for program tracing
   iter_num=j    
   foldi=i  
   test = (indices == i); train = ~test;
        
   d=data(train(),:);
   min_data_train=d(d(:,c)==1,:);
   maj_data_train=d(d(:,c)==2,:);
   
   t=data(test(),:);
   min_data_test=t(t(:,c)==1,:);
   maj_data_test=t(t(:,c)==2,:);
       
   %% *********************create SVM model before over-sampling**************************
   model_svm_before = fitcsvm(data1(train(),:),lable(train(),:),'Standardize',true,'KernelFunction',kernel_svm,'KernelScale','auto');
   predicted_label_svm_before = predict(model_svm_before,data1(test(),:));
   xs_svm_before=confusionmat(lable(test(),:),predicted_label_svm_before);
   
   %% ***********************SVM_Measures_before over-sampling************************
   [recall_before(i,1),precision_before(i,1),F_measure_before(i,1),G_means_before(i,1),accuracy_before(i,1)]=...
                                                               measures_of_classify(xs_svm_before);
                                                           
   %% Creating a weighted combination of centrality and marginality in a multi-manifold approach
   %% Call the multi-manifold approache. 
   [sorted_weight,sorted_data,sort_lable]=over_multi_manifold(data(train(),:));

   %% ************************oversampling stage*************************
   [new_minority_data]=gradual_overSampling_func(sorted_weight,sorted_data,sort_lable); 
   over_data=[new_minority_data;d];
    
 %% *****************create SVM model after over sampling******************
   model_svm_after = fitcsvm(over_data(:,1:end-1),over_data(:,end),  'Standardize',true,'KernelFunction',kernel_svm,'KernelScale','auto');
   predicted_label_svm_after = predict(model_svm_after,data1(test(),:));
   xs_svm_after=confusionmat(lable(test(),:),predicted_label_svm_after);
 
    %% ***********************SVM_Measures_after over-sampling***********************
   [recall_after(i,1),precision_after(i,1),F_measure_after(i,1),G_means_after(i,1),accuracy_after(i,1)]=...
                                                               measures_of_classify(xs_svm_after);
    
%% **************while loop for SVM model  and gradual-over-sampling*****************************************
  over_data_svm=over_data;
  while   F_measure_after(i,1)>=F_measure_before(i,1)   
   
    if F_measure_after(i,1)==1
       break;
    end    
   if  F_measure_after(i,1)>F_measure_before(i,1)     
        F_measure_before(i,1)=F_measure_after(i,1);  
   end
    
   %************************oversampling data*************************
   [new_minority_data]=gradual_overSampling_func(sorted_weight,sorted_data,sort_lable); 
   r_min=size(new_minority_data,1);
   if r_min==0
       break;
   end       
   over_data_svm=[new_minority_data;over_data_svm];
   over_data_svm=unique(over_data_svm,'rows'); 
   
   minority_data=over_data_svm(over_data_svm(:,c)==1,:);
   majority_data=over_data_svm(over_data_svm(:,c)==2,:);
   r_min=size(minority_data,1);
   r_maj=size(majority_data,1);
   difference=r_min/r_maj;
   if   difference>0.9
       break;
   end
   %************create SVM model after over-sampling********************************
   model_svm_after = fitcsvm(over_data_svm(:,1:end-1),over_data_svm(:,end),'Standardize',true,'KernelFunction',kernel_svm,'KernelScale','auto');
   predicted_label_svm_after = predict(model_svm_after,data1(test(),:));
   xs_svm_after=confusionmat(lable(test(),:),predicted_label_svm_after);
   [recall_after(i,1),precision_after(i,1),F_measure_after(i,1),G_means_after(i,1),accuracy_after(i,1)]=...
                                                               measures_of_classify(xs_svm_after);
  end
  if   F_measure_after(i,1)<F_measure_before(i,1)
       F_measure_after(i,1)=F_measure_before(i,1);
  end  
 %% Draw a graph after over-sampling
%    b_data=over_data_svm(:,1:end-1);
%    b_lable=over_data_svm(:,end);
%    figure, scatter(b_data(:,1), b_data(:,2),25, b_lable,'filled');
%    title('over-sampling dataset');
%    xlabel('x1');
%    ylabel('x2');
%    colormap([0 0 1;1 0 0])  %RGB for example R=1 0 0
   
end   
%% **********Keeping the criteria of each replicate to calculate the standard deviation *****************************
%*********************for SVM  model*****************************
all_recall(:,j,1)=recall_after(:,1);
all_precision(:,j,1)=precision_after(:,1);
all_F_measure(:,j,1)=F_measure_after(:,1);
all_G_means(:,j,1)=G_means_after(:,1);
all_accuracy(:,j,1)=accuracy_after(:,1);

end
%% *********************criteria average in 5 repetitions *****************************

% *****************Average_SVM Model*****************************
Ave_recall_svm=sum(sum(all_recall(:,:,1)))/(iter*kf);
Ave_precision_svm=sum(sum(all_precision(:,:,1)))/(iter*kf);
Ave_F_measure_svm=sum(sum(all_F_measure(:,:,1)))/(iter*kf);
Ave_G_means_svm=sum(sum(all_G_means(:,:,1)))/(iter*kf);
Ave_accuracy_svm=sum(sum(all_accuracy(:,:,1)))/(iter*kf);


%% **********************calculate std.Dev.***************************

% *********************Std_Dev_SVM Model*****************************
Std_Dev_svm_recall=sqrt(sum(sum((all_recall(:,:,1)-Ave_recall_svm).^2))/(iter*kf));
Std_Dev_svm_precision=sqrt(sum(sum((all_precision(:,:,1)-Ave_precision_svm).^2))/(iter*kf));
Std_Dev_svm_F_measure=sqrt(sum(sum((all_F_measure(:,:,1)-Ave_F_measure_svm).^2))/(iter*kf));
Std_Dev_svm_G_means=sqrt(sum(sum((all_G_means(:,:,1)-Ave_G_means_svm).^2))/(iter*kf));
Std_Dev_svm_accuracy=sqrt(sum(sum((all_accuracy(:,:,1)-Ave_accuracy_svm).^2))/(iter*kf));

end