function [stego_blk_dct,pos] = embed_Zhou_1(stego_blk_dct,data,pos,i,positions)
l_data = numel(data);
for L= 1:2048
    if pos == l_data ||pos == l_data+1;
        break;
    end
    for n=1:length(positions)
        if abs(stego_blk_dct{i,L}(positions(n),1))==1 && abs(stego_blk_dct{i,L}(positions(n),2))==1
            if pos == l_data - 1
            data = [data,0];
            end
            if data(pos+1) == 1 && data(pos+2) == 1
                stego_blk_dct{i,L}(positions(n),2) = stego_blk_dct{i,L}(positions(n),2)+ sign(stego_blk_dct{i,L}(positions(n),2));
                pos = pos + 2;
            elseif data(pos+1) == 1 && data(pos+2) == 0
                stego_blk_dct{i,L}(positions(n),1) = stego_blk_dct{i,L}(positions(n),1) + sign(stego_blk_dct{i,L}(positions(n),1));
                pos = pos + 2;
            elseif data(pos+1) == 0
                pos = pos + 1;
            end
        elseif abs(stego_blk_dct{i,L}(positions(n),1))==1 && abs(stego_blk_dct{i,L}(positions(n),2))~=1 && abs(stego_blk_dct{i,L}(positions(n),2))~=0
            if data(pos+1) == 0
                stego_blk_dct{i,L}(positions(n),2) = stego_blk_dct{i,L}(positions(n),2) + sign(stego_blk_dct{i,L}(positions(n),2));
                pos = pos + 1;
            elseif data(pos+1) == 1
                stego_blk_dct{i,L}(positions(n),1) = stego_blk_dct{i,L}(positions(n),1) + sign(stego_blk_dct{i,L}(positions(n),1));
                pos = pos + 1;
            end
        elseif abs(stego_blk_dct{i,L}(positions(n),1))~=1 && abs(stego_blk_dct{i,L}(positions(n),1))~=0 && abs(stego_blk_dct{i,L}(positions(n),2))==1
            if data(pos+1) == 0
                stego_blk_dct{i,L}(positions(n),1) = stego_blk_dct{i,L}(positions(n),1) + sign(stego_blk_dct{i,L}(positions(n),1));
                pos = pos + 1;
            elseif data(pos+1) == 1
                stego_blk_dct{i,L}(positions(n),1) = stego_blk_dct{i,L}(positions(n),1) + sign(stego_blk_dct{i,L}(positions(n),1));
                stego_blk_dct{i,L}(positions(n),2) = stego_blk_dct{i,L}(positions(n),2) + sign(stego_blk_dct{i,L}(positions(n),2));
                pos = pos + 1;
            end
        elseif abs(stego_blk_dct{i,L}(positions(n),1))==0 && abs(stego_blk_dct{i,L}(positions(n),2))==1
            if data(pos+1) == 0
                pos = pos + 1;
            elseif data(pos+1) == 1
                stego_blk_dct{i,L}(positions(n),2) = stego_blk_dct{i,L}(positions(n),2) + sign(stego_blk_dct{i,L}(positions(n),2));
                pos = pos + 1;
            end
        elseif abs(stego_blk_dct{i,L}(positions(n),1))==1 && abs(stego_blk_dct{i,L}(positions(n),2))==0
            if data(pos+1) == 0
                pos = pos + 1;
            elseif data(pos+1) == 1
                stego_blk_dct{i,L}(positions(n),1) = stego_blk_dct{i,L}(positions(n),1) + sign(stego_blk_dct{i,L}(positions(n),1));
                pos = pos + 1;
            end        
        elseif abs(stego_blk_dct{i,L}(positions(n),1))==0 && abs(stego_blk_dct{i,L}(positions(n),2))==0
                continue;
        else  % ÒÆÎ»¶Ô
            stego_blk_dct{i,L}(positions(n),1) = stego_blk_dct{i,L}(positions(n),1) + sign(stego_blk_dct{i,L}(positions(n),1));
            stego_blk_dct{i,L}(positions(n),2) = stego_blk_dct{i,L}(positions(n),2) + sign(stego_blk_dct{i,L}(positions(n),2));
        end
        if pos == l_data ||pos == l_data+1;
            break;
        end
    end
end
end

