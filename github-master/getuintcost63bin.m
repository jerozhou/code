function unit=getuintcost63bin(num_embed_pairs,Q_cost)
unit=zeros(64,1);
unit(1)=10000;
for i=2:64
                id=i-1;
                cost=sum(sum( Q_cost(:,:,id).^2 ));
                 cost=sqrt(cost/64);
                 if num_embed_pairs(i,1)==0
                     unit(i)=10000;
                 else
                  distortion=(0.5*num_embed_pairs(i,1)+num_embed_pairs(i,2))*cost;         %ÿ��λ��ϵ��������ʧ��
                unit(i)=distortion /num_embed_pairs(i,3);  %��λʧ�档
                 end
end
end