function b =get_mark(a)
for i=1:8
    for j = 1:8
        if i == 1 && j == 1
            a(i,j) = 0;
        elseif a(i,j) ~= 0;
            a(i,j) = 1;
        end
    end     
b = a;
end

