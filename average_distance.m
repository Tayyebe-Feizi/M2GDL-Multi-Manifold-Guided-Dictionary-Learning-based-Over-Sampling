function  [ave_distance]=average_distance(minority_data)

[r,~]=size(minority_data); 
sum=0;
cnt=0;

for i=1:r-1
    for  j=r-1:-1:i+1
        difference=minority_data(i,:)-minority_data(j,:);
        length=norm(difference,2);
        sum=sum+length;
        cnt=cnt+1;
    end
end
ave_distance=sum/cnt;
end