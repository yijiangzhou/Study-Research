function cstar = solveforc1(w,A,beta,r)
syms c
y = (1/c) - (beta/(r * (A + (w^3)/(c^2) -c)));

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