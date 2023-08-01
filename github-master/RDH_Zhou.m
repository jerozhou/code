function [File_Size,PSNR,runtime,ssim] = RDH_Zhou(name_cover,secret)
% 《基于平均纹理复杂度的JPEG图像可逆信息隐藏》。
t1 = clock;
%% 提取图像信息
payload = numel(secret);
jpg_obj = jpeg_read(name_cover);
jpg_dct = jpg_obj.coef_arrays{1,1};% 得到图像DCT系数
Q_table=jpg_obj.quant_tables{1}; %得到JPEG图像的量化表
[row,col] = size(jpg_dct);%图像的尺寸大小
blk_dct = mat2cell(jpg_dct,ones(row/8,1)*8,ones(col/8,1)*8);  % 得到8*8的块
N = row * col / (8 * 8); % 8*8块的总数量

%根据零AC系数排序
% num_zeroAC = cellfun(@(x) sum(sum(x(2:64)==0)), blk_dct); % the number of zero-AC coefficients in each block.
% s_zeroac(:,1) = 1:1:N;%生成一个4096 x 1的向量
% s_zeroac(:,2) = reshape(num_zeroAC,[N 1]);%生成每个块（4096）中0系数的个数。
% s_zeroac = sortrows(s_zeroac,-2); % 根据0系数对块按行进行降序。
% s_zeroac_1 = s_zeroac(:,1);
% trans_blk_dct_1 = reshape(blk_dct,[N,1]);
% for i=1:N
%     sort_blk_dct_zero(i) = trans_blk_dct_1(s_zeroac_1(i));
% end
% sort_blk_dct_zero = reshape(sort_blk_dct_zero,[N,1]);
% bin64_zero = cellfun(@(x) zigzag2(x), sort_blk_dct_zero,'UniformOutput',false); 
% bin64_zero = [bin64_zero{:}];

%% 计算平均纹理复杂度。
blk_mark = cellfun(@(x) get_mark(x),blk_dct,'UniformOutput',false); %将每个DCT块中的非零AC系数频段进行标记。
blk_texture = cellfun(@(x) get_texture(x,Q_table),blk_mark,'UniformOutput',false); %将标记的非零AC系数频段得到对应的量化系数
blk_texture_sum = cellfun(@(x) sum(sum(x)), blk_texture);% 得到每个块的纹理复杂度Ri
no_zero_ac = cellfun(@(x) sum(sum(x(2:64)~=0)), blk_dct);%得到每个块的非零AC系数的总数
average_blk_texture = blk_texture_sum ./ no_zero_ac;  %得到每个块的平均纹理复杂度。


%% 块排序
blk_sort(:,1) = 1:1:N;
blk_sort(:,2) = reshape(average_blk_texture,[N,1]);
blk_sort = sortrows(blk_sort,2);
blk_sort_1 = blk_sort(:,1);
trans_blk_dct = reshape(blk_dct,[N,1]);
for i=1:N
    sort_blk_dct(i) = trans_blk_dct(blk_sort_1(i));
end
sort_blk_dct = reshape(sort_blk_dct,[N,1]);

 %将量化表的每个因子返回到空域中看它对像素产生的影响
 Q_cost=costFun(Q_table); 

 %% 相邻2个块构造AC系数对
bin64 = cellfun(@(x) zigzag2(x), sort_blk_dct,'UniformOutput',false); %按列抽出每个DCT块中ij位置的系数为一行，相同位置为一行形成矩阵。
bin64 = [bin64{:}];
blk_pairs = mat2cell(bin64,ones(1,1)*64,ones(2048,1)*2);%将相邻2个系数块结合成一个cell
single_blk_capacity = zeros(64,2048);
single_blk_capacity(1,:) = 1:2048;
[num_embed_pairs,type_embed_pairs,single_blk_capacity] = get_embed_pairs(single_blk_capacity,blk_pairs);
unit = getuintcost63bin(num_embed_pairs,Q_cost);
unitDistortion(:,1) = 1:1:64;
unitDistortion(:,2) = unit;
unitDistortion = sortrows(unitDistortion,2);
unitDistortion_1 = unitDistortion(:,1);
blk_cap = type_embed_pairs(1,3)*1.5+type_embed_pairs(3,3)*1+type_embed_pairs(4,3)*1+type_embed_pairs(5,3)*1;%获得图像能提供的总容量EC
blk_cap = floor(blk_cap);
if blk_cap-100<payload  %如果最大容量小于所要嵌入的容量就停止。
    [fi,psnr_value,runtime] = deal(0);
    disp('estimated capacity is smaller than the given payload!');
    return;
