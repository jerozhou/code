function [File_Size,PSNR,runtime,ssim] = RDH_Zhou(name_cover,secret)
% ������ƽ�������Ӷȵ�JPEGͼ�������Ϣ���ء���
t1 = clock;
%% ��ȡͼ����Ϣ
payload = numel(secret);
jpg_obj = jpeg_read(name_cover);
jpg_dct = jpg_obj.coef_arrays{1,1};% �õ�ͼ��DCTϵ��
Q_table=jpg_obj.quant_tables{1}; %�õ�JPEGͼ���������
[row,col] = size(jpg_dct);%ͼ��ĳߴ��С
blk_dct = mat2cell(jpg_dct,ones(row/8,1)*8,ones(col/8,1)*8);  % �õ�8*8�Ŀ�
N = row * col / (8 * 8); % 8*8���������

%������ACϵ������
% num_zeroAC = cellfun(@(x) sum(sum(x(2:64)==0)), blk_dct); % the number of zero-AC coefficients in each block.
% s_zeroac(:,1) = 1:1:N;%����һ��4096 x 1������
% s_zeroac(:,2) = reshape(num_zeroAC,[N 1]);%����ÿ���飨4096����0ϵ���ĸ�����
% s_zeroac = sortrows(s_zeroac,-2); % ����0ϵ���Կ鰴�н��н���
% s_zeroac_1 = s_zeroac(:,1);
% trans_blk_dct_1 = reshape(blk_dct,[N,1]);
% for i=1:N
%     sort_blk_dct_zero(i) = trans_blk_dct_1(s_zeroac_1(i));
% end
% sort_blk_dct_zero = reshape(sort_blk_dct_zero,[N,1]);
% bin64_zero = cellfun(@(x) zigzag2(x), sort_blk_dct_zero,'UniformOutput',false); 
% bin64_zero = [bin64_zero{:}];

%% ����ƽ�������Ӷȡ�
blk_mark = cellfun(@(x) get_mark(x),blk_dct,'UniformOutput',false); %��ÿ��DCT���еķ���ACϵ��Ƶ�ν��б�ǡ�
blk_texture = cellfun(@(x) get_texture(x,Q_table),blk_mark,'UniformOutput',false); %����ǵķ���ACϵ��Ƶ�εõ���Ӧ������ϵ��
blk_texture_sum = cellfun(@(x) sum(sum(x)), blk_texture);% �õ�ÿ����������Ӷ�Ri
no_zero_ac = cellfun(@(x) sum(sum(x(2:64)~=0)), blk_dct);%�õ�ÿ����ķ���ACϵ��������
average_blk_texture = blk_texture_sum ./ no_zero_ac;  %�õ�ÿ�����ƽ�������Ӷȡ�


%% ������
blk_sort(:,1) = 1:1:N;
blk_sort(:,2) = reshape(average_blk_texture,[N,1]);
blk_sort = sortrows(blk_sort,2);
blk_sort_1 = blk_sort(:,1);
trans_blk_dct = reshape(blk_dct,[N,1]);
for i=1:N
    sort_blk_dct(i) = trans_blk_dct(blk_sort_1(i));
end
sort_blk_dct = reshape(sort_blk_dct,[N,1]);

 %���������ÿ�����ӷ��ص������п��������ز�����Ӱ��
 Q_cost=costFun(Q_table); 

 %% ����2���鹹��ACϵ����
bin64 = cellfun(@(x) zigzag2(x), sort_blk_dct,'UniformOutput',false); %���г��ÿ��DCT����ijλ�õ�ϵ��Ϊһ�У���ͬλ��Ϊһ���γɾ���
bin64 = [bin64{:}];
blk_pairs = mat2cell(bin64,ones(1,1)*64,ones(2048,1)*2);%������2��ϵ�����ϳ�һ��cell
single_blk_capacity = zeros(64,2048);
single_blk_capacity(1,:) = 1:2048;
[num_embed_pairs,type_embed_pairs,single_blk_capacity] = get_embed_pairs(single_blk_capacity,blk_pairs);
unit = getuintcost63bin(num_embed_pairs,Q_cost);
unitDistortion(:,1) = 1:1:64;
unitDistortion(:,2) = unit;
unitDistortion = sortrows(unitDistortion,2);
unitDistortion_1 = unitDistortion(:,1);
blk_cap = type_embed_pairs(1,3)*1.5+type_embed_pairs(3,3)*1+type_embed_pairs(4,3)*1+type_embed_pairs(5,3)*1;%���ͼ�����ṩ��������EC
blk_cap = floor(blk_cap);
if blk_cap-100<payload  %����������С����ҪǶ���������ֹͣ��
    [fi,psnr_value,runtime] = deal(0);
    disp('estimated capacity is smaller than the given payload!');
    return;
end

%%  ������Ƕ�������������
R_MIN = 0;
est_cap = 0;
flag = 0;
for i = 1:64 %������Ƕ�������������
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
            blk_cap_1 = single_blk_capacity(p(k),j); %��ÿһ��ǰi�е�����
            est_cap = blk_cap_1+est_cap;%�����п�ǰi�е�������
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


%%  �����У�Ropt����ѡȡ
for r = R_MIN:R_MAX
    stego_blk_dct = blk_pairs;
    %count=1;1��
    pos = 0;
    for k = 1:r
        positions(k) = unitDistortion_1(k);
    end
    positions=sort(positions,2);
    while pos<payload
        i=1;
        [stego_blk_dct,pos] = embed_Zhou_1(stego_blk_dct,secret,pos,i,positions);
    end
    
    
    %% ������ϢǶ��
%      [side] = get_side(payload,positions); %��ñ���Ϣ
%      [stego_blk_dct] = LSB_embed(stego_blk_dct,side);%��81��ֱ��ϵ����LSB�滻Ϊ����Ϣ��
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
    
    
    %% ����Ƕ����Ϣ�������ͼƬ
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

