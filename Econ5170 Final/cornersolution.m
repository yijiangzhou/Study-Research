function [cstar,hstar,vstar] = cornersolution(A_grid,A_value,w,beta,r,t,epsi,valuef)
h = 100:100:8700;
vmatrix = zeros(length(h),length(A_grid));
for i = 1:length(h)
    for j = 1:length(A_grid)
        c = A_value + w * h(i) - (A_grid(j)/(1+r));
        vmatrix(i,j) = log(c) - (1/1.5) * h(i)^1.5...
            + beta * discountv(w,A_value,r,c,h(i),t,epsi,valuef);
    end
end
[row,column] = find(vmatrix == max(vmatrix,[],'all'));
cstar = A_value + w * h(row) - (A_grid(column)/(1+r));
hstar = h(row);
vstar = vmatrix(row,column);



