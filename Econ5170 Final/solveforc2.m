function cstar = solveforc2(bpi0,bpi1,bpi2,bpi3,bpi4,w,A,beta,r)
syms c
y = (1/c) - beta * (1+r) * (bpi0 + bpi1 * ((1+r) * (A + (w^3)/(c^2) -c))...
    + bpi2 * ((1+r) * (A + (w^3)/(c^2) -c))^2 + bpi3 * ((1+r) * (A + (w^3)/(c^2) -c))^3 ...
    + bpi4 * ((1+r) * (A + (w^3)/(c^2) -c))^4);

root = sym2cell(vpasolve(y,c));

temp = zeros(1,1);
for i = 1:length(root)
    if root{i}(1) > 0 && isreal(root{i}(1))
        temp(1) = root{i}(1);
        break % We only want one positive and real root.
    else
        temp(1) = NaN;
    end
end
cstar = temp(1);
