function stego_DCT = get_stego_DCT( stego_blk_dct_cell_1 )
[m,n]=size(stego_blk_dct_cell_1);
id=0;
stego_DCT = zeros(512,512);
stego_DCT = mat2cell(stego_DCT,ones(512/8,1)*8,ones(512/8,1)*8); 
for i = 1:64
    for j = 1:64
        x = 1;
        for u = 1:8
            for v = 1:8
              stego_DCT{i,j}(u,v) =   stego_blk_dct_cell_1{i,j}(x);
              x = x +1;
            end
        end
    end     
 end
end

