function [manifold,all_data_map]=neighborhood_Measure_mm(data)
%% number of each classes
labels=data(:,end);
class=unique(labels);
%% initialization
k=3;   %number of neighborhood for calculate neighborhood_Measurement 
k=k+1;
[~,c]=size(data); 

manifold=struct;          %names and alpha values of all manifolds on both of class
all_data_map=struct;      %map on both of class Simultaneously

%% unsupervised Linear Methods
%PCA:  Principal Component Analysis 
%LPP:  Locality Preserving Projection
%NPE: Neighborhood Preserving Embedding
%% map all data together or  map on both of class Simultaneously
all_X=data(:,1:end-1);
no_dims=c-1;

%***************Mapping with the PCA manifold****************************
  type='PCA';
 [mappedX, mapping] = compute_mapping(all_X,type, no_dims);
 all_data_map(1).all_x=mappedX;
%***************Mapping with the LPP manifold****************************
 type='LPP';
 [mappedX, mapping] = compute_mapping(all_X,type, no_dims);	
 all_data_map(2).all_x=mappedX;

%***************Mapping with the NPE manifold****************************
 type='NPE';
 [mappedX, mapping] = compute_mapping(all_X,type, no_dims);	
 all_data_map(3).all_x=mappedX;

 for i=1:3
    all_data_map(i).all_x=real(all_data_map(i).all_x);    
    all_data_map(i).all_x(isnan(all_data_map(i).all_x))=0;
 end
 %% map every class individually or map on only one class individually for all manifolds
for i=1:numel(class)
     classNo(i)=numel(find(labels==class(i)));
     classes=data(data(:,c)==i,:);
     nc=classNo(i);
     X =classes(:,1:c-1);      
     label_class=classes(:,c); 
%% calculate neighborhoods  before mapping
     sample= classes;
     [Idx1,D] = knnsearch(classes,sample,'K',k, 'Distance','euclidean');
     Idx=Idx1(:,2:end);
     neighbor_before=Idx;
     no_dims=c-1;
%% ***************Mapping with the PCA manifold****************************
    utype_m='PCA';
    type=utype_m; 
    [mappedX, mapping] = compute_mapping(X,type, no_dims);	 
    mappedX=real(mappedX);
    mappedX(isnan(mappedX))=0;

    [Idx2,d] = knnsearch(mappedX,sample(:,1:end-1),'K',k, 'Distance','euclidean');    % calculate neighborhoods after mapping
    IIdx=Idx2(:,2:end);
    neighbor_after=IIdx;
    for s=1:nc
       [overlap, ia, ib] = intersect(neighbor_before(s,:), neighbor_after(s,:));       %Neighbor overlap calculation
       unsup_cardinality(s,1)=size(overlap,2);
    end
            
%% ***************Mapping with the LPP manifold****************************
   type='LPP';
   utype_m=char(utype_m,type);
   [mappedX, mapping] = compute_mapping(X,type, no_dims);	 
    mappedX=real(mappedX);
    mappedX(isnan(mappedX))=0;
    [Idx2,d] = knnsearch(mappedX,sample(:,1:end-1),'K',k, 'Distance','euclidean');    % calculate neighborhoods after mapping
    IIdx=Idx2(:,2:end);
    neighbor_after=IIdx;
    for s=1:nc
       [overlap, ia, ib] = intersect(neighbor_before(s,:), neighbor_after(s,:));       %Neighbor overlap calculation
       unsup_cardinality(s,2)=size(overlap,2);
    end
            
%% ***************Mapping with the NPE manifold ****************************       
   type='NPE';
   utype_m=char(utype_m,type);
   [mappedX, mapping] = compute_mapping(X,type, no_dims);	 
    mappedX=real(mappedX);
    mappedX(isnan(mappedX))=0;
    [Idx2,d] = knnsearch(mappedX,sample(:,1:end-1),'K',k, 'Distance','euclidean');    % calculate neighborhoods after mapping
    IIdx=Idx2(:,2:end);
    neighbor_after=IIdx;
    for s=1:nc
       [overlap, ia, ib] = intersect(neighbor_before(s,:), neighbor_after(s,:));       %Neighbor overlap calculation
       unsup_cardinality(s,3)=size(overlap,2);
    end 
    unsup_cardinality(isnan(unsup_cardinality))=0;
        
%% save names and alpha values all manifolds on both of class
    manifold(i).alpha=sum(unsup_cardinality)';   
    manifold(i).type=char(utype_m);
   
end
k=k-1;
end