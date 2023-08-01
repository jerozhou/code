function [num_embed_pairs,type_embed_pairs,single_blk_capacity]= get_embed_pairs( single_blk_capacity,blk_pairs )
num_embed_pairs = zeros(64,3);
h = 100;
type_embed_pairs = [1,1,0;
                    2,2,0;
                    1,h,0;
                    h,1,0;
                    0,1,0;
                    0,h,0;
                    h,h,0];
[~,n] = size(blk_pairs); 
%for count = 1:63
    for c = 2:64
        for r = 1:n
            if abs(blk_pairs{1,r}(c,1))==1 && abs(blk_pairs{1,r}(c,2))==1 %(1,1)
                num_embed_pairs(c,1) = num_embed_pairs(c,1)+1;
                num_embed_pairs(c,3) = num_embed_pairs(c,3)+1.5;
                type_embed_pairs(1,3) = type_embed_pairs(1,3)+1;
                single_blk_capacity(c,r) = 1.5;
            elseif abs(blk_pairs{1,r}(c,1))==2 && abs(blk_pairs{1,r}(c,2))==2 %(2,2) 将此类型转为移位对，不嵌入秘密信息。
                num_embed_pairs(c,2) = num_embed_pairs(c,2)+1;
                type_embed_pairs(7,3) = type_embed_pairs(7,3)+1;
            elseif (abs(blk_pairs{1,r}(c,1))==1 && abs(blk_pairs{1,r}(c,2))~=1 && abs(blk_pairs{1,r}(c,2))~=0)%(1,h)
                num_embed_pairs(c,1) = num_embed_pairs(c,1)+1;
                num_embed_pairs(c,3) = num_embed_pairs(c,3)+1;
                type_embed_pairs(3,3) = type_embed_pairs(3,3)+1;
                single_blk_capacity(c,r) = 1;
            elseif  (abs(blk_pairs{1,r}(c,1))~=1 && abs(blk_pairs{1,r}(c,1))~=0 && abs(blk_pairs{1,r}(c,2))==1)%(h,1)
                num_embed_pairs(c,1) = num_embed_pairs(c,1)+1;
                num_embed_pairs(c,3) = num_embed_pairs(c,3)+1;
                type_embed_pairs(4,3) = type_embed_pairs(4,3)+1;  
                single_blk_capacity(c,r) = 1;
            elseif (abs(blk_pairs{1,r}(c,1))==0 && abs(blk_pairs{1,r}(c,2))==1) || (abs(blk_pairs{1,r}(c,1))==1 && abs(blk_pairs{1,r}(c,2))==0)
                num_embed_pairs(c,1) = num_embed_pairs(c,1)+1;
                num_embed_pairs(c,3) = num_embed_pairs(c,3)+1;
                type_embed_pairs(5,3) = type_embed_pairs(5,3)+1;
                single_blk_capacity(c,r) = 1;
            elseif (abs(blk_pairs{1,r}(c,1))==0 && abs(blk_pairs{1,r}(c,2))>=1) || (abs(blk_pairs{1,r}(c,1))>=1 && abs(blk_pairs{1,r}(c,2))==0) 
                num_embed_pairs(c,2) = num_embed_pairs(c,2)+1;
                type_embed_pairs(6,3) = type_embed_pairs(6,3)+1;
            elseif abs(blk_pairs{1,r}(c,1))==0 && abs(blk_pairs{1,r}(c,2))==0
                continue;
            else
                num_embed_pairs(c,2) = num_embed_pairs(c,2)+1;
                type_embed_pairs(7,3) = type_embed_pairs(7,3)+1;
            end
        end
    end
            
end

