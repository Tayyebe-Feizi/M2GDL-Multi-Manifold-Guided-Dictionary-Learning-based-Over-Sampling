function  [Over_Sampling_Data]=gradual_overSampling_func(sorted_weight,sorted_data,sort_lable)

[~,c]=size(sorted_data); 
minority_data=sorted_data(sorted_data(:,c)==1,:);

sorted_weight_with_lables=[sorted_weight,sort_lable];   
minority_sorted_weight=sorted_weight_with_lables(sorted_weight_with_lables(:,2)==1,:);

label=minority_data(:,end);

[rr,~]=size(minority_data);
fifty_percent=round(rr*0.5);          
minority_sorted_weight(1:fifty_percent,3)=5;   %Separation of 50% of minority data

minority_data_selected=minority_data(minority_sorted_weight(:,3)==5,:);
fifty_percent_minority_data=minority_data_selected(:,1:end-1);
%lable_minority=minority_data_selected(:,end);
[nc,c]=size(minority_data_selected); 

k=3;       %number of neighborhoods for calculate main vectors
k=k+1;
x_i_Data=zeros(nc,c-1);
%% calculate neighborhoods for calculate main vectors
 [Idx1,~] = knnsearch(fifty_percent_minority_data,fifty_percent_minority_data,'K',k, 'Distance','euclidean');
 Idx=Idx1(:,2:end);
 k=k-1;
%% calculate value w
 [ave_distance]=average_distance(fifty_percent_minority_data);
 w=ave_distance*0.01;    %Setting the w parameter
 w(isnan(w))=0;
%% Over_Sampling phase
p=0;
for    i=1:nc
      
     v1= rand(1,k);           %Create initial v_i vector
     normalize_v=(v1-min(v1))/(max(v1)-min(v1));
     old_v_i=normalize_v/sum(normalize_v);
     
    U=fifty_percent_minority_data(Idx(i,:),1:end)';  
    for l=1:5                   % Number of optimization iterations
       x_i=U*old_v_i';          % Create an instance of x_i
            
       for j=1:k           %Checking the condition of closeness of the new data point to the manifold
       % z's is elements of  vector U 
       % Point z is assumed to be the neighbors of the sample around which we intend to generate samples
              z=fifty_percent_minority_data(Idx(i,j),1:end);   
              d= x_i-z';
              norm_d=norm(d,2);
              if  norm_d<w      
                  v1= rand(1,k);
                  normalize_v=(v1-min(v1))/(max(v1)-min(v1));
                  old_v_i=normalize_v/sum(normalize_v);
                  p=1;
                  break;
              end 
        end    
    
     if p==0 
     alpha=1;              % Setting the alpha parameter                           
     v2=(U'*x_i-0.5*alpha)'*inv(U'*U);                   %Create v_i vector
     normalize_v=(v2-min(v2))/(max(v2)-min(v2));
     new_v_i=normalize_v/sum(normalize_v);
     dd=new_v_i-old_v_i;
     norm_v_i=norm(dd,2);
     
     if  norm_v_i<=0.01     % Checking the convergence of v_i vector 
         x_i_Data(i,:)=x_i';
         break;
     else     % if  norm_v_i<=0.01 
     old_v_i=new_v_i;
     end      % if  norm_v_i<=0.01 
     end      % if p==0
    p=0; 
     
    end   % for l=1:5
end      % for    i=1:nc
%% Removal of zero rows (zero row means not creating a sample),
% which is caused by the lack of convergence of the v_i vector or the sample not being close to the manifold.
[r,~]= size(x_i_Data);
j=1;
q=0;
for i=1:r
    if   sum( x_i_Data(i,:))~=0
           Over(j,:)= x_i_Data(i,:);
           j=j+1;
           q=1;
   end    
end  

if q==1
lable_newdata=ones(j-1,1);
Over_Sampling_Data=[Over,lable_newdata];
else 
    Over_Sampling_Data=[];
end

Over_Sampling_Data=unique(Over_Sampling_Data,'rows');

end