function [ZRVs] = get_zrv(Z)
%genZRVs ��zigzagɨ��������ת����ZRV����ʽ, Z:1*64
Z = Z(2:64);%ȥ��DCϵ��
num = sum(sum(Z~=0));
ZRVs = zeros(num,4);
index = find(Z~=0);
for i = 1:num
    value = Z(index(i));
    size = length(dec2bin(abs(value))); %��10���Ʒ���ACϵ����λ��ת��Ϊ2����
    if i == 1
        run = index(i)-1;
        ZRVs(i,:) = [index(i),run,size,value];
    else
        run = index(i)-index(i-1)-1;
        ZRVs(i,:) = [index(i),run,size,value];
    end
end 
end