end

%%  求满足嵌入容量的最低列
R_MIN = 0;
est_cap = 0;
flag = 0;
for i = 1:64 %求满足嵌入容量的最低列
    if flag == 1
        break
    end
    for k = 1:i
        p(k) = unitDistortion_1(k);
    end
    est_cap = 0;
    for j = 1:2048
        if flag == 1
            break;
        end
        for k =1:numel(p)
            blk_cap_1 = single_blk_capacity(p(k),j); %求每一块前i行的容量
            est_cap = blk_cap_1+est_cap;%求所有块前i行的总容量
            if est_cap >= payload+200
                flag = 1;
                R_MIN = i;
                break;
            end
        end
    end
end
R_MAX = 64;
FI_1 = zeros(R_MAX-R_MIN+1,1);
PSNR_1 = zeros(R_MAX-R_MIN+1,1);
SSIM_1 = zeros(R_MAX-R_MIN+1,1);


%%  最优列（Ropt）的选取
for r = R_MIN:R_MAX
    stego_blk_dct = blk_pairs;
    %count=1;1·
    pos = 0;
    for k = 1:r
        positions(k) = unitDistortion_1(k);
    end
    positions=sort(positions,2);
    while pos<payload
        i=1;
        [stego_blk_dct,pos] = embed_Zhou_1(stego_blk_dct,secret,pos,i,positions);
    end
    
    
    %% 辅助信息嵌入
%      [side] = get_side(payload,positions); %获得边信息
%      [stego_blk_dct] = LSB_embed(stego_blk_dct,side);%将81个直流系数的LSB替换为侧信息。
    stego_blk_dct = cell2mat(stego_blk_dct);
    stego_blk_dct_cell = mat2cell(stego_blk_dct,ones(1,1)*64,ones(1,4096)*1);
    stego_blk_dct_cell = reshape(stego_blk_dct_cell,[4096,1]);
    stego_blk_dct_cell_1 = cell(N,1);
    for i=1:N
        stego_blk_dct_cell_1{i,1} = stego_blk_dct_cell{find(blk_sort(:,1)==i),1};
%         stego_blk_dct_cell_1{i,1} = stego_blk_dct_cell{find(s_zeroac(:,1)==i),1};
    end
    stego_blk_dct_cell_1 =reshape(stego_blk_dct_cell_1,[64,64]); 
    stego_DCT = cellfun(@(x) reverse_zigzag(x),stego_blk_dct_cell_1,'UniformOutput',false);
    stego_DCT = cell2mat(stego_DCT);
    
    
    %% 生成嵌入信息后的载体图片
    stego_obj = jpg_obj;
    stego_obj.coef_arrays{1,1} = stego_DCT;
    stego_name = 'stego.jpg';
    jpeg_write(stego_obj,stego_name);
    cover = imread(name_cover);
    stego = imread(stego_name);
    cover_file = imfinfo(name_cover);
    stego_file = imfinfo(stego_name);
    FI_1(r-R_MIN+1) = (stego_file.FileSize - cover_file.FileSize) * 8;
    PSNR_1(r-R_MIN+1) = double(compute_psnr(cover,stego));
    SSIM_1(r-R_MIN+1) = SSIM(cover,stego);
end
[PSNR,ind]= max(PSNR_1);
File_Size = FI_1(ind);
ssim = SSIM_1(ind);
t2 = clock;
runtime = etime(t2,t1);
end

